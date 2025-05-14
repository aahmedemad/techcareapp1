import 'package:flutter/material.dart';
import 'patient_request_screen.dart';
import 'doctor_homescreen.dart';

class AddPatientScreen extends StatefulWidget {
  final String dCode;
  final String doctorName;

  const AddPatientScreen ({required this.dCode ,required this.doctorName});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool requestSent = false;

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
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Dr./${widget.doctorName}",
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
                  onPressed: () {}, //
                  icon: Icon(Icons.person_add,color: Colors.black,),
                  label: Text("Add Patient",style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
                ),
                SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PatientRequestsScreen (dCode: widget.dCode ,doctorName: widget.doctorName,)),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor:  Color(0xFFA0D8B3),
                  ),
                  child: Text("Requests",style: TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.w500),),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              'Enter Patient Code:',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  hintText: 'example: P-000',
                  fillColor:  Color(0xFFA0D8B3),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF09806A),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {
                setState(() {
                  requestSent = true;
                });
              },
              child: Text("Send Request",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
            ),
            SizedBox(height: 20),
            if (requestSent)
              Text(
                'Request Sent Successfully',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            Spacer(),
            BottomNavigationBarWidget(dCode: widget.dCode),
          ],
        ),
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final String dCode;
  const BottomNavigationBarWidget({required this.dCode});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Color(0xFF09806A),
        borderRadius: BorderRadius.circular(30),
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
    );
  }
}