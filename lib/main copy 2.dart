import 'package:flutter/material.dart';
import 'add_data_page.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  // Method to clear all Firestore data from the 'users' collection
  void _clearFirestoreData(BuildContext context) async {
    try {
      // Get all documents in the 'users' collection
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();

      // Delete all documents
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All data cleared from Firestore')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear data: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: Text('Add Data'),
              onTap: () {
                // Navigate to Add Data Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddDataPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text('Users List', style: TextStyle(fontSize: 24)),
            ElevatedButton(
              onPressed: () => _clearFirestoreData(context),
              child: Text('Clear Firestore Data'),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No Data Found'));
                  }

                  final users = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final data = user.data() as Map<String, dynamic>;  // Get document data as a Map

                      final name = data['name'] ?? 'Unknown';
                      final email = data['email'] ?? 'No email';  // Safely accessing email field

                      return ListTile(
                        title: Text(name),
                        subtitle: Text('Email: $email'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
