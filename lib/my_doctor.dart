import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_doctor_request.dart';

class MyDoctorScreen extends StatelessWidget {
  final String pCode;
  final String patientName;

  const MyDoctorScreen({required this.pCode ,required this.patientName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('doctor_patients')
            .where('P-code', isEqualTo: pCode)
            .limit(1)
            .get(),
        builder: (context, patientSnapshot) {
          if (patientSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!patientSnapshot.hasData || patientSnapshot.data!.docs.isEmpty) {
            return Center(child: Text('No doctor assigned yet.'));
          }

          var doctorData = patientSnapshot.data!.docs.first;
          String dCode = doctorData['D-code'];

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .where('D-code', isEqualTo: dCode)
                .limit(1)
                .get(),
            builder: (context, doctorSnapshot) {
              if (doctorSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!doctorSnapshot.hasData || doctorSnapshot.data!.docs.isEmpty) {
                return Center(child: Text('No doctor details available.'));
              }

              var doc = doctorSnapshot.data!.docs.first;
              String doctorName = '${doc['firstName']} ${doc['lastName']}';
              String mobile = doc['mobileNumber'];
              String email = doc['email'];
              String code = doc['D-code'];

              return SafeArea(
                child: SingleChildScrollView(
                child:Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(50),
                      ),
                    ),
                    padding: EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
                    child: Column(
                      children: [
                        Text(
                          'Connect With Your Doctor For Easier\nFollow-Ups, Prescriptions, And Care.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w400),
                        ),
                        SizedBox(height: 20),
                        Text(
                          " Dr. $doctorName",
                          style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundImage: AssetImage('images/image 32.jpg'),
                              ),
                            ),
                            SizedBox(width: 30),
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child:GestureDetector(
                                onTap: () async {
                                  final Uri phoneUri = Uri(scheme: 'tel', path: mobile);
                                  if (await canLaunchUrl(phoneUri)) {
                                    await launchUrl(phoneUri);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Cannot make a call')),
                                    );
                                  }
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: AssetImage('images/image 44.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                    child: Column(
                      children: [
                        LabelValueRow(label: 'Number', value: mobile),
                        LabelValueRow(label: 'Email', value: email),
                        LabelValueRow(label: 'Code', value: code),
                        LabelValueRow(label: 'Clinic', value: 'El Ebrashy Clinic'),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: Center(
                            child:ElevatedButton(
                              onPressed: () async {
                                bool confirmed = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Confirm'),
                                    content: Text('Are you sure you want to remove your doctor?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: Text('Remove'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed) {
                                  await FirebaseFirestore.instance
                                      .collection('doctor_patients')
                                      .where('P-code', isEqualTo: pCode)
                                      .get()
                                      .then((snapshot) {
                                    for (var doc in snapshot.docs) {
                                      doc.reference.delete();
                                    }
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Doctor removed successfully')),
                                  );

                                  // يمكنك الرجوع للشاشة السابقة أو تحديث الواجهة
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(horizontal: 24.0 ,vertical: 14.0 ,),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text('Remove Doctor', style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Colors.white)),
                            ),
                          ),
                        ),
                      ],

                    ),
                  ),
                ],
              ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 0.0), // رفع الـ BottomNavigationBar
        child: BottomNavigationBarWidget(pCode: pCode ,patientName: patientName,),
      ),
    );
  }
}

class LabelValueRow extends StatelessWidget {
  final String label;
  final String value;

  const LabelValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              label,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 28,fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final String pCode;
  final String patientName;

  const BottomNavigationBarWidget({required this.pCode , required this.patientName});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Container(
          margin: EdgeInsets.only(bottom: 25),
          decoration: BoxDecoration(
            color: Color(0xFF2260FF),
            borderRadius: BorderRadius.circular(35),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.black, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(pCode: pCode)),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.black, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>AddDoctorScreen (pCode: pCode, patientName:patientName )),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.black, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyDoctorScreen(pCode: pCode , patientName:patientName)),
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
        )
    );
  }
}