import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uas_pm2/auth/login_screen.dart';
import 'package:uas_pm2/manage_acc/change_pw.dart';
import 'package:uas_pm2/manage_acc/edit_profile.dart';

class ManageAccountScreen extends StatefulWidget {
  final File? profileImage;

  ManageAccountScreen({Key? key, this.profileImage}) : super(key: key);

  @override
  _ManageAccountScreenState createState() => _ManageAccountScreenState();
}

class _ManageAccountScreenState extends State<ManageAccountScreen> {
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

  Future<void> _deleteUserData() async {
    // Delete user document from Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user?.uid)
        .delete();

    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref('profile_images/${_user!.uid}.jpg');
    await ref.delete();
  }

  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteAccount() async {
    if (_user != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Account Deletion"),
            content: Text(
                "Are you sure you want to delete your account? This action cannot be undone."),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Delete Account"),
                onPressed: () async {
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: _user!.email!,
                    password: "user_current_password_here",
                  );

                  try {
                    await _user!.reauthenticateWithCredential(credential);
                    await _deleteUserData();
                    await _user!.delete();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  } catch (error) {
                    print("Error reauthenticating: $error");
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      print("User not signed in.");
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
        title: Text('Manage Account'),
      ),
      body: Column(
        children: [
          if (_profileImage != null)
            CircleAvatar(
              radius: 50,
              backgroundImage: MemoryImage(_profileImage!),
            ),
          SizedBox(height: 18.0),
          Text(
            '${_user?.displayName ?? "N/A"}',
            style: TextStyle(fontSize: 18.0),
          ),
          Text(
            '${_user?.email ?? "N/A"}', // Display user's email
            style: TextStyle(fontSize: 16.0, color: Colors.grey),
          ),
          SizedBox(height: 24.0),
          Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              title: Text(
                'Change Password',
                style: TextStyle(fontSize: 16.0),
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Logic to navigate to the password change screen
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen()));
              },
            ),
          ),
          Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              title: Text(
                'Edit Profile',
                style: TextStyle(fontSize: 16.0),
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Logic to navigate to the profile editing screen
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditProfileScreen()));
              },
            ),
          ),
          Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              title: Text(
                'Logout',
                style: TextStyle(fontSize: 16.0),
              ),
              trailing: Icon(Icons.exit_to_app),
              onTap: () {
                _handleLogout();
              },
            ),
          ),
          Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              title: Text(
                'Delete Account',
                style: TextStyle(fontSize: 16.0, color: Colors.red),
              ),
              trailing: Icon(Icons.delete),
              onTap: () {
                _handleDeleteAccount();
              },
            ),
          ),
        ],
      ),
    );
  }
}
