// firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch data from Firestore
  Future<List<Map<String, dynamic>>> fetchData() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      
      // Extracting name, age, and email from the documents and returning as a list of maps
      List<Map<String, dynamic>> userData = [];
      snapshot.docs.forEach((doc) {
        userData.add({
          'name': doc['name'],
          'age': doc['age'],
          'email': doc['email'],
        });
      });
      return userData;  // Return the list of user data maps
    } catch (e) {
      print("Error fetching data: $e");
      return [];  // Return an empty list if there was an error
    }
  }
}
