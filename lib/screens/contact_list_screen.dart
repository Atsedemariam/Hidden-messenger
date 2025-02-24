import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ContactListScreen extends StatelessWidget {
  // Simulated contact list
  final List<String> contacts = ["John", "Jane", "Paul", "Alice"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts')),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(contacts[index]),
            onTap: () {
              // Navigate to chat screen for the selected contact
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(contactName: contacts[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
