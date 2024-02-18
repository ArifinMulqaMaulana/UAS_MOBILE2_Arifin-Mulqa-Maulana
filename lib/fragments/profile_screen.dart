import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:uas_pm2/profile_items_screen/download_screen.dart';
import 'package:uas_pm2/profile_items_screen/favorites_screen.dart';
import 'package:uas_pm2/profile_items_screen/manage_account_screen.dart';
import 'package:uas_pm2/profile_items_screen/notification_screen.dart';
import 'package:uas_pm2/profile_items_screen/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final File? profileImage;

  ProfileScreen({Key? key, this.profileImage}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  Uint8List? _profileImage;

  Future<void> loadProfileData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      await loadProfileImage();
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

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.email),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_profileImage != null)
            Card(
              elevation: 4.0,
              color: Colors.blueGrey,
              margin: EdgeInsets.all(16.0),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: MemoryImage(_profileImage!),
                ),
                title: Text('${_user?.displayName ?? "N/A"}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ManageAccountScreen()),
                  );
                },
              ),
            ),
          Card(
            elevation: 5.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Favorites'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesScreen()),
                );
              },
            ),
          ),
          Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: Icon(Icons.file_download),
              title: Text('Download'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DownloadScreen()),
                );
              },
            ),
          ),
          Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Manage Account'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ManageAccountScreen()),
                );
              },
            ),
          ),
          Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
