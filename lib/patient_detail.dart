import 'package:flutter/material.dart';
import 'shadow_homescreen.dart';
import 'medicine_check.dart';
import 'measurements_shadow.dart';
import 'tracking_screen.dart';



class PatientDetailScreen extends StatelessWidget {
  final String patientName;
  final String sCode;
  final String pCode;


  const PatientDetailScreen ({required this.sCode,super.key, required this.patientName, required this.pCode});

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
                color: Color(0xFFF5CDAD),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: Color(0xFFE8883C),
          leading: SizedBox.shrink(),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
          IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) => ShadowHomeScreen (sCode: sCode)),
                  (Route<dynamic> route) => false,);
          },
        ),
             Padding(
                padding: const EdgeInsets.only(left: 50.0),
                child: Text(
                  "$patientName",
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
        padding: const EdgeInsets.all(16.0),
        child: ListView(
        //  crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 0),
            _buildCategoryCard(
              context,
              'images/image 29.jpg',
              "Medicine Check",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MedicineCheckScreen (pCode: pCode,)),
                    );

              },
            ),
            SizedBox(height: 25,),
            _buildCategoryCard(
              context,
              'images/image 28.jpg',
              "Measurements",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MeasurementsScreen (pCode: pCode,)),
                    );

              },
            ),
            SizedBox(height: 25,),
            _buildCategoryCard(
              context,
              'images/image 8.jpg',
              "Tracking",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TrackingScreen (pCode: pCode)),
                    );

              },
            ),
          ],
        ),
      ),
    );
  }
}