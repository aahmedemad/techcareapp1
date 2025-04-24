import 'package:flutter/material.dart';
import 'package:techcareapp1/notification_screen.dart';
import 'choose_screen.dart';
import 'medicine_reminder_screen.dart';
import 'setting_screen.dart';
import 'choose_clinics.dart';
import 'pharmacy_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techcareapp1/reminder_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'add_doctor_request.dart';

class HomeScreen extends StatefulWidget {
  final String pCode;

  HomeScreen({required this.pCode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String patientName = '';

  @override
  void initState() {
    super.initState();
    fetchPatientName();
    _startLiveLocationUpdates();
    _sendLocationToFirestore(widget.pCode);
  }

  Future<void> _sendLocationToFirestore(String pCode) async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .where('P-code', isEqualTo: pCode)
        .get()
        .then((query) {
      if (query.docs.isNotEmpty) {
        query.docs.first.reference.update({
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      }
    });
  }

  void fetchPatientName() async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('P-code', isEqualTo: widget.pCode)
          .where('role', isEqualTo: 'patient')
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data() as Map<String, dynamic>;
        setState(() {
          patientName = "${data['firstName']} ${data['lastName']}";
        });
      } else {
        setState(() {
          patientName = 'Unknown';
        });
      }
    } catch (e) {
      print("Error fetching name: $e");
      setState(() {
        patientName = 'Error';
      });
    }
  }
  void _startLiveLocationUpdates() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        FirebaseFirestore.instance.collection('users').where('P-code', isEqualTo: widget.pCode).get().then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            String userId = querySnapshot.docs.first.id;
            FirebaseFirestore.instance.collection('users').doc(userId).update({
              'latitude': position.latitude,
              'longitude': position.longitude,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160),
        child: Container(
          color: Color(0xFF2260FF),
          child: Column(
            children: [
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage('images/image 32.jpg'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, Welcome Back",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(height: 5),
                            Text(
                             patientName.isEmpty ? "Loading... " : patientName,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "P-Code: ${widget.pCode}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('images/image 11.jpg'),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Patient",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            GestureDetector(
                              onTap:(){
                                Navigator.push(context,
                                MaterialPageRoute(builder: (context)=> ReminderScreen (pCode: widget.pCode)),);
                  },
                             child:  Icon(Icons.notifications, color: Colors.white, size: 28),
                            ),
                            SizedBox(width: 20),
                            GestureDetector(
                              onTap:(){
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (context)=> SettingsScreen()),);
                              },
                              child: Icon(Icons.settings, color: Colors.white, size: 28),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [

          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChooseScreen(pCode: widget.pCode)),
                  );
                },
                child: buildFeatureCard('images/image 28.jpg', "Enter Measurements"),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MedicineReminderScreen(pCode: widget.pCode)),
                  );
                },
                child: buildFeatureCard('images/image 29.jpg', "Medicine's Reminder"),
              ),
            ],
          ),
          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChooseClinicScreen(pCode: widget.pCode)),
                  );
                },
                child: buildFeatureCard('images/image 30.jpg', "Clinics"),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PharmacyScreen(pCode:widget.pCode)),
                  );
                },
                child: buildFeatureCard('images/image 31.jpg', "Pharmacy"),
              ),
            ],
          ),
          Spacer(),
          BottomNavigationBarWidget(pCode: widget.pCode),
        ],
      ),
    );
  }

  Widget buildFeatureCard(String imagePath, String title) {
    return Container(
      width: 160,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 95,
            height: 95,
            fit: BoxFit.cover,
          ),
          Container(
            width: 130,
            height: 45,
            decoration: BoxDecoration(
              color: Color(0x9E2260FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final String pCode;
  const BottomNavigationBarWidget({required this.pCode});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        margin: EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          color: Color(0xFF2260FF),
          borderRadius: BorderRadius.circular(35),
        ),
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen (pCode: pCode)),
                );

              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddDoctorScreen(pCode: pCode)),
                );

              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.black, size: 30),
              onPressed: () {

              },
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.black, size: 30),
              onPressed: () {

              },
            ),
          ],
        ),
      ),
    );
  }
}