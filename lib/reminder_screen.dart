import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReminderScreen extends StatefulWidget {
  final String pCode;

  const ReminderScreen({required this.pCode});

  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<DocumentSnapshot> reminders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        Navigator.pop(context);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 100.0),
                      child: Text(
                        "Reminder",
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateNavigation(),
            SizedBox(height: 16),
            Text(
              "Your Medication Plan:",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("medicine reminder")
                  .where("pCode", isEqualTo: widget.pCode)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No reminders found"));
                }

                reminders = snapshot.data!.docs;

                return Expanded(
                  child: ListView.builder(
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      var reminder = reminders[index];
                      return MedicationCard(
                        medication: {
                          'name': reminder['medicine_name'],
                          'time': reminder['time'],
                          'dose': reminder['dose'],
                          'note': reminder['meal_time'],
                        },
                        reminder: reminder,
                        onDelete: () {
                          setState(() {
                            reminders.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateNavigation() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back_ios, size: 16),
            SizedBox(width: 8),
            Text(
              "Today",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  final Map<String, String> medication;
  final DocumentSnapshot reminder;
  final Function() onDelete;

  MedicationCard({required this.medication, required this.reminder, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medication['name']!,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text('${medication['time']} - ${medication['dose']}'),
          SizedBox(height: 4),
          Text(
            medication['note']!,
            style: TextStyle(
              color: Colors.blue[900],
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(),
          _buildActionButtons(reminder),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DocumentSnapshot reminder) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(Icons.close, "Skip", reminder, onDelete),
        _buildActionButton(Icons.check, "Done", reminder, onDelete),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, DocumentSnapshot reminder, Function() onDelete) {
    return Row(
      children: [
        IconButton(
          icon: Icon(icon, size: 18),
          onPressed: () async {
            if (label == "Skip") {
              await _updateReminderStatus(reminder.id, "skipped");
              onDelete();
            }
          },
        ),
        SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Future<void> _updateReminderStatus(String reminderId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection("medicine reminder")
          .doc(reminderId)
          .update({
        "status": status,
      });

      print("Reminder status updated to $status");
    } catch (e) {
      print("Error updating reminder status: $e");
    }
  }
}