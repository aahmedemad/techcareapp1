import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeasurementsScreen extends StatefulWidget {
  final String pCode;

  const MeasurementsScreen({super.key, required this.pCode});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  int firstValue = 0;
  int secondValue = 0;
  DateTime selectedDate = DateTime.now();
  String selectedDayLabel = "Today";

  @override
  void initState() {
    super.initState();
    fetchMeasurements();
  }

  void _changeDay(bool next) {
    setState(() {
      selectedDate = next
          ? selectedDate.add(const Duration(days: 1))
          : selectedDate.subtract(const Duration(days: 1));
      selectedDayLabel = _getLabelForDate(selectedDate);
    });
    fetchMeasurements();
  }

  String _getLabelForDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return "Today";
    if (target == today.subtract(const Duration(days: 1))) return "Yesterday";
    return DateFormat('d MMM yyyy').format(target);
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
    DateTime startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('Sugar Measurements')
        .doc(widget.pCode)
        .collection('BloodSugarReadings')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: const Color(0xFFE8883C),
          leading: const SizedBox.shrink(),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 60),
                    const Text(
                      "Measurements",
                      style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 31,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFE8883C)),
                  onPressed: () => _changeDay(false),
                ),
                Text(
                  selectedDayLabel,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFFE8883C)),
                  onPressed: () => _changeDay(true),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Color(0xFFE8883C), size: 20),
                  onPressed: _showCalendarDialog,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const MeasurementStatus(),
            const SizedBox(height: 20),
            measurementCard("1st Measurement", firstValue),
            const SizedBox(height: 15),
            measurementCard("2nd Measurement", secondValue),
          ],
        ),
      ),
    );
  }

  Widget measurementCard(String title, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 16)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
        ],
      ),
    );
  }
}

class MeasurementStatus extends StatelessWidget {
  const MeasurementStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        children: [
          Text("Status:", style: TextStyle(fontSize: 16)),
          SizedBox(width: 10),
          Icon(Icons.flag, color: Colors.green),
        ],
      ),
    );
  }
}