import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patientInfo_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodPressurePatientsScreen extends StatefulWidget {
  final String dCode;

  BloodPressurePatientsScreen({required this.dCode});
  @override
  _BloodPressurePatientsScreenState createState() =>
      _BloodPressurePatientsScreenState();
}

class _BloodPressurePatientsScreenState
    extends State<BloodPressurePatientsScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredPatients = [];

  @override
  void initState() {
    super.initState();
    fetchBloodPressurePatients();
  }

  void fetchBloodPressurePatients() async {
    final firestore = FirebaseFirestore.instance;

    // 1. جيب كل المرضى المرتبطين بالدكتور
    final doctorPatientsSnapshot = await firestore
        .collection('doctor_patients')
        .where('D-code', isEqualTo: widget.dCode)
        .get();

    final pCodes = doctorPatientsSnapshot.docs.map((doc) => doc['P-code']).toList();

    // 2. جيب بيانات المرضى اللي حالتهم blood pressure ومن ضمن الـ P-code اللي فوق
    final patientsSnapshot = await firestore
        .collection('patient')
        .where('status', isEqualTo: 'blood pressure')
        .where('P-code', whereIn: pCodes)
        .get();

    setState(() {
      filteredPatients = patientsSnapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'P-code': doc['P-code'],
          'mobile no': doc['mobile no'],
          'age': doc['age'] ?? 'N/A',
          'email': doc['email'] ?? 'N/A',
          'status': doc['status'],
        };
      }).toList();
    });
  }

  void filterSearch(String query) {
    setState(() {
      filteredPatients = filteredPatients
          .where((patient) =>
          patient['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
            child: filteredPatients.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                var patient = filteredPatients[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientInfoScreen(
                          patient: patient,
                          dCode: widget.dCode,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.green[100],
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.black),
                      ),
                      title: Text(
                        patient['name'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        "Mobile: ${patient['mobile no']}",
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.call, color: Colors.black54),
                        onPressed: () {
                          _makePhoneCall(patient['mobile no']);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF09806A),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              "Done",
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

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
}