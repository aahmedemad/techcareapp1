import 'package:flutter/material.dart';
import 'add_patient_request.dart';
import 'doctor_homescreen.dart';

class PatientRequestsScreen extends StatelessWidget {
  final String dCode;

  const PatientRequestsScreen ({required this.dCode});

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
                            "Hi, Welcome Back",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Dr./Mohamed",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
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
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF09806A),
                    shape: StadiumBorder(),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddPatientScreen (dCode: dCode)),
                    );
                  },
                  icon: Icon(Icons.person_add,color:Colors.black),
                  label: Text("Add Patient",style: TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.w500)),
                ),
                SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor:  Color(0xFFA0D8B3),),
                  child: Text("Requests",style: TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  _buildRequestCard(
                    context,
                    patientName: 'Ahmed Ali',
                    patientCode: 'P005',
                  ),

                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBarWidget(dCode: dCode,),
    );
  }

  Widget _buildRequestCard(BuildContext context,
      {required String patientName, required String patientCode}) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.green[100],
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Name: $patientName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              'Patient Code: $patientCode',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    //
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF09806A),
                  ),
                  child: Text("Accept",style: TextStyle(color: Colors.white,)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: Text("Decline" ,style: TextStyle(color: Colors.white,)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final String dCode;
  const BottomNavigationBarWidget({required this.dCode, super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding :EdgeInsets.only(bottom: 29),
      child:Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      margin:  EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: Color(0xFF09806A),
        borderRadius: BorderRadius.circular(31),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.black, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>DoctorHomeScreen (dCode: dCode)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add_circle, color: Colors.black, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPatientScreen(dCode:dCode)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.calendar_month_outlined, color: Colors.black, size: 30),
            onPressed: () {
              Navigator.pushNamed(context, '/appointments');
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black, size: 30),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      ),
    );
  }
}