import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'main.dart'; // Import the home page where you want to go after login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Login logic
  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        // Attempt to sign in the user with email and password
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Fetch the username from Firestore using the user's email
        String username = await _getUsernameFromFirestore(email);
        
        // After successful login, navigate to HomePage and pass the username
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(username: username)),
        );
      } on FirebaseAuthException catch (e) {
        // Detailed error handling
        String errorMessage = 'Failed to log in: ${e.message}';

        if (e.code == 'user-not-found') {
          errorMessage = 'No account found with this email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password.';
        } else {
          errorMessage = 'Login failed: ${e.code} - ${e.message}';
        }

        print('Firebase Auth Error: ${e.code} - ${e.message}'); // Print error to console
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } else {
      // Handle empty email or password
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both email and password.')),
      );
    }
  }

  Future<String> _getUsernameFromFirestore(String email) async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();

      if (userDoc.exists) {
        return userDoc['username'] ?? 'Unknown User';
      } else {
        return 'No username found';
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return 'Error fetching username';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Email input field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 8),
            
            // Password input field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            
            // Login button
            ElevatedButton(
              onPressed: _login,
              child: Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String username;

  HomePage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $username'),
      ),
      body: Center(
        child: Text('Welcome to your home page, $username!'),
      ),
    );
  }
}
