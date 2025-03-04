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
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the column items vertically
          children: [
            Text('Well... privacy setting is not done 😐, 🔧 Under Development',
                style: TextStyle(fontSize: 20)),
            // The text is placed here
            // SizedBox(
            //     height: 20), // Add some space between the text and the switch
            // SwitchListTile(
            //   title: Text('Hide Last Seen'),
            //   value: _hideLastSeen,
            //   onChanged: (value) {
            //     setState(() {
            //       _hideLastSeen = value;
            //     });
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
