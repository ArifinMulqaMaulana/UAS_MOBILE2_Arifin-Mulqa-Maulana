import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        primary: backgroundColor,
        onPrimary: Colors.white,
        shape: CircleBorder(),
      ),
      child: Icon(icon),
    );
  }
}

class ExploreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 12.0),
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
            const SizedBox(height: 16.0),
            // Genres Section
            buildGenresSection(),
            const SizedBox(height: 16.0),
            // Actors Section
            buildActorsSection(),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget buildGenresSection() {
    return Container(
      height: 40.0,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Text(
              'Error fetching genres',
              style: TextStyle(color: Colors.red),
            );
          }

          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<String> genres = [];
          for (var doc in snapshot.data!.docs) {
            if (doc['genres'] != null) {
              genres.addAll((doc['genres'] as List<dynamic>).cast<String>());
            }
          }
          genres = genres.toSet().toList();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: genres.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.only(left: index == 0 ? 16.0 : 8.0),
                child: Chip(
                  label: Text(
                    genres[index],
                    style: TextStyle(
                        color: const Color.fromARGB(255, 214, 113, 232)),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildActorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            'Actors',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color:
                  const Color.fromARGB(255, 214, 113, 232), // Change text color
            ),
          ),
        ),
        Container(
          height: 150.0,
          child: Row(
            children: [
              // Actor 1
              buildActorCard(
                'https://firebasestorage.googleapis.com/v0/b/uaspm2.appspot.com/o/actors_image%2FHan%20So-hee.jpg?alt=media&token=e0362364-e6f2-41da-a4b7-159325b49ffc',
                'Han So-hee',
              ),
              // Actor 2
              buildActorCard(
                'https://firebasestorage.googleapis.com/v0/b/uaspm2.appspot.com/o/actors_image%2FIU.jpeg?alt=media&token=f1e6b524-c95b-49ca-accd-7bd56879ff98',
                'IU',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildActorCard(String imageUrl, String actorName) {
    return Container(
      width: 120.0,
      margin: EdgeInsets.only(left: 16.0),
      child: Stack(
        children: [
          // Actor Image
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10.0),
            ),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Actor Name
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
              child: Text(
                actorName,
                style: TextStyle(color: Color.fromARGB(255, 213, 133, 227)),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
