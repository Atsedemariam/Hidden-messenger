import 'package:flutter/material.dart';

class ThemeSettingsPage extends StatefulWidget {
  @override
  _ThemeSettingsPageState createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Theme Settings")),
      body: Center(
        child: SwitchListTile(
          title: Text('Dark Mode'),
          value: _isDarkMode,
          onChanged: (value) {
            setState(() {
              _isDarkMode = value;
            });
            if (_isDarkMode) {
              // Switch to dark theme
              ThemeMode.dark;
            } else {
              // Switch to light theme
              ThemeMode.light;
            }
          },
        ),
      ),
    );
  }
}
