import 'package:flutter/material.dart';
import 'patientinfo_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DiabeticsScreen extends StatefulWidget {
  @override
  _DiabeticsScreenState createState() => _DiabeticsScreenState();
}

class _DiabeticsScreenState extends State<DiabeticsScreen> {

  void _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $url");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch phone call")),
      );
    }
  }

  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> patients = [
    {
      'name': 'Mohamed Ahmed',
      'code': 'P-001',
      'age': 45,
      'mobile': '01060051899',
      'email': 'example1@example.com',
      'lastVisit': 'Feb 28, 2025',
      'nextVisit': 'March 10, 2025',
      'statusColor': Colors.green,
      'measurements': [90, 130],
    },
    {
      'name': 'Sarrah Ahmed',
      'code': 'P-002',
      'age': 50,
      'mobile': '01065319455',
      'email': 'example2@example.com',
      'lastVisit': 'Feb 16, 2025',
      'nextVisit': 'March 10, 2025',
      'statusColor': Colors.red,
      'measurements': [150, 250],
    },
    {
      'name': 'Mohamed El-Sayed',
      'code': 'P-003',
      'age': 60,
      'mobile': '01006467153',
      'email': 'example3@example.com',
      'lastVisit': 'Feb 20, 2025',
      'nextVisit': 'March 10, 2025',
      'statusColor': Colors.green,
      'measurements': [100, 110],
    },
    {
      'name': 'Ahmed Khaled',
      'code': 'P-004',
      'age': 48,
      'mobile': '01141660166',
      'email': 'example4@example.com',
      'lastVisit': 'Feb 18, 2025',
      'nextVisit': 'March 10, 2025',
      'statusColor': Colors.yellow,
      'measurements': [105, 145],
    },
  ];

  List<Map<String, dynamic>> filteredPatients = [];

  @override
  void initState() {
    super.initState();
    filteredPatients = patients;
  }

  void filterSearch(String query) {
    setState(() {
      filteredPatients = patients
          .where((patient) =>
          patient['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Diabetics',
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
        shape: const RoundedRectangleBorder(
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,color: Colors.white,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterSearch,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                var patient = filteredPatients[index];
                return GestureDetector(
                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientInfoScreen(patient: patient),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Colors.black),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient['name'],
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(Icons.flag, color: patient['statusColor'], size: 18),
                                  SizedBox(width: 5),
                                  Text(patient['nextVisit']),
                                ],
                              ),
                              Text(
                                "Last Visit: ${patient['lastVisit']}",
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.call, color: Colors.black54),
                              onPressed: () {
                                _makePhoneCall(patient['mobile']);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.message, color: Colors.black54),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                legendItem('Normal', Colors.green),
                legendItem('High', Colors.red),
                legendItem('Low', Colors.yellow),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget legendItem(String text, Color color) {
    return Row(
      children: [
        Icon(Icons.flag, color: color, size: 18),
        SizedBox(width: 5),
        Text(text),
      ],
    );
  }
}