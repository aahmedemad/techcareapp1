import 'package:flutter/material.dart';
import 'add_patient_request.dart';
import 'doctor_homescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientRequestsScreen extends StatelessWidget {
  final String dCode;
  final String doctorName;


  const PatientRequestsScreen({required this.dCode ,required this.doctorName});

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
                            "Dr./ ${doctorName}",
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddPatientScreen(dCode: dCode ,doctorName: doctorName,)),
                    );
                  },
                  icon: Icon(Icons.person_add, color: Colors.black),
                  label: Text("Add Patient", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
                ),
                SizedBox(width: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('doctor_requests')
                      .where('D-code', isEqualTo: dCode)
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
                  builder: (context, snapshot) {
                    int count = snapshot.hasData ? snapshot.data!.docs.length : 0;

                    return OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(backgroundColor: Color(0xFFA0D8B3)),
                      child: Row(
                        children: [
                          Text("Requests", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
                          SizedBox(width: 5),
                          if (count > 0)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('$count', style: TextStyle(color: Colors.white, fontSize: 14)),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('doctor_requests')
                    .where('D-code', isEqualTo: dCode)
                    .where('status', isEqualTo: 'pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No pending requests.'));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final patientName = data['patientName'] ?? 'Unknown';
                      final pCode = data['P-code'] ?? '';
                      final requestId = doc.id;

                      return _buildRequestCard(
                        context,
                        patientName: patientName,
                        pCode: pCode,
                        requestId: requestId,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(dCode: dCode ,doctorName: doctorName,),
    );
  }

  Widget _buildRequestCard(
      BuildContext context, {
        required String patientName,
        required String pCode,
        required String requestId,
      }) {
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
            Text('Patient Name: $patientName'),
            Text('P-code: $pCode'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final FirebaseFirestore firestore = FirebaseFirestore.instance;

                    try {
                      // 1. حدّث حالة الطلب إلى "accepted"
                      await firestore.collection('doctor_requests').doc(requestId).update({
                        'status': 'accepted',
                      });

                      // 2. احصل على بيانات المريض
                      QuerySnapshot patientSnapshot = await firestore
                          .collection('users')
                          .where('P-code', isEqualTo: pCode)
                          .limit(1)
                          .get();

                      if (patientSnapshot.docs.isNotEmpty) {
                        DocumentReference patientRef = patientSnapshot.docs.first.reference;

                        // 3. اربط الدكتور بالمريض (في مجموعة جديدة)
                        await firestore.collection('doctor_patients').add({
                          'D-code': dCode,
                          'P-code': pCode,
                          'patientName': patientName,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        // 4. أضف dCode إلى حقل doctors داخل المريض (لو مش موجود بالفعل)
                        await firestore.runTransaction((transaction) async {
                          DocumentSnapshot freshSnapshot = await transaction.get(patientRef);
                          List<dynamic> currentDoctors = freshSnapshot.get('doctors') ?? [];

                          if (!currentDoctors.contains(dCode)) {
                            currentDoctors.add(dCode);
                            transaction.update(patientRef, {'doctors': currentDoctors});
                          }
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Request accepted and patient linked to doctor.')),
                        );
                      }
                    } catch (e) {
                      print('Error accepting request: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Something went wrong.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF09806A),
                  ),
                  child: Text("Accept", style: TextStyle(color: Colors.black)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    // كود رفض الطلب
                    await FirebaseFirestore.instance
                        .collection('doctor_requests')
                        .doc(requestId)
                        .update({'status': 'declined'});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: Text("Decline", style: TextStyle(color: Colors.black)),
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
  final String doctorName;
  const BottomNavigationBarWidget({required this.dCode, super.key ,required this.doctorName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 29),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        margin: EdgeInsets.symmetric(horizontal: 17),
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
                  MaterialPageRoute(builder: (context) => DoctorHomeScreen(dCode: dCode)),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPatientScreen(dCode: dCode ,doctorName: doctorName,)),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.black, size: 30),
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