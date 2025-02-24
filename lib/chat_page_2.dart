import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage_2 extends StatefulWidget {
  final String userName; // Username to display at the top of the chat screen
  final String userImageUrl; // User's profile picture URL
  final String receiverId; // Receiver ID for messaging

  ChatPage_2({
    required this.userName,
    required this.userImageUrl,
    required this.receiverId,
  });

  @override
  _ChatPage_2State createState() => _ChatPage_2State();
}

class _ChatPage_2State extends State<ChatPage_2> {
  TextEditingController _controller = TextEditingController();
  late String currentUserId;
  late String receiverUserId;
  String? conversationId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    receiverUserId = widget.receiverId; // Ensure the receiverId is passed correctly

    if (receiverUserId.isNotEmpty) {
      // Generate a unique conversation ID based on both user IDs
      conversationId = _generateConversationId(currentUserId, receiverUserId);
    } else {
      // Handle case when receiverUserId is not set properly
      throw Exception("Receiver ID is not provided");
    }
  }

  // Generate a unique conversation ID (ensures it's the same for both user1-user2 and user2-user1)
  String _generateConversationId(String userId1, String userId2) {
    if (userId1.compareTo(userId2) < 0) {
      return '$userId1-$userId2';
    } else {
      return '$userId2-$userId1';
    }
  }

  // Send message to Firestore
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final message = {
        'sender_id': currentUserId,
        'receiver_id': receiverUserId,
        'message_content': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
        'message_type': 'text', // Set message type (text, image, etc.)
        'status': 'sent',  // Initial status of the message
        'is_deleted': false,
        'conversation_id': conversationId, // Use unique conversation ID
      };

      // Add message to Firestore
      await FirebaseFirestore.instance.collection('messages').add(message);

      _controller.clear(); // Clear the input field after sending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.userImageUrl),
            ),
            SizedBox(width: 10),
            Text(widget.userName),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: Column(
        children: [
          // Real-time message list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('conversation_id', isEqualTo: conversationId) // Only fetch messages for the specific conversation
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index].data() as Map<String, dynamic>;
                    String message = messageData['message_content'] ?? '';
                    return MessageBubble(message: message);
                  },
                );
              },
            ),
          ),
          // Input field for new message
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Type a message..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;

  MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
