import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:uas_pm2/dashboard/addings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:uas_pm2/dashboard/detail_screen.dart';

class CustomButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const CustomButton({
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.purple,
        onPrimary: Colors.white,
        shape: CircleBorder(),
      ),
      child: Icon(icon),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        flexibleSpace: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 16.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: (query) {
                      // Call the search function when text changes
                      searchItems(query);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 12.0,
                      ),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildCarouselSlider(), // Carousel Slider
            const SizedBox(height: 16.0),
            // Trending Now Section
            buildSection(
              'Trending Now',
              'https://firebasestorage.googleapis.com/v0/b/uaspm2.appspot.com/o/items%2FUPOeakmbA5ONJDH8XUl2r3lQ02I2%2Frending%20Now?alt=media',
              Icons.add,
              handleAddButtonPress,
            ),
            const SizedBox(height: 16.0),
            // Movie Section
            buildSection(
              'Movie',
              'https://firebasestorage.googleapis.com/v0/b/uaspm2.appspot.com/o/items%2FUPOeakmbA5ONJDH8XUl2r3lQ02I2%2FMovie?alt=media',
              Icons.add,
              handleAddButtonPress,
            ),
            const SizedBox(height: 16.0),
            // Series Section
            buildSection(
              'Series',
              'https://firebasestorage.googleapis.com/v0/b/uaspm2.appspot.com/o/items%2FUPOeakmbA5ONJDH8XUl2r3lQ02I2%2FSeries?alt=media',
              Icons.add,
              handleAddButtonPress,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCarouselSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 16 / 9,
        enlargeCenterPage: true,
        viewportFraction: 1.0,
      ),
      items: [
        Image.asset(
          'assets/images/1.png',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
        Image.asset(
          'assets/images/2.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
        Image.asset(
          'assets/images/3.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget buildSection(
    String sectionTitle,
    String imageUrl,
    IconData icon,
    Function(String) onPressed,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Row(
            children: [
              Text(
                sectionTitle,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              CustomButton(
                icon: icon,
                backgroundColor: Colors.blue,
                onPressed: () => onPressed(sectionTitle),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 150.0,
          child: FutureBuilder(
            future: getSectionItems(sectionTitle),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                // Display the list of items in the section
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data?.length,
                  itemBuilder: (BuildContext context, int index) {
                    // Wrap the item widget with GestureDetector
                    return GestureDetector(
                      onTap: () {
                        // Navigate to the detail information page
                        navigateToDetailPage(snapshot.data?[index]);
                      },
                      child: Container(
                        width: 120.0,
                        margin: EdgeInsets.only(left: index == 0 ? 16.0 : 8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        alignment: Alignment.center,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Display item image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                snapshot.data?[index]['imageUrl'],
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Display item title behind the image
                            Positioned(
                              bottom: 8.0,
                              left: 8.0,
                              right: 8.0,
                              child: Text(
                                snapshot.data?[index]['title'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  backgroundColor: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void searchItems(String query) {}

  void navigateToDetailPage(Map<String, dynamic>? item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(item: item),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getSectionItems(String section) async {
    List<Map<String, dynamic>> items = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('section', isEqualTo: section)
          .get();

      items = await Future.wait(querySnapshot.docs.map((doc) async {
        String imagePath = doc['imagePath'];
        String imageUrl = await loadItemsImage(imagePath);

        return {
          'title': doc['title'],
          'imageUrl': imageUrl,
          'description': doc['description'],
          'duration': doc['duration'],
          'genres': doc['genres'],
          'actors': doc['actors'],
          'date': doc['date']
        };
      }).toList());
    } catch (error) {
      print('Error fetching items for $section: $error');
    }
    return items;
  }

  Future<String> loadItemsImage(String imagePath) async {
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref('$imagePath');
    try {
      String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Error loading image: $e");
      // Return a default image URL or handle the error as needed
      return 'default_image_url';
    }
  }

  String encodeSection(String section) {
    return Uri.encodeComponent(section);
  }

  Future<void> handleAddButtonPress(String section) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddingScreen(section: section),
      ),
    );
  }
}
