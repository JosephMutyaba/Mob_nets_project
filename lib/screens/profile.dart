import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/screens/cart.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _user;
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    QuerySnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
        .instance
        .collection('user')
        .where('email', isEqualTo: _user.email)
        .limit(1)
        .get();

    if (userData.docs.isNotEmpty) {
      setState(() {
        _userData = userData.docs.first.data()!;
      });
    } else {
      print('User data not found');
    }
  }

  void _editProfile() {
    // Navigate to the edit profile screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userData: _userData),
      ),
    ).then((result) {
      // Handle the result if needed (e.g., updated user data)
      if (result != null) {
        _loadUserData(); // Reload user data after editing
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _userData['imageUrl'] != null
                    ? NetworkImage(_userData['imageUrl']!)
                    : const AssetImage('assets/default_profile_image.jpg')
                        as ImageProvider<Object>,
              ),
              const SizedBox(height: 16),
              Text(
                'Name: ${_userData['fname']} ${_userData['lName']}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Email: ${_userData['email']}'),
              const SizedBox(height: 8),
              Text('Age: ${_userData['age']}'),
              const SizedBox(height: 8),
              Text('Phone: ${_userData['phone']}'),
              const SizedBox(height: 8),
              Text('Address: ${_userData['address']}'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.deepPurple),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: Colors.deepPurple),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.deepPurple),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const Cart()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ProfilePage()));
          }
        },
      ),

    );
  }
}

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _fnameController;
  late TextEditingController _lNameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  late XFile _profileImage;

  @override
  void initState() {
    super.initState();
    _fnameController = TextEditingController(text: widget.userData['fname']);
    _lNameController = TextEditingController(text: widget.userData['lName']);
    _ageController =
        TextEditingController(text: widget.userData['age'].toString());
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _addressController =
        TextEditingController(text: widget.userData['address']);

    // Initialize _profileImage with the current user image URL
    _profileImage = XFile(widget.userData['imageUrl'] ?? '');
  }

  Future<void> _saveChanges() async {
    try {
      // Get the current user's email
      String currentUserEmail = FirebaseAuth.instance.currentUser!.email!;

      // Get the reference to the user's document in Firestore based on the email
      QuerySnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore
          .instance
          .collection('user')
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // Update the document with the new data
        await userSnapshot.docs.first.reference.update({
          'fname': _fnameController.text.trim(),
          'lName': _lNameController.text.trim(),
          'age': int.parse(_ageController.text.trim()),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'imageUrl': _profileImage != null
              ? await uploadImage(_profileImage!)
              : widget
                  .userData['imageUrl'], // Keep existing image if not changed
        });

        // Show a success message or handle it as needed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        // Close the screen and pass the updated data back to the previous screen
        Navigator.pop(context, true);
      } else {
        // Handle the case where user data doesn't exist
        print('User data not found');
      }
    } catch (e) {
      // Handle errors, show error message, etc.
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error updating profile. Please try again.')),
      );
    }
  }

  Future<String> uploadImage(XFile imageFile) async {
    File file = File(imageFile.path);

    final Reference ref = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${FirebaseAuth.instance.currentUser!.uid}.jpg');

    final UploadTask uploadTask = ref.putFile(file);

    final TaskSnapshot snapshot = await uploadTask;

    final String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<void> selectImage() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = pickedImage;
      });
    }
  }

  final _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: selectImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey,
                  backgroundImage: _profileImage != null
                      ? FileImage(File(_profileImage!.path))
                      : AssetImage('assets/default_profile_image.jpg')
                          as ImageProvider<Object>,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _fnameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _lNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.deepPurple),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: Colors.deepPurple),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.deepPurple),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const Cart()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ProfilePage()));
          }
        },
      ),

    );
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _lNameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
