import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String currentUserId;
  late String currentUserEmail;
  List<Map<String, dynamic>> filteredUsers = []; // List of filtered users (excluding current user)
  List<Map<String, dynamic>> messages = []; // Store messages with their metadata
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentUserEmail = FirebaseAuth.instance.currentUser!.email ?? '';  // Get current user's email
    debugPrint("Current User Email: $currentUserEmail");  // Debugging log for currentUserEmail

    // Fetch the current user's data from the 'users' collection
    _loadUsers();
  }

  // Function to load and filter users based on the current user's email
  void _loadUsers() async {
    try {
      var usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

      // Filter out the current user based on email
      var users = usersSnapshot.docs.map((doc) => doc.data()).toList();
      filteredUsers = users.where((userDoc) {
        return userDoc['email'] != currentUserEmail;  // Exclude the current user's email
      }).toList();

      // Get the current user's user_id
      var currentUserDoc = usersSnapshot.docs.firstWhere(
        (doc) => doc['email'] == currentUserEmail,
        orElse: () => throw Exception("User not found"),
      );

      currentUserId = currentUserDoc['user_id'];  // Get the user_id from the current user's document
      debugPrint("Current User ID: $currentUserId");

      // Load messages for the current user
      _loadMessages();

      setState(() {
        isLoading = false;  // Set loading to false once data is loaded
      });

    } catch (e) {
      debugPrint("Error fetching users: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to load messages for the current user
  void _loadMessages() async {
    debugPrint("Fetching messages where receiver_id is: $currentUserId");

    // Fetch messages where the current user is the receiver
    FirebaseFirestore.instance
        .collection('messages')
        .where('receiver_id', isEqualTo: currentUserId) // Fetch messages where the current user is the receiver
        .snapshots()
        .listen((receiverSnapshot) {
      debugPrint("Receiver Snapshot: ${receiverSnapshot.docs.length} messages found.");

      setState(() {
        if (receiverSnapshot.docs.isEmpty) {
          debugPrint("No messages found for receiver_id: $currentUserId");
          messages = []; // No messages found for current user as receiver
        } else {
          debugPrint("Messages found for receiver_id: $currentUserId");

          messages = receiverSnapshot.docs.map((doc) {
            var timestamp = doc['timestamp'];

            // Handle timestamp properly
            if (timestamp is Timestamp) {
              return {
                'message_content': doc['message_content'],
                'sender_id': doc['sender_id'],
                'receiver_id': doc['receiver_id'],
                'timestamp': timestamp.toDate(),  // Convert Firestore Timestamp to DateTime
              };
            } else {
              return {
                'message_content': doc['message_content'],
                'sender_id': doc['sender_id'],
                'receiver_id': doc['receiver_id'],
                'timestamp': DateTime.now(),  // Default timestamp if no timestamp exists
              };
            }
          }).toList();
        }

        // Sort messages by timestamp (ascending order)
        messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Your Messages'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator()) // Loading indicator while fetching data
                  : messages.isEmpty
                      ? Center(
                          child: Text(
                            'You have no messages.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ) // Message when no messages are found
                      : ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            var message = messages[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  message['message_content'],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
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
