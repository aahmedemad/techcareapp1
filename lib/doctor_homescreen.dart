import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'your_patients_screen.dart';
import 'clinic_screen.dart';
import 'add_patient_request.dart';
import 'setting_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  final String dCode;

  DoctorHomeScreen({required this.dCode});

  @override
  _DoctorHomeScreenState createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  String doctorName = '';

  @override
  void initState() {
    super.initState();
    fetchDoctorName();
  }

  void fetchDoctorName() async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('D-code', isEqualTo: widget.dCode)
          .where('role', isEqualTo: 'doctor')
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data() as Map<String, dynamic>;
        setState(() {
          doctorName = "${data['firstName']} ${data['lastName']}";
        });
      } else {
        setState(() {
          doctorName = 'Unknown';
        });
      }
    } catch (e) {
      print("Error fetching name: $e");
      setState(() {
        doctorName = 'Error';
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
          padding: EdgeInsets.only(top: 40, left: 20, right: 20),
          decoration: BoxDecoration(
            color: Color(0xFF09806A),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage('images/image 32.jpg'),
                      ),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, WelcomeBack",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400,),
                          ),
                          SizedBox(height: 5),
                          Text(
                            doctorName.isEmpty ? "Loading..." :" Dr./$doctorName",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                          "Doctor",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            SizedBox(height: 40,),
            _buildCategoryCard(
              context,
              'images/image 25.jpg',
              "My Patients",
                () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => YourPatientsScreen(dCode: widget.dCode)),
                );
              },
            ),
            SizedBox(height: 40),
            _buildCategoryCard(
              context,
              'images/image 30.jpg',
              "Clinic",
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClinicScreen()),
                );
              },
            ),
            Spacer(),
            BottomNavigationBarWidget(dCode: widget.dCode , doctorName: doctorName,),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String imagePath, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Image.asset(imagePath, width: 80, height: 80),
            SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Color(0xFFA0D8B3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final String dCode;
  final String doctorName;

  const BottomNavigationBarWidget({required this.dCode , required this.doctorName});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF09806A),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black, size: 30),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.black, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPatientScreen(dCode: dCode ,doctorName: doctorName,)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: Colors.black, size: 30),
            onPressed: () {
              Navigator.pushNamed(context, '/appointments');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black, size: 30),
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context)=> SettingsScreen(userRole: 'doctor',)),);
            },
          ),
        ],
      ),
    );
  }
}