import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicAppointmentScreen extends StatefulWidget {
  final String pCode;

  ClinicAppointmentScreen({required this.pCode});

  @override
  _ClinicAppointmentScreenState createState() =>
      _ClinicAppointmentScreenState();
}

class _ClinicAppointmentScreenState extends State<ClinicAppointmentScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedDoctor = 'Doctor';
  String selectedTime = 'Choose Time';
  String selectedStatus = 'Diabetics';
  TextEditingController patientCodeController = TextEditingController();


  final List<String> consultationTimes = ['Choose Time', '10:00 AM', '2:00 PM', '4:00 PM'];
  final List<String> statusOptions = ['Diabetics', 'Blood Pressure'];

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  Future<List<String>> fetchDoctors() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Doctor').get();
    List<String> doctorNames = ['Doctor'];
    for (var doc in querySnapshot.docs) {
      doctorNames.add(doc['Doctor name']);
    }
    return doctorNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
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
                        "Clinic Appointment",
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

      endDrawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF2260FF)),
              child: Text(
                'Saved Appointments',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('appointments')
                    .doc(widget.pCode)
                    .collection('visits')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No appointments available'));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text("${data['doctor']}"),
                        subtitle: Text("${data['date']} - ${data['time']}"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('appointments')
                                .doc(widget.pCode)
                                .collection('visits')
                                .doc(doc.id)
                                .delete();
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "P-Code: ${widget.pCode}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text('Choose Doctor', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
            FutureBuilder<List<String>>(
              future: fetchDoctors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(child: Text('Error loading doctors'));
                }

                return buildDropdownMenu(snapshot.data!, selectedDoctor, (value) {
                  setState(() {
                    selectedDoctor = value!;
                  });
                });
              },
            ),
            SizedBox(height: 16),

            Center(
                child:TableCalendar(
                  focusedDay: focusedDay,
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (selectedDay.weekday != 5) {
                      setState(() {
                        this.selectedDay = selectedDay;
                        this.focusedDay = focusedDay;
                      });
                    }
                  },
                  enabledDayPredicate: (day) => day.weekday != 5,
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    formatButtonVisible: false,
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blue),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.blue),
                    weekendStyle: TextStyle(color: Colors.blue),
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(color: Colors.black, fontSize: 16),
                    weekendTextStyle: TextStyle(color: Colors.black, fontSize: 16),
                    outsideTextStyle: TextStyle(color: Colors.grey.shade400),
                    disabledTextStyle: TextStyle(color: Colors.grey.shade400),
                    todayTextStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    todayDecoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
            ),
            SizedBox(height: 20),

            Text('Select A Consultation Time', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
            buildDropdownMenu(consultationTimes, selectedTime, (value) {
              setState(() {
                selectedTime = value!;
              });
            }),
            SizedBox(height: 20),

            Text('Select Status', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
            buildDropdownMenu(statusOptions, selectedStatus, (value) {
              setState(() {
                selectedStatus = value!;
              });
            }),
            SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedDoctor == 'Doctor' || selectedTime == 'Choose Time' || selectedDay == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  String selectedDate = "${selectedDay!.day} ${getMonthName(selectedDay!.month)} ${selectedDay!.year}";

                  saveAppointment(widget.pCode, selectedDoctor, selectedDate, selectedTime, selectedStatus);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2260FF)),
                child: Text('Done', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdownMenu(List<String> items, String selectedItem, ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFA9BCFE),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        value: selectedItem,
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Color(0xFF2260FF)),
        style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.w500),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item, style: TextStyle(fontSize: 16)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  String getMonthName(int month) {
    return ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][month - 1];
  }

  void saveAppointment(String patientCode, String doctor, String date, String time, String status) async {
    await FirebaseFirestore.instance.collection('appointments')
        .doc(patientCode).collection('visits')
      .add({
      'pCode': widget.pCode,
      'doctor': doctor,
      'date': date,
      'time': time,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}