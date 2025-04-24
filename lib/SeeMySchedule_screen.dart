import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SeeMyScheduleScreen extends StatefulWidget {
  @override
  _SeeMyScheduleScreenState createState() => _SeeMyScheduleScreenState();
}

class _SeeMyScheduleScreenState extends State<SeeMyScheduleScreen> {
  String selectedDay = "Tomorrow";
  List<Map<String, dynamic>> patients = [];

  @override
  void initState() {
    super.initState();
    fetchVisits();
  }

  void _changeDay(bool next) {
    setState(() {
      if (next) {
        if (selectedDay == "Tomorrow") {
          selectedDay = "Next Day";
        } else if (selectedDay == "Next Day") {
          _showCalendarDialog();
          return;
        }
      } else {
        selectedDay = "Yesterday";
      }
    });
    fetchVisits();
  }

  Future<void> _showCalendarDialog() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      String formatted = DateFormat('d MMMM yyyy').format(picked);
      selectedDay = formatted;
      fetchVisits();
    }
  }

  Future<void> fetchVisits() async {
    final DateTime now = DateTime.now();
    DateTime targetDate;

    if (selectedDay == "Tomorrow") {
      targetDate = now.add(Duration(days: 1));
    } else if (selectedDay == "Next Day") {
      targetDate = now.add(Duration(days: 2));
    } else if (selectedDay == "Yesterday") {
      targetDate = now.subtract(Duration(days: 1));
    } else {
      // لو تم تحديد التاريخ من Calendar
      targetDate = DateFormat('d MMMM yyyy').parse(selectedDay);
    }

    String formattedTargetDate = DateFormat('d MMMM yyyy').format(targetDate);
    List<Map<String, dynamic>> visitCards = [];

    try {
      final visitsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .doc("P001")
          .collection('visits')
          .get();

      for (var doc in visitsSnapshot.docs) {
        final data = doc.data();
        final visitDateString = data['date'];

        if (visitDateString == formattedTargetDate) {
          final pCode = data['pCode'];

          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('P-code', isEqualTo: pCode)
              .get();

          if (userSnapshot.docs.isNotEmpty) {
            final userData = userSnapshot.docs.first.data();
            final fullName = '${userData['firstName']} ${userData['lastName']}';

            visitCards.add({
              'docId': doc.id,
              'time': data['time'],
              'name': fullName,
              'type': data['status'] ?? '',
              'pCode': pCode,
            });
          }
        }
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() {
      patients = visitCards;
    });
  }

  Future<void> _deleteVisit(String docId) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc("P001")
        .collection('visits')
        .doc(docId)
        .delete();
    fetchVisits();
  }

  void _editVisitDialog(String docId, String oldTime, String oldStatus) {
    TextEditingController timeController = TextEditingController(text: oldTime);
    TextEditingController statusController = TextEditingController(text: oldStatus);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Visit"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeController,
                decoration: InputDecoration(labelText: "Time"),
              ),
              TextField(
                controller: statusController,
                decoration: InputDecoration(labelText: "Status"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('appointments')
                    .doc("P001")
                    .collection('visits')
                    .doc(docId)
                    .update({
                  'time': timeController.text,
                  'status': statusController.text,
                });
                Navigator.pop(context);
                fetchVisits();
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPatientCard(String time, String name, String type, String docId) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(time, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(width: 15),
          Icon(Icons.person, size: 30, color: Colors.black54),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(type, style: TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.orange),
            onPressed: () => _editVisitDialog(docId, time, type),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteVisit(docId),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      onPressed: () => Navigator.pop(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50.0),
                      child: Text(
                        "See My Schedule",
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Color(0xFF09806A)),
                  onPressed: () => _changeDay(false),
                ),
                Text(
                  selectedDay,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: Color(0xFF09806A)),
                  onPressed: () => _changeDay(true),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: patients.isEmpty
                  ? Center(child: Text('No appointments'))
                  : ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  return _buildPatientCard(
                    patient['time'],
                    patient['name'],
                    patient['type'],
                    patient['docId'],
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