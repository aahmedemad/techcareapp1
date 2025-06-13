import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'clinic_appoi_screen.dart';
import 'home_screen.dart';

class ChooseClinicScreen extends StatelessWidget {
  final String pCode;
  final String patientName;


  const ChooseClinicScreen({required this.pCode,required this.patientName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: Color(0xFF2260FF),
          leading: SizedBox.shrink(),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: ClipOval(
                    child: Image.asset(
                      'images/image 11.jpg',
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen(pCode: pCode)),
                              (Route<dynamic> route) => false,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 75.0),
                      child: Text(
                        "Choose Clinics",
                        style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('Clinics').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final clinics = snapshot.data!.docs;

          return ListView(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Available Clinics:",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              ...clinics.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final cCode = data['C-code']?? 'No Code';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ClinicCard(
                    logoPath: data['logoPath'] ?? 'images/image 35.png',
                    clinicName: data['Name'] ?? 'Unknown Clinic',
                    cCode: data['C-code']?? 'Unknown Code',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClinicAppointmentScreen(
                            pCode: pCode,
                            clinicId: doc.id,
                            clinicName: data['Name'],
                            clinicLogo: data['logoPath'],
                            patientName: patientName,
                            cCode:cCode,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}

class ClinicCard extends StatelessWidget {
  final String logoPath;
  final String clinicName;
  final String cCode;
  final VoidCallback onTap;

  ClinicCard({required this.logoPath, required this.clinicName,required this.cCode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xFFCAD6FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.asset(logoPath, width: 40, height: 40),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                clinicName,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}