import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingScreen extends StatefulWidget {
  final String userRole;

  NotificationSettingScreen({required this.userRole});

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
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      generalNotification = prefs.getBool('generalNotification') ?? true;
      sound = prefs.getBool('sound') ?? true;
      soundCall = prefs.getBool('soundCall') ?? false;
      vibrate = prefs.getBool('vibrate') ?? false;
      specialOffers = prefs.getBool('specialOffers') ?? false;
    });
  }

  void _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Color getBackgroundColor() {
    switch (widget.userRole) {
      case 'doctor':
        return Colors.white;
      case 'patient':
        return Colors.white;
      case 'shadow':
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  Color getAppBarColor() {
    switch (widget.userRole) {
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
          'Notification Setting',
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
          SwitchListTile(
            title: Text("General Notification"),
            value: generalNotification,
            activeColor: Colors.white,
            onChanged: (value) {
              setState(() {
                generalNotification = value;
              });
              _savePreference('generalNotification', value);
            },
          ),
          SwitchListTile(
            title: Text("Sound"),
            value: sound,
            activeColor: Colors.white,
            onChanged: (value) {
              setState(() {
                sound = value;
              });
              _savePreference('sound', value);
            },
          ),
          SwitchListTile(
            title: Text("Sound Call"),
            value: soundCall,
            activeColor: Colors.white,
            onChanged: (value) {
              setState(() {
                soundCall = value;
              });
              _savePreference('soundCall', value);
            },
          ),
          SwitchListTile(
            title: Text("Vibrate"),
            value: vibrate,
            activeColor: Colors.white,
            onChanged: (value) {
              setState(() {
                vibrate = value;
              });
              _savePreference('vibrate', value);
            },
          ),
          if (widget.userRole == 'patient')
            SwitchListTile(
              title: Text("Special Offers"),
              value: specialOffers,
              activeColor: getAppBarColor(),
              onChanged: (value) {
                setState(() {
                  specialOffers = value;
                });
                _savePreference('specialOffers', value);
              },
            ),
        ],
      ),
    );
  }
}