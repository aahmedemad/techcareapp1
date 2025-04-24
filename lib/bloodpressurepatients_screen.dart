import 'package:flutter/material.dart';

class BloodPressurePatientsScreen extends StatelessWidget {
  const BloodPressurePatientsScreen({super.key});

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
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Blood Pressure Patients",
                        style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          fontSize: 29,
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  border: TableBorder.all(color: Colors.black12),
                  columns: const [
                    DataColumn(
                        label: Text("Name",
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Date",
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Measurements",
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Mail",
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Gander",
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Age",
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Phone number",
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Patient Code",
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold))),

                  ],
                  rows: _buildRows(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2260FF),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              "Done",
              style:
              TextStyle(color: Colors.black,fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  List<DataRow> _buildRows() {
    final List<Map<String, String>> patients = [
      {"name": "Salma", "date": "Wed Nov 25", "measurements": "80-100", "mail":"salma@gmail.com","Gender":"female","age":"20","phone number":"010600438905","patient code":"p12"},
      {"name": "Mohamed", "date": "Mon Apr 25", "measurements": "70-100","mail":"mohamed@gmail.com","Gender":"male","age":"55","phone number":"0188043205","patient code":"p10"},
      {"name": "Fathy", "date": "Tue Dec 27", "measurements": "190-230","mail":"fathy@gmail.com","Gender":"male","age":"35","phone number":"01088843255","patient code":"p20"},
      {"name": "Mohamed", "date": "Fri Oct 15", "measurements": "220-300", "mail":"mohamed@gmail.com","Gender":"male","age":"20","phone number":"01060043265","patient code":"p7"},
      {"name": "Yasser", "date": "Mon Jul 10", "measurements": "80-100","mail":"yasser@gmail.com","Gender":"male","age":"40","phone number":"01069948259","patient code":"p11"},
      {"name": "Sara", "date": "Tue Oct 21", "measurements": "220-300","mail":"sara@gmail.com","Gender":"female","age":"50","phone number":"01060043255","patient code":"p5"},
      {"name": "Nada", "date": "Sun Jun 20", "measurements": "230-300", "mail":"nada@gmail.com","Gender":"female","age":"19","phone number":"01060043285","patient code":"p3"},
      {"name": "Lama", "date": "Sat Jun 05", "measurements": "190-230", "mail": "lama@gmail.com","Gender":"female","age":"40","phone number":"01049093205","patient code":"p1"},
      {"name": "Khaled", "date": "Mon Sep 08", "measurements": "220-300","mail":"khaled@gmail.com","Gender":"male","age":"25","phone number":"01060043245","patient code":"p9"},
      {"name": "Fouad", "date": "Sat Apr 24", "measurements": "190-230","mail":"fouad@gmail.com","Gender":"male","age":"19","phone number":"01060943275","patient code":"p30"},
    ];

    return patients.map((patient) => DataRow(cells: [
      DataCell(Text(patient["name"]!,style:TextStyle(fontSize:16,fontWeight: FontWeight.w500))),
      DataCell(Text(patient["date"]!,style:TextStyle(fontSize:16,fontWeight: FontWeight.w500))),
      DataCell(Text(patient["measurements"]!,style:TextStyle(fontSize:16,fontWeight: FontWeight.w500))),
      DataCell(Text(patient["mail"]!,style:TextStyle(fontSize:16,fontWeight: FontWeight.w500))),
      DataCell(Text(patient["Gender"]!,style:TextStyle(fontSize:16,fontWeight: FontWeight.w500))),
      DataCell(Text(patient["age"]!,style:TextStyle(fontSize:16,fontWeight: FontWeight.w500))),
      DataCell(Text(patient["phone number"]!,style:TextStyle(fontSize:16,fontWeight: FontWeight.w500))),
      DataCell(Text(patient["patient code"]!,style:TextStyle(fontSize:16,fontWeight: FontWeight.w500))),

    ]))
        .toList();
  }
}