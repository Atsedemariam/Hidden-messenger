// profile_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileProvider with ChangeNotifier {
  String _profileName = 'Atsed B.';
  String _profileEmail = 'atsedemarian@tern.is';
  String _profileImageUrl = 'https://via.placeholder.com/150';

  String get profileName => _profileName;
  String get profileEmail => _profileEmail;
  String get profileImageUrl => _profileImageUrl;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Load profile data from Firestore
  Future<void> loadProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await _firestore.collection('profiles').doc(user.uid).get();
      if (doc.exists) {
        _profileName = doc['name'] ?? 'Anonymous';
        _profileEmail = user.email ?? '';
        _profileImageUrl = doc['profileImageUrl'] ?? _profileImageUrl;
      }
      notifyListeners();
    }
  }

  // Update profile image
  Future<void> updateProfile(String name, String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('profiles').doc(user.uid).set({
        'name': name,
        'profileImageUrl': imageUrl,
      });
      _profileName = name;
      _profileImageUrl = imageUrl;
      notifyListeners();
    }
  }
}
