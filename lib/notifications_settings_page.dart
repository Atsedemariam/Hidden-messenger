import 'package:flutter/material.dart';

class NotificationsSettingsPage extends StatefulWidget {
  @override
  _NotificationsSettingsPageState createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications Settings")),
      body: Center(
        child: SwitchListTile(
          title: Text('Enable Notifications'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
      ),
    );
  }
}
