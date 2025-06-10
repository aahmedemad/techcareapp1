    import 'package:flutter/material.dart';
    import 'package:cloud_firestore/cloud_firestore.dart';
    import 'add_patient_screen.dart';
    import 'patient_detail.dart';
    import 'setting_screen.dart';

    class ShadowHomeScreen extends StatefulWidget {
      final String sCode;

      const ShadowHomeScreen({super.key, required this.sCode});

      @override
      _ShadowHomeScreenState createState() => _ShadowHomeScreenState();
    }
    class _ShadowHomeScreenState extends State<ShadowHomeScreen> {
      String shadowName = '';
      List<Map<String, dynamic>> patients = [];

      @override
      void initState() {
        super.initState();
        fetchShadowName();
        fetchPatients();
      }
      void fetchShadowName() async {
        try {
          QuerySnapshot query = await FirebaseFirestore.instance
              .collection('users')
              .where('S-code', isEqualTo: widget.sCode)
              .where('role', isEqualTo: 'shadow')
              .limit(1)
              .get();

          if (query.docs.isNotEmpty) {
            final data = query.docs.first.data() as Map<String, dynamic>;
            setState(() {
              shadowName = "${data['firstName']} ${data['lastName']}";
            });
          } else {
            setState(() {
              shadowName = 'Unknown';
            });
          }
        } catch (e) {
          print("Error fetching shadow name: $e");
          setState(() {
            shadowName = 'Error';
          });
        }
      }

      void fetchPatients() async {
        try {
          QuerySnapshot snapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('S-code', isEqualTo: widget.sCode)
              .where('role', isEqualTo: 'patient')
              .get();

          setState(() {
            patients = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          });
        } catch (e) {
          print("Error fetching patients: $e");
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(160),
            child: Container(
              padding: EdgeInsets.only(top: 40, left: 20, right: 20),
              decoration: BoxDecoration(
                color: Color(0xFFE8883C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundImage: AssetImage('images/image 32.jpg'),
                          ),
                          SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hi, Welcome Back",
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400),
                              ),
                              SizedBox(height: 5),
                              Text(
                                shadowName.isEmpty ? "Loading..." : shadowName,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: AssetImage('images/image 11.jpg'),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Shadow",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Ready To Check In On\nSomeone You Care About!",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPatientScreen(sCode: widget.sCode,shadowName: shadowName,)),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text(
                  "Add Patient",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF5CDAD),
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: patients.isEmpty
                    ? Center(child: Text("No patients found."))
                    : ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return Card(
                      color:Color(0xFFF5CDAD) ,
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientDetailScreen(
                                patientName: "${patient['firstName']} ${patient['lastName']}",
                                sCode: widget.sCode,
                                pCode: patient['P-code'],
                              ),
                            ),
                          );
                        },
                        leading: Icon(Icons.person, color: Colors.black, size: 40),
                        title: Text("${patient['firstName']} ${patient['lastName']}", style: TextStyle(fontSize: 20)),
                        subtitle: Text("Tap to view details", style: TextStyle(color: Colors.grey)),
                    trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                    bool? confirmDelete = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                    title: Text('Confirm Delete'),
                    content: Text('Are you sure you want to delete this patient?'),
                    actions: [
                    TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel'),
                    ),
                    TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                    ],
                    ),
                    );

                    if (confirmDelete == true) {
                    try {
                    // حذف S-code من وثيقة المريض
                    QuerySnapshot snapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .where('P-code', isEqualTo: patient['P-code'])
                        .limit(1)
                        .get();

                    if (snapshot.docs.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(snapshot.docs.first.id)
                        .update({'S-code': FieldValue.delete()});

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Patient unfollow successfully'),
                    backgroundColor: Colors.green,
                    ));

                    // تحديث القائمة
                    fetchPatients();
                    }
                    }
                    catch (e) {
                    print("Error deleting patient link: $e");
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error removing patient'),
                    backgroundColor: Colors.red,
                    ));
                    }
                    }
                    },
                    ),
                    ),
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBarWidget(),
        );
      }
    }

    class BottomNavigationBarWidget extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: Color(0xFFE8883C),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.home, color: Colors.black, size: 30),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black, size: 30),
                  onPressed: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context)=> SettingsScreen(userRole: 'shadow',)),);
                  },
                ),
              ],
            ),
          ),
        );
      }
    }