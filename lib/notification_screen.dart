import 'package:flutter/material.dart';

class NotificationSettingScreen extends StatefulWidget {
  @override
  _NotificationSettingScreenState createState() => _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  bool generalNotification = true;
  bool sound = true;
  bool soundCall = false;
  bool vibrate = false;
  bool specialOffers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Notification Setting',
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
          SwitchListTile(
            title: Text("General Notification"),
            value: generalNotification,
            onChanged: (value) {
              setState(() {
                generalNotification = value;
              });
            },
          ),
          SwitchListTile(
            title: Text("Sound"),
            value: sound,
            onChanged: (value) {
              setState(() {
                sound = value;
              });
            },
          ),
          SwitchListTile(
            title: Text("Sound Call"),
            value: soundCall,
            onChanged: (value) {
              setState(() {
                soundCall = value;
              });
            },
          ),
          SwitchListTile(
            title: Text("Vibrate"),
            value: vibrate,
            onChanged: (value) {
              setState(() {
                vibrate = value;
              });
            },
          ),
          SwitchListTile(
            title: Text("Special Offers"),
            value: specialOffers,
            onChanged: (value) {
              setState(() {
                specialOffers = value;
              });
            },
          ),
        ],
      ),
    );
  }
}