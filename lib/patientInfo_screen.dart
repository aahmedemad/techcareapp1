import 'package:flutter/material.dart';

class PatientInfoScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientInfoScreen({required this.patient, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Patient Info',
          style: TextStyle(
            fontFamily: 'LeagueSpartan',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF09806A),
        elevation: 0,
        shape: const RoundedRectangleBorder(
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,color: Colors.white,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Color.fromRGBO(9,128,106,0.49),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person, color: Colors.black),
                  backgroundColor: Colors.white,
                ),
                title: Text(
                  patient["name"] ?? "Unknown",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text("Personal Info", style: sectionTitleStyle),
            const SizedBox(height: 5),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Table(
                border: TableBorder.all(color: Colors.grey[300]!),
                children: [
                  tableRow("Code", patient["code"] ?? "N/A", "Age", (patient["age"] ?? "N/A").toString()),
                  tableRow("Mobile No.", patient["mobile"] ?? "N/A", "E-Mail", patient["email"] ?? "N/A"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text("Medical Info", style: sectionTitleStyle),
            const SizedBox(height: 5),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: const Text("Status:"),
                trailing: Icon(Icons.flag, color: patient["statusColor"] ?? Colors.grey),
              ),
            ),

            const SizedBox(height: 10),

            measurementCard("1st Measurement", patient["measurements"] != null && patient["measurements"].length > 0 ? patient["measurements"][0] : 0),
            measurementCard("2nd Measurement", patient["measurements"] != null && patient["measurements"].length > 1 ? patient["measurements"][1] : 0),
          ],
        ),
      ),
    );
  }

  TableRow tableRow(String title1, String value1, String title2, String value2) {
    return TableRow(children: [
      tableCell(title1, value1),
      tableCell(title2, value2),
    ]);
  }

  Widget tableCell(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget measurementCard(String title, int value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(title),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: value > 120 ? Colors.red[100] : Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "$value Mg/DL",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: value > 120 ? Colors.red : Colors.green,
            ),
          ),
        ),
      ),
    );
  }

  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
}