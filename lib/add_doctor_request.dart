import 'package:flutter/material.dart';
import 'doctor_request_screen.dart';
import 'home_screen.dart';

class AddDoctorScreen extends StatefulWidget {
  final String pCode;

  const AddDoctorScreen ({required this.pCode});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
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
            color: Color(0xFF2260FF),
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
                        "Patient",
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
                    backgroundColor: Color(0xFF2260FF),
                    shape: StadiumBorder(),
                  ),
                  onPressed: () {}, //
                  icon: Icon(Icons.person_add,color: Colors.black,),
                  label: Text("Add Doctor",style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
                ),
                SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DoctorRequestScreen (pCode: widget.pCode)),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor:  Color(0x9E2260FF),
                  ),
                  child: Text("Requests",style: TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.w500),),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              'Enter Doctor Code:',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  hintText: 'example: D-000',
                  fillColor: Colors.blue[100],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2260FF),
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
            BottomNavigationBarWidget(pCode: widget.pCode),
          ],
        ),
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final String pCode;
  const BottomNavigationBarWidget({required this.pCode});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Color(0xFF2260FF),
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
                MaterialPageRoute(builder: (context) =>HomeScreen (pCode: pCode)),
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