import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pharmacy_screen.dart';
import 'choose_pharmacy_screen.dart';

class PrescriptionViewScreen extends StatelessWidget {
  final String pCode;
  const PrescriptionViewScreen({required this.pCode});

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
                      fit: BoxFit.cover,
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
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => PharmacyScreen (pCode: pCode)),
                              (Route<dynamic> route) => false,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50.0),
                      child: Text(
                        "Prescription View",
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
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('Prescriptions')
            .where('pCode', isEqualTo: pCode)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No prescription found for this code."));
          }

          final data = snapshot.data!.docs.first;
          final prescriptionData = data.data() as Map<String, dynamic>;
          final doctorName = data['doctorName'] ?? '---';
          final patientName = data['patientName'] ?? '---';
          final date = data['date'] ?? '---';
          final medicines = List<Map<String, dynamic>>.from(data['Medicines'] ?? []);

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Prescription',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F0FF),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xFF2260FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundImage: AssetImage('images/image 11.jpg'),
                                ),
                                SizedBox(width: 20),
                                Text(
                                  'TechCare Prescription',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Date: $date', style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text('Doctor Name: $doctorName', style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text('Patient Name: $patientName', style: TextStyle(fontSize: 16)),
                          SizedBox(height: 16),
                          Text('Medicine:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          ...medicines.map((medicine) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(child: Text('- ${medicine['Medicine'] ?? '---'}')),
                                SizedBox(width: 8),
                                Text('Dose: ${medicine['Dosage'] ?? '--'}'),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChooseFarmacyScreen(pCode: pCode,prescriptionData: prescriptionData,)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2260FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Send To Pharmacy',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}