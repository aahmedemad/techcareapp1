import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPatientScreen extends StatefulWidget {
  final String sCode;
  const AddPatientScreen({super.key, required this.sCode});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final codeController = TextEditingController();
  final nameController = TextEditingController();

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
                            "Mohamed",
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                hintText: "example: P-000",
                labelText: "Enter Patient Code",
                fillColor: Color(0xFFF6DCC0),
                filled: true,
              ),
            ),
            const SizedBox(height: 50),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "example: Mohammed Ahmed",
                labelText: "Enter Patient Name",
                fillColor: Color(0xFFF6DCC0),
                filled: true,
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () async {
                String pCode = codeController.text.trim();
                String pName = nameController.text.trim();

                try {
                  QuerySnapshot patientSnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .where('P-code', isEqualTo: pCode)
                      .where('role', isEqualTo: 'patient')
                      .limit(1)
                      .get();

                  if (patientSnapshot.docs.isNotEmpty) {
                    var patientDoc = patientSnapshot.docs.first;
                    var data = patientDoc.data() as Map<String, dynamic>;
                    String fullName = "${data['firstName']} ${data['lastName']}";

                    if (fullName.toLowerCase() == pName.toLowerCase()) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(patientDoc.id)
                          .update({'S-code': widget.sCode});

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Patient Added successfully!'),
                        backgroundColor: Colors.green,
                      ));

                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Name does not match.'),
                        backgroundColor: Colors.red,
                      ));
                    }
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
              child: Text('Done'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE8883C),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}
class BottomNavigationBarWidget extends StatelessWidget {
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
            Icon(Icons.home, color: Colors.black, size: 30),

            Icon(Icons.settings, color: Colors.black, size: 30),
          ],
        ),
      ),
    );
  }
}