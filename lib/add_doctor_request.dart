import 'package:flutter/material.dart';
import 'doctor_request_screen.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_doctor.dart';

class AddDoctorScreen extends StatefulWidget {
  final String pCode;
  final String patientName;

  const AddDoctorScreen ({required this.pCode , required this.patientName});

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
                            widget.patientName,
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
      body: SafeArea(
        child:SingleChildScrollView(
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
                      MaterialPageRoute(builder: (context) => DoctorRequestScreen (pCode: widget.pCode , patientName:widget.patientName ,)),
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
              onPressed: () async {
                String dCode = _codeController.text.trim();

                if (dCode.isEmpty) return;

                // 1. التحقق من وجود طلب جاري أو دكتور مقبول
                final existingAccepted = await FirebaseFirestore.instance
                    .collection('doctor_requests')
                    .where('P-code', isEqualTo: widget.pCode)
                    .where('status', isEqualTo: 'accepted')
                    .get();

// لو في طلب مقبول حاليًا، امنع الإرسال
                if (existingAccepted.docs.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You already have a doctor.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

// امسح أي طلبات معلقة قبل إرسال الجديد
                final existingPending = await FirebaseFirestore.instance
                    .collection('doctor_requests')
                    .where('P-code', isEqualTo: widget.pCode)
                    .where('status', isEqualTo: 'pending')
                    .get();

                for (var doc in existingPending.docs) {
                  await doc.reference.delete();
                }

// الآن أرسل الطلب الجديد
                await FirebaseFirestore.instance
                    .collection('doctor_requests')
                    .add({
                  'D-code': dCode,
                  'P-code': widget.pCode,
                  'patientName': widget.patientName,
                  'status': 'pending',
                  'timestamp': FieldValue.serverTimestamp(),
                });

                // 2. إرسال الطلب الجديد
                await FirebaseFirestore.instance
                    .collection('doctor_requests')
                    .add({
                  'D-code': dCode,
                  'P-code': widget.pCode,
                  'patientName': widget.patientName,
                  'status': 'pending',
                  'timestamp': FieldValue.serverTimestamp(),
                });
                setState(() {
                  requestSent = true;
                  _codeController.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Request Sent Successfully'),
                      backgroundColor: Colors.green,
                    )
                );
              },
              child: Text("Send Request",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
            ),


            SizedBox(height: 20),
            SizedBox(height: 245,),
            BottomNavigationBarWidget(pCode: widget.pCode, patientName: widget.patientName,),
          ],
        ),
      ),
      )
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final String pCode;
  final String patientName;
  const BottomNavigationBarWidget({required this.pCode , required this.patientName});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Color(0xFF2260FF),
        borderRadius: BorderRadius.circular(37),
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
            icon: Icon(Icons.person, color: Colors.black, size: 30),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyDoctorScreen (pCode: pCode , patientName:patientName)),
              );
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