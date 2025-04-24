import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_detail.dart';

class MedicineCheckScreen extends StatelessWidget {
  const MedicineCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: Color(0xFFE8883C),
          leading: SizedBox.shrink(),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                ),
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
                      padding: const EdgeInsets.only(left: 50.0),
                      child: Text(
                        "Medicine Check",
                        style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          fontSize: 31,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active_outlined, color: Colors.orange),
                SizedBox(width: 10),
                Text(
                  "Today's Review",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('medicine reminder')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No medicine reminders found."));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['medicine_name'] ?? 'Unknown';
                      final time = data['time'] ?? 'Unknown';
                      final status = data['status'] ?? 'Pending';

                      Color statusColor;
                      IconData icon;

                      if (status == 'Completed') {
                        statusColor = Colors.green;
                        icon = Icons.check;
                      } else if (status == 'Skipped') {
                        statusColor = Colors.red;
                        icon = Icons.close;
                      } else {
                        statusColor = Colors.grey;
                        icon = Icons.help_outline;
                      }

                      return MedicineCard(
                        name: name,
                        time: time,
                        status: status,
                        statusColor: statusColor,
                        icon: icon,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicineCard extends StatelessWidget {
  final String name;
  final String time;
  final String status;
  final Color statusColor;
  final IconData icon;

  const MedicineCard({
    super.key,
    required this.name,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.medication_outlined, size: 30),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$time - $status', style: TextStyle(color: statusColor)),
        trailing: Icon(icon, color: Colors.orange),
        onTap: () {
        },
      ),
    );
  }
}