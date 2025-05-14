import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'doctor_homescreen.dart';
import 'shadow_homescreen.dart';
import 'package:techcareapp1/forget_password_screen.dart';
import 'package:geolocator/geolocator.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
   String email = '';
   String password = '';

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied')),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF2260FF)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Login",
          style: TextStyle(
              fontSize: 32,
              color: Color(0xFF2260FF),
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'images/image 10.jpg',
                  height: 150,
                  width: 150,
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  email = value.trim();
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  hintText: "example@gmail.com",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Password",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  password = value.trim();
                },
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  suffixIcon: Icon(Icons.visibility_off),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgetPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Forget Password",
                    style: TextStyle(color: Color(0xFF2260FF), fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(

                    onPressed: () async {
                      try {
                        UserCredential userCredential =
                        await auth.signInWithEmailAndPassword(
                            email: email, password: password);

                        if (userCredential.user != null) {
                          DocumentSnapshot userDoc = await firestore
                              .collection('users')
                              .doc(userCredential.user!.uid)
                              .get();

                          if (userDoc.exists) {
                            String role = userDoc['role'];
                            String code = '';


                            if (role == "doctor") {
                              code = userDoc['D-code'] ?? '';
                            } else if (role == "patient") {
                              code = userDoc['P-code'] ?? '';
                            } else if (role == "shadow") {
                              code = userDoc['S-code'] ?? '';
                            }

                            print("User role: $role, Code: $code");

                          if (role == "patient") {
                            Position? position = await _determinePosition();
                            if (position != null) {
                              await firestore.collection('users').doc(
                                  userCredential.user!.uid).update({
                                'latitude': position.latitude,
                                'longitude': position.longitude,
                              });
                            }
                          }


                            if (role == "doctor") {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorHomeScreen(dCode: code),
                                ),
                              );
                            } else if (role == "patient") {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(pCode: code),
                                ),
                              );
                            } else if (role == "shadow") {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShadowHomeScreen(sCode: code),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Unknown role")),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("User data not found")),
                            );
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}")),
                        );
                      }
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2260FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(37),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                  ),
                  child: Text(
                    "Log In",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}