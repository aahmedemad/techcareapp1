import 'package:flutter/material.dart';

class AllPatientsScreen extends StatefulWidget {
  @override
  _AllPatientsScreenState createState() => _AllPatientsScreenState();
}

class _AllPatientsScreenState extends State<AllPatientsScreen> {
  List<Map<String, String>> patients = [
    {"name": "Mohamed Ahmed", "condition": "Diabetic"},
    {"name": "Sarah Salem", "condition": "Blood Pressure"},
    {"name": "Khaled Ahmed", "condition": "Diabetic"},
    {"name": "Nour Hassan", "condition": "Blood Pressure"},
    {"name": "Hassan Ali", "condition": "Diabetic"},
  ];

  String searchQuery = "";

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
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: ClipOval(),
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
                      padding: const EdgeInsets.only(left: 75.0),
                      child: Text(
                        "All Patients",
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
          children: [
            // Search Bar
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search for a patient...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Patients List
            Expanded(
              child: ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  if (searchQuery.isNotEmpty &&
                      !patient["name"]!.toLowerCase().contains(searchQuery)) {
                    return SizedBox(); // Hide unmatched patients
                  }
                  return buildPatientCard(patient);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPatientCard(Map<String, String> patient) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[300],
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          patient["name"]!,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          patient["condition"]!,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.chat_bubble_outline, color: Colors.grey),
      ),
    );
  }
}