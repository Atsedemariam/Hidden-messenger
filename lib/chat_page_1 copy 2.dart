import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String currentUserId;
  late String userId; // To store the user_id from the 'users' collection
  List<Map<String, dynamic>> messages = []; // Store messages with their metadata
  bool isLoading = true;
  bool hasError = false;  // To track if there is an error fetching data

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid; // Get current user's ID
    debugPrint("Current User ID: $currentUserId");  // Debugging log for currentUserId
    _fetchUserId();
  }

  // Function to fetch the user_id from the users collection based on currentUserId
  void _fetchUserId() async {
    try {
      // Fetch the user document where the firebase_uid matches the currentUserId
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('firebase_uid', isEqualTo: currentUserId) // Assuming you have a 'firebase_uid' field
          .get();

      if (userDoc.docs.isNotEmpty) {
        // Assuming one document for each user
        userId = userDoc.docs.first['user_id'];  // Get the user_id from the document
        debugPrint("Fetched User ID from users collection: $userId");

        // Now that we have the userId, load messages
        _loadMessages();
      } else {
        debugPrint("User not found in users collection.");
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      debugPrint("Error fetching user ID: $e");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  // Function to load messages for the current user
  void _loadMessages() async {
    debugPrint("Fetching messages where receiver_id is: $userId");

    try {
      // Fetch messages where the receiver_id matches the userId
      FirebaseFirestore.instance
          .collection('messages')
          .where('receiver_id', isEqualTo: userId) // Fetch messages where the receiver_id matches userId
          .snapshots()
          .listen((receiverSnapshot) {
        debugPrint("Receiver Snapshot: ${receiverSnapshot.docs.length} messages found.");

        setState(() {
          if (receiverSnapshot.docs.isEmpty) {
            debugPrint("No messages found for receiver_id: $userId");
            messages = []; // No messages found for current user as receiver
          } else {
            debugPrint("Messages found for receiver_id: $userId");

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
          isLoading = false;  // Set loading to false once data is loaded
        });
      });
    } catch (e) {
      debugPrint("Error loading messages: $e");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
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
                  : hasError
                      ? Center(
                          child: Text(
                            'Something went wrong. Please try again.',
                            style: TextStyle(fontSize: 18, color: Colors.red),
                          ),
                        )
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
