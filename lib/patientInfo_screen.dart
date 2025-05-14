import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PatientInfoScreen extends StatefulWidget {
  final Map<String, dynamic> patient;
  final String dCode;

  const PatientInfoScreen({
    required this.patient,
    required this.dCode,
    Key? key,
  }) : super(key: key);

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  late String pCode;
  DateTime selectedDate = DateTime.now();
  int firstValue = 0;
  int secondValue = 0;
  String selectedDayLabel = "Today";

  @override
  void initState() {
    super.initState();
    pCode = widget.patient['P-code'];
    fetchMeasurements();
  }

  void _changeDay(bool next) {
    setState(() {
      if (next) {
        selectedDate = selectedDate.add(Duration(days: 1));
      } else {
        selectedDate = selectedDate.subtract(Duration(days: 1));
      }
      selectedDayLabel = _getLabelForDate(selectedDate);
    });
    fetchMeasurements();
  }

  String _getLabelForDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return "Today";
    if (target == today.subtract(Duration(days: 1))) return "Yesterday";
    return DateFormat('d MMMM yyyy').format(target);
  }

  Future<void> _showCalendarDialog() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedDayLabel = _getLabelForDate(selectedDate);
      });
      fetchMeasurements();
    }
  }

  Future<void> fetchMeasurements() async {
    final targetDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    final snapshot = await FirebaseFirestore.instance
        .collection('Sugar Measurements')
        .doc(pCode)
        .collection('BloodSugarReadings')
        .where('timestamp', isGreaterThanOrEqualTo: targetDay)
        .where('timestamp', isLessThan: targetDay.add(Duration(days: 1)))
        .orderBy('timestamp', descending: true)
        .get();

    QueryDocumentSnapshot? firstReading;
    QueryDocumentSnapshot? secondReading;

    try {
      firstReading = snapshot.docs.firstWhere((doc) => doc['measurement']['type'] == 'first');
    } catch (_) {}

    try {
      secondReading = snapshot.docs.firstWhere((doc) => doc['measurement']['type'] == 'second');
    } catch (_) {}

    setState(() {
      firstValue = firstReading != null ? firstReading['measurement']['value'] : 0;
      secondValue = secondReading != null ? secondReading['measurement']['value'] : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // بيانات المريض
            Card(
              color:Color(0xFFA0D8B3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Table(
                border: TableBorder.all(color: Colors.grey[300]!),
                children: [
                  tableRow("Code", pCode, "Age", patient["age"] ?? "N/A"),
                  tableRow("Mobile No.", patient["mobile no"] ?? "N/A", "E-Mail", patient["email"] ?? "N/A"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF09806A)),
                  onPressed: () => _changeDay(false),
                ),
                Text(
                  selectedDayLabel,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF09806A)),
                  onPressed: () => _changeDay(true),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Color(0xFF09806A), size: 20),
                  onPressed: _showCalendarDialog,
                ),
              ],
            ),
            const Text("Medical Info", style: sectionTitleStyle),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: const Text("Status:"),
                trailing: Icon(Icons.flag, color: patient["statusColor"] ?? Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            measurementCard("1st Measurement", firstValue),
            measurementCard("2nd Measurement", secondValue),
            const Spacer(),
            Center(child: ElevatedButton(
              onPressed: () async {
                final firestore = FirebaseFirestore.instance;
                try {
                  final snapshot = await firestore
                      .collection('doctor_patients')
                      .where('D-code', isEqualTo: widget.dCode)
                      .where('P-code', isEqualTo: pCode)
                      .get();

                  for (var doc in snapshot.docs) {
                    await doc.reference.delete();
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Patient removed successfully')),
                  );
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to remove patient')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Remove Patient", style: TextStyle(color: Colors.white)),
            ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static TableRow tableRow(String title1, String value1, String title2, String value2) {
    return TableRow(children: [
      tableCell(title1, value1),
      tableCell(title2, value2),
    ]);
  }

  static Widget tableCell(String title, String value) {
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

  static Widget measurementCard(String title, int value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    color:Color(0xFF09806A),
  );
}