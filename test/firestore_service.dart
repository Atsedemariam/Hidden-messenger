import 'package:cloud_firestore/cloud_firestore.dart';

/// Function to send a message
void sendMessage(String message, String userId) {
  FirebaseFirestore.instance.collection('messages').add({
    'message': message,
    'userId': userId,
    'timestamp': FieldValue.serverTimestamp(), // Automatically add the server timestamp
  });
}

/// Function to get messages for a specific user (streaming messages)
Stream<QuerySnapshot> getMessages(String userId) {
  return FirebaseFirestore.instance
      .collection('messages')
      .where('userId', isEqualTo: userId) // Filter messages by userId
      .orderBy('timestamp', descending: true) // Order by timestamp to get most recent first
      .snapshots();
}
