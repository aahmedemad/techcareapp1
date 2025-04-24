import 'package:flutter/material.dart';
import 'prescription_view_screen.dart';
import 'order_method_screen.dart';

class ChooseFarmacyScreen extends StatelessWidget {
  final String pCode;
  final Map<String, dynamic> prescriptionData;

  const ChooseFarmacyScreen({required this.pCode, required this.prescriptionData});

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
                      fit: BoxFit.cover, //
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (context) => PrescriptionViewScreen (pCode: pCode)),
                              (Route<dynamic> route) => false,);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50.0),
                      child: Text(
                        "Choose Pharmacy",
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
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Padding(
              padding: EdgeInsets.symmetric(horizontal:20,vertical:30),
              child:Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Available Pharmacies:",
                  style:TextStyle(fontSize:26,  fontWeight: FontWeight.w500),
                ),
              ),
            ),

            //
            ClinicCard(
              logoPath: "images/image 37.png",
              clinicName: "El Ezaby",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>OrderMethodScreen (pCode: pCode,
                    selectedPharmacy: "El Ezaby",
                    prescriptionData: prescriptionData,
                  )),
                );

              },
            ),



            SizedBox(height: 50),

            ClinicCard(
              logoPath: "images/image 38.png",
              clinicName: "Seif Pharmacy",

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>OrderMethodScreen (pCode: pCode,
                  selectedPharmacy: "Seif Pharmacy",
                  prescriptionData: prescriptionData,
                  )),
                );

              },
            ),

            SizedBox(height: 50),

            ClinicCard(
              logoPath: "images/image 39.png",
              clinicName: "Sally Pharmacy",

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>OrderMethodScreen (pCode: pCode,
                    selectedPharmacy: "Sally Pharmacy",
                    prescriptionData: prescriptionData,)),
                );

              },
            ),
          ],
        ),

      ),
    );
  }
}

class ClinicCard extends StatelessWidget {
  final String logoPath;
  final String clinicName;
  final VoidCallback onTap;

  ClinicCard({required this.logoPath, required this.clinicName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:  Color(0xFFCAD6FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(

          children: [
            Image.asset(logoPath, width: 40, height: 40),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                clinicName,
                style:TextStyle(fontSize:26,  fontWeight: FontWeight.w500,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}