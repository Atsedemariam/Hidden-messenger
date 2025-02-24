import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String contactName;

  ChatScreen({required this.contactName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _controller = TextEditingController();
  List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _getMessages();
  }

  // Fetch messages for the selected contact from Firestore
  void _getMessages() {
    FirebaseFirestore.instance
        .collection('messages')
        .where('userId', isEqualTo: widget.contactName)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _messages = snapshot.docs.map((doc) => doc['message'] as String).toList();
      });
    });
  }

  // Send a new message
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('messages').add({
        'message': _controller.text,
        'userId': widget.contactName,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.contactName}')),
      body: Column(
        children: [
          // Display chat messages
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(_messages[index]);
              },
            ),
          ),
          // Message input field and send button
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
