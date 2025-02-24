import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatefulWidget {
  @override
  _PrivacySettingsPageState createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _hideLastSeen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Privacy Settings")),
      body: Center(
        child: SwitchListTile(
          title: Text('Hide Last Seen'),
          value: _hideLastSeen,
          onChanged: (value) {
            setState(() {
              _hideLastSeen = value;
            });
          },
        ),
      ),
    );
  }
}
