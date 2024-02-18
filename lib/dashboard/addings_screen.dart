import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uas_pm2/fragments/home_screen.dart';

class AddingScreen extends StatefulWidget {
  final String section;

  AddingScreen({required this.section});

  @override
  _AddingScreenState createState() => _AddingScreenState();
}

class _AddingScreenState extends State<AddingScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  List<TextEditingController> genreControllers = [TextEditingController()];
  List<TextEditingController> actorControllers = [TextEditingController()];
  final TextEditingController dateController = TextEditingController();
  File? _pickedImage;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        dateController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _pickedImage = File(pickedImage.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item to ${widget.section}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(titleController, 'Title'),
              const SizedBox(height: 8.0),
              _buildTextField(descriptionController, 'Description'),
              const SizedBox(height: 8.0),
              _buildTextField(durationController, 'Duration'),
              const SizedBox(height: 8.0),
              _buildGenreAndActorFields(
                genreControllers,
                'Genre',
                Icons.movie,
              ),
              const SizedBox(height: 8.0),
              _buildGenreAndActorFields(
                actorControllers,
                'Actor',
                Icons.person,
              ),
              const SizedBox(height: 8.0),
              _buildDateField(),
              const SizedBox(height: 8.0),
              _buildImagePreview(),
              const SizedBox(height: 8.0),
              _buildPickImageButton(),
              const SizedBox(height: 16.0),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildGenreAndActorFields(
    List<TextEditingController> controllers,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        for (int i = 0; i < controllers.length; i++)
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controllers[i],
                  decoration: InputDecoration(
                    labelText: '$label ${i + 1}',
                    prefixIcon: Icon(icon),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    controllers.removeAt(i);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    controllers.add(TextEditingController());
                  });
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: dateController,
      decoration: InputDecoration(
        labelText: 'Date',
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return _pickedImage != null
        ? Image.file(
            _pickedImage!,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          )
        : Container();
  }

  Widget _buildPickImageButton() {
    return ElevatedButton(
      onPressed: () async {
        await _pickImage();
      },
      child: Text('Pick Image'),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await addNewItem();
            Navigator.of(context).pop();

            // After adding the item, push the home screen to refresh it
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  Future<void> addNewItem() async {
    try {
      // Connect to Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Generate a unique ID for the image
      String imageId = DateTime.now().millisecondsSinceEpoch.toString();

      // Get the current user's ID (Firebase Authentication)
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';

      // Define the storage path
      String storagePath = 'items/$userId/${widget.section}/$imageId.jpg';

      // Upload the image to Firebase Storage
      await FirebaseStorage.instance.ref(storagePath).putFile(_pickedImage!);

      // Example: Adding a document to the "items" collection
      await firestore.collection('items').add({
        'section': widget.section,
        'title': titleController.text,
        'description': descriptionController.text,
        'duration': durationController.text,
        'genres':
            genreControllers.map((controller) => controller.text).toList(),
        'actors':
            actorControllers.map((controller) => controller.text).toList(),
        'date': dateController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'imagePath': storagePath,
      });

      // Clear the controllers after adding the item
      titleController.clear();
      descriptionController.clear();
      durationController.clear();
      genreControllers.forEach((controller) => controller.clear());
      actorControllers.forEach((controller) => controller.clear());
      dateController.clear();

      print('Item added successfully to ${widget.section}');
    } catch (error) {
      print('Error adding item to ${widget.section}: $error');
    }
  }
}
