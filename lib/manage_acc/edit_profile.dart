import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class EditProfileScreen extends StatefulWidget {
  final File? profileImage;

  EditProfileScreen({Key? key, this.profileImage}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Uint8List? _profileImage;

  TextEditingController _usernameController = TextEditingController();

  bool _isEditing = false;
  File? _imageFile;

  Future<void> loadProfileData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      await loadProfileImage();
      _usernameController.text = _user!.displayName ?? "";
    }
  }

  Future<void> loadProfileImage() async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref('profile_images/${_user!.uid}.jpg');

    try {
      final Uint8List? data = await ref.getData();
      setState(() {
        _profileImage = data;
      });
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  Future<void> _updateProfileImage(File imageFile) async {
    try {
      // Upload the new image to Firebase Storage
      String imageName = '${_user!.uid}.jpg';
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref('profile_images/$imageName');
      await ref.putFile(imageFile);

      // Update the profile image URL in Firestore
      String imageURL = await ref.getDownloadURL();
      await _firestore.collection('users').doc(_user!.uid).update({
        'profileImageURL': imageURL,
      });

      // Refresh the displayed image
      await loadProfileImage();
    } catch (e) {
      print('Error updating profile image: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } on PlatformException catch (e) {
      print("Failed to pick image: $e");
    }
  }

  void _handleImagePicker() async {
    await _pickImage();

    if (_imageFile != null) {
      setState(() {
        _profileImage = File(_imageFile!.path).readAsBytesSync();
      });

      await _updateProfileImage(_imageFile!);
    }
  }

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> updateProfileDetails(String newUsername) async {
    try {
      // Update display name in Firebase Authentication
      await _user!.updateDisplayName(newUsername);

      // Update display name in Firestore (you can modify this for other fields as needed)
      await _firestore.collection('users').doc(_user!.uid).update({
        'username': newUsername,
      });

      // Reload profile data to update displayed name immediately
      await loadProfileData();
    } catch (e) {
      print('Error updating profile details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.0),
            Center(
              child: Container(
                width: 140.0,
                height: 140.0,
                child: Stack(
                  children: [
                    if (_profileImage != null)
                      Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: MemoryImage(_profileImage!),
                        ),
                      ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            _handleImagePicker();
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Username:',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            _isEditing
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your username',
                      ),
                    ),
                  )
                : Text(
                    '${_user?.displayName ?? "N/A"}',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                if (_isEditing) {
                  if (_user != null) {
                    await updateProfileDetails(_usernameController.text);
                  }
                }
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              child: Text(_isEditing ? 'Selesai' : 'Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
