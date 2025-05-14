import 'package:flutter/material.dart';
import 'notification_screen.dart';

class SettingsScreen extends StatelessWidget {
  final String userRole; // 'patient', 'doctor', 'shadow'

  SettingsScreen({required this.userRole});

  Color getBackgroundColor() {
    switch (userRole) {
      case 'doctor':
        return Colors.blue.shade50;
      case 'patient':
        return Colors.green.shade50;
      case 'shadow':
        return Colors.orange.shade50;
      default:
        return Colors.white;
    }
  }

  Color getAppBarColor() {
    switch (userRole) {
      case 'doctor':
        return Color(0xFF09806A);
      case 'patient':
        return  Color(0xFF2260FF);
      case 'shadow':
        return Color(0xFFE8883C);
      default:
        return Color(0xFF2260FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: getAppBarColor(),
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.notifications, color: getAppBarColor()),
            title: Text("Notification Setting"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationSettingScreen(userRole: userRole,)),
              );
            },
          ),
          if (userRole == 'patient') ...[
            ListTile(
              leading: Icon(Icons.local_hospital, color: getAppBarColor()),
              title: Text("My Doctors"),
              onTap: () {},
            ),
          ] else if (userRole == 'doctor') ...[
            ListTile(
              leading: Icon(Icons.calendar_today, color: getAppBarColor()),
              title: Text("Manage Appointments"),
              onTap: () {},
            ),
          ] else if (userRole == 'shadow') ...[
            ListTile(
              leading: Icon(Icons.people, color: getAppBarColor()),
              title: Text("Followed Patients"),
              onTap: () {},
            ),
          ],
          ListTile(
            leading: Icon(Icons.key, color: getAppBarColor()),
            title: Text("Password Manager"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.person, color: getAppBarColor()),
            title: Text("Delete Account"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}