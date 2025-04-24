import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MeasurementsScreen extends StatefulWidget {
  final String pCode;

  const MeasurementsScreen({super.key, required this.pCode});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  // Store the future here
  late Future<Map<String, String>> measurementsFuture;

  @override
  void initState() {
    super.initState();
    measurementsFuture = fetchMeasurements(); // Initialize the future
  }

  Future<Map<String, String>> fetchMeasurements() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    print('Current date: $now');
    print('Start of day: $startOfDay');
    print('End of day: $endOfDay');
    print('Fetching measurements for pCode: ${widget.pCode}');

    final snapshot = await FirebaseFirestore.instance
        .collection('Sugar Measurements')
        .doc(widget.pCode)
        .collection('BloodSugarReadings')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    print('Documents found: ${snapshot.docs.length}');

    String fetchedFirst = 'N/A';
    String fetchedSecond = 'N/A';

    for (var doc in snapshot.docs) {
      final data = doc.data();
      print('Document data: $data');

      final measurement = data['measurement'];

      if (measurement != null && measurement is Map<String, dynamic>) {
        final type = measurement['type'];
        final value = measurement['value']?.toString();

        print('Type: $type - Value: $value');

        if (type == 'First') {
          fetchedFirst = value ?? 'N/A';
        } else if (type == 'Second') {
          fetchedSecond = value ?? 'N/A';
        }
      }
    }
    // Return a map containing both measurements
    return {'first': fetchedFirst, 'second': fetchedSecond};
  }

  @override
  Widget build(BuildContext context) {
    print('Building screen');
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const MeasurementStatus(),
            const SizedBox(height: 20),
            // Use FutureBuilder to handle the asynchronous operation
            FutureBuilder<Map<String, String>>(
              future: measurementsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while waiting for the data
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Display an error message if something went wrong
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  // Extract the data from the snapshot
                  final firstMeasurement = snapshot.data!['first']!;
                  final secondMeasurement = snapshot.data!['second']!;

                  // Build the UI with the fetched data
                  return Column(
                    children: [
                      MeasurementCard(label: "1st Measurement:", value: firstMeasurement),
                      const SizedBox(height: 15),
                      MeasurementCard(label: "2nd Measurement:", value: secondMeasurement),
                    ],
                  );
                } else {
                  // Handle the case where no data is available
                  return const Text('No measurements found for today.');
                }
              },
            ),
          ],
        ),
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

class MeasurementCard extends StatelessWidget {
  final String label;
  final String value;

  const MeasurementCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}