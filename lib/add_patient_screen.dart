import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shadow_homescreen.dart';
import 'setting_screen.dart';

class AddPatientScreen extends StatefulWidget {
  final String sCode;
  final String shadowName;
  const AddPatientScreen({super.key, required this.sCode,required this.shadowName,});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final codeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160),
        child: Container(
          padding: EdgeInsets.only(top: 40, left: 20, right: 20),
          decoration: BoxDecoration(
            color: Color(0xFFE8883C),
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
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400,),
                          ),
                          SizedBox(height: 5),
                          Text(
                            widget.shadowName.isEmpty ? "Loading..." : widget.shadowName,
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
                          "Shadow",
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
        padding: const EdgeInsets.only(top: 50,left: 16,right: 35),

        child: Column(

          children: [
           Align(
             alignment: Alignment.centerLeft,
             child:  Text("Enter Patient Code:",
               style: TextStyle(
                 color: Colors.black,
                 fontSize: 32,
                 fontWeight: FontWeight.w400,
               ),
               ),
           ),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                hintText: "example: P005",
                fillColor: Color(0xFFF6DCC0),
                filled: true,
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () async {
                String pCode = codeController.text.trim();

                try {
                  QuerySnapshot patientSnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .where('P-code', isEqualTo: pCode)
                      .where('role', isEqualTo: 'patient')
                      .limit(1)
                      .get();

                  if (patientSnapshot.docs.isNotEmpty) {
                    var patientDoc = patientSnapshot.docs.first;

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(patientDoc.id)
                        .update({'S-code': widget.sCode});

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Patient added successfully!'),
                      backgroundColor: Colors.green,
                    ));

                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Patient not found.'),
                      backgroundColor: Colors.red,
                    ));
                  }
                } catch (e) {
                  print("Error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('An error occurred.'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Text('Done', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26,),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE8883C),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(sCode: widget.sCode),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final String sCode;
  const BottomNavigationBarWidget({required this.sCode});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Color(0xFFE8883C),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShadowHomeScreen(sCode: sCode)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=> SettingsScreen(userRole: 'shadow',)),);
              },
            ),
          ],
        ),
      ),
    );
  }
}