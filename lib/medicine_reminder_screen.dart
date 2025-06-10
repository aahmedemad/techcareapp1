import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';


class MedicineReminderScreen extends StatefulWidget {
  final String pCode; // استقبال P-Code من LoginScreen

  const MedicineReminderScreen({required this.pCode});
  @override
  _MedicineReminderScreenState createState() =>
      _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  final TextEditingController medicineNameController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  String selectedMealTime = 'Before Meal';
  TimeOfDay selectedTime = TimeOfDay(hour: 10, minute: 0);
  List<String> savedReminders = [];
  String selectedDose = '1 Dose';

  void _resetFields() {
    setState(() {
      medicineNameController.clear();
      durationController.clear();
      selectedMealTime = 'Before Meal';
      selectedTime = TimeOfDay(hour: 10, minute: 0);
      selectedDose = '1 Dose';
    });
  }


  void _saveReminder() async {
    if (medicineNameController.text.isNotEmpty && durationController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection("medicine reminder").add({
        "pCode": widget.pCode,
        "medicine_name": medicineNameController.text,
        "dose": selectedDose,
        "duration": durationController.text,
        "time": "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
        "meal_time": selectedMealTime,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reminder added!"), duration: Duration(seconds: 2)),
      );

      _resetFields();
    }
  }

  void _deleteReminder(String documentId) async {
    await FirebaseFirestore.instance.collection("medicine reminder").doc(documentId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF2260FF)),
              child: Text(
                'Saved Reminders',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection("medicine reminder")
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No reminders added."));
                  }

                  var reminders = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      var reminder = reminders[index];
                      return ListTile(
                        title: Text(
                          "${reminder['medicine_name']} - ${reminder['dose']} - ${reminder['duration']} days at ${reminder['time']} (${reminder['meal_time']})",
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteReminder(reminder.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: Color(0xFF2260FF),
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.white, size: 32),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 45.0),
                          child: Text(
                            "Medicine Reminder",
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
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Medicine Name:', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              TextField(
                controller: medicineNameController,
                decoration: InputDecoration(
                  hintText: 'Enter Medicine Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 30),
              Text('Amount & How Long', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedDose,
                      items: ['1 Dose', '2 Doses', '3 Doses', '4 Doses'].map((dose) {
                        return DropdownMenuItem<String>(
                          value: dose,
                          child: Text(dose),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedDose = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: '30 Days',
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text('Food & Medicine', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _mealOption('Before Meal', 'images/image 33.jpg'),
                  _mealOption('During Meal', 'images/image 33.jpg'),
                  _mealOption('After Meal', 'images/image 33.jpg'),
                ],
              ),
              SizedBox(height: 30),
              Text('Notification', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _selectTime,
                icon: Icon(Icons.notifications, color: Colors.white),
                label: Text('Change Time', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w500)),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2260FF)),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2260FF), minimumSize: Size(double.infinity, 50)),
                  onPressed: _saveReminder,
                  child: Text('Done', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mealOption(String text, String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMealTime = text;
        });
      },
      child: Column(
        children: [
          Image.asset(imagePath, width: 100, height: 100),
          SizedBox(height: 5),
          Text(text, style: TextStyle(color: selectedMealTime == text ? Colors.blue : Colors.black54)),
        ],
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }
}