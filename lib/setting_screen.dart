import 'package:flutter/material.dart';
import 'notification_screen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(color: Color(0xFF2260FF), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color:Color(0xFF2260FF)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.notifications, color:Color(0xFF2260FF)),
            title: Text("Notification Setting"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationSettingScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.key, color:Color(0xFF2260FF)),
            title: Text("Password Manager"),
            onTap: () {
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color:Color(0xFF2260FF)),
            title: Text("Delete Account"),
            onTap: () {
            },
          ),
        ],
      ),
    );
  }
}