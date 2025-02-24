import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String currentUserId;
  List<Map<String, dynamic>> messages = []; // Store messages with their metadata
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid; // Get current user's ID
    _loadMessages();
  }

  // Function to load messages for the current user
  void _loadMessages() async {
    FirebaseFirestore.instance
        .collection('messages')
        .where('sender_id', isEqualTo: currentUserId) // Fetch messages where the current user is the sender
        .snapshots()
        .listen((snapshot) {
      setState(() {
        if (snapshot.docs.isEmpty) {
          // No messages for the user as the sender
          messages = [];
        } else {
          messages = snapshot.docs.map((doc) {
            return {
              'message_content': doc['message_content'],
              'sender_id': doc['sender_id'],
              'timestamp': doc['timestamp'],
            };
          }).toList();
        }
      });
    });

    // Fetch messages where the current user is the receiver (if the user receives any messages)
    FirebaseFirestore.instance
        .collection('messages')
        .where('receiver_id', isEqualTo: currentUserId) // Fetch messages where the current user is the receiver
        .snapshots()
        .listen((snapshot) {
      setState(() {
        if (snapshot.docs.isNotEmpty) {
          // Combine both sender and receiver messages
          messages.addAll(snapshot.docs.map((doc) {
            return {
              'message_content': doc['message_content'],
              'sender_id': doc['sender_id'],
              'timestamp': doc['timestamp'],
            };
          }).toList());
        }
        // Sort messages by timestamp, just in case
        messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
        isLoading = false;
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
            Navigator.pop(context);
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
                  ? Center(child: CircularProgressIndicator())
                  : messages.isEmpty
                      ? Center(
                          child: Text(
                            'You have no messages.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
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
