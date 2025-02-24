import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker package
import 'dart:io'; // For File usage

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  XFile? _image; // Store the picked image

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker(); // Initialize the image picker
    final XFile? image = await picker.pickImage(source: ImageSource.gallery); // Pick image from gallery
    setState(() {
      _image = image; // Update the image
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the entire body
        child: Center(  // Center the entire column vertically
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  // Vertically center the content
            crossAxisAlignment: CrossAxisAlignment.center,  // Horizontally center the content
            children: [
              // Profile Image (taking up half of the screen height)
              Container(
                width: MediaQuery.of(context).size.width * 0.8, // Set width to 80% of the screen width
                height: MediaQuery.of(context).size.height * 0.3, // Set height to 50% of the screen height
                decoration: BoxDecoration(
                  image: _image == null
                      ? DecorationImage(
                          image: NetworkImage('https://via.placeholder.com/150'), // Default image if none picked
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: FileImage(File(_image!.path)), // Use the picked image
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(height: 20), // Space between the image and the button
              ElevatedButton(
                onPressed: _pickImage, // Trigger image picker
                child: Text('Update Profile Picture'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
