import 'package:flutter/material.dart';
import 'diabetics_screen.dart';
import 'bloodpressurepatients_screen.dart';
import 'all_patient_screen.dart';

class YourPatientsScreen extends StatelessWidget {
  final String dCode;
  YourPatientsScreen({required this.dCode});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: Color(0xFF09806A),
          leading: SizedBox.shrink(),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: ClipOval(),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 85.0),
                      child: Text(
                        "Patients",
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
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildCategoryCard(
              title: "Diabetics",
              subtitle: "You Can See All Diabetics Here.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DiabeticsScreen(dCode: dCode,)),
                );
              },
            ),
            const SizedBox(height: 30),
            buildCategoryCard(
              title: "Blood Pressure Patients",
              subtitle: "You Can See All Blood Pressure Patients Here.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BloodPressurePatientsScreen(dCode: dCode)),
                );
              },
            ),
            const SizedBox(height: 30),
            buildCategoryCard(
              title: "All Patients",
              subtitle: "You Can See All Patients Here.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllPatientsScreen(dCode: dCode)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryCard({required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 158,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFA0D8B3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 31,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Text(
                subtitle,
                style: TextStyle(fontSize: 22, color: Colors.black87, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}