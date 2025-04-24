import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'SeeMySchedule_screen.dart';

class ClinicScreen extends StatefulWidget {
  @override
  _ClinicScreenState createState() => _ClinicScreenState();
}

class _ClinicScreenState extends State<ClinicScreen> {
  List<Map<String, String>> patientVisits = [];

  @override
  void initState() {
    super.initState();
    fetchPatientVisits();
  }

  Future<void> fetchPatientVisits() async {
    final visitsSnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .doc('P001')
        .collection('visits')
        .get();

    List<Map<String, String>> loadedPatients = [];

    for (var doc in visitsSnapshot.docs) {
      final data = doc.data();
      final pcode = data['pCode'] ?? '';
      final time = data['time'] ?? '';
      final status = data['status'] ?? '';

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('P-code', isEqualTo: pcode)
          .limit(1)
          .get();

      String fullName = 'Unknown';
      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        final firstName = userData['firstName'] ?? '';
        final lastName = userData['lastName'] ?? '';
        fullName = '$firstName $lastName';
      }

      loadedPatients.add({
        'time': time,
        'name': fullName,
        'status': status,
      });
    }

    setState(() {
      patientVisits = loadedPatients;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: Color(0xFF09806A),
          leading: SizedBox.shrink(),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 100.0),
                      child: Text(
                        "Clinic",
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
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Patients",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeeMyScheduleScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "See My Schedule",
                    style: TextStyle(color: Color(0xFF09806A), fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: patientVisits.length,
                itemBuilder: (context, index) {
                  final patient = patientVisits[index];
                  return _buildPatientCard(
                    patient['time']!,
                    patient['name']!,
                    patient['status']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(String time, String name, String status) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(width: 15),
          Icon(Icons.person, size: 30, color: Colors.black54),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  status,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          Icon(Icons.chat_bubble_outline, size: 24, color: Colors.black54),
        ],
      ),
    );
  }
}