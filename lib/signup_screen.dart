import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'doctor_homescreen.dart';
import 'login_screen.dart';
import 'shadow_homescreen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late String email;
  late String password;
  late String firstName;
  late String lastName;
  late String mobileNumber;
  late String age;
  String? selectedRole;
  String? selectedStatus;

  final List<String> roles = ['doctor', 'patient', 'shadow'];
  final List<String> status = ['diabetic', 'blood pressure', 'both'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'New Account',
          style: TextStyle(color: Color(0xFF2260FF), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('First name', 'example', (value) => firstName = value),
              SizedBox(height: 16),
              _buildTextField('Last name', 'example', (value) => lastName = value),
              SizedBox(height: 16),
              _buildTextField('Email', 'example@gmail.com', (value) => email = value),
              SizedBox(height: 16),
              _buildPasswordField('Password', (value) => password = value),
              SizedBox(height: 16),
              _buildTextField('age', '30', (value) => age = value),
              SizedBox(height: 16),
              _buildTextField('Mobile Number', '0123456789', (value) => mobileNumber = value),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedRole,
                items: roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Select Role',
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (selectedRole == 'patient') ...[
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                items: status.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role.toLowerCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Select Status',
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              ],
              SizedBox(height: 16,),

              ElevatedButton(
                onPressed: () async {
                  // تحقق من الحقول الفارغة
                  if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty ||
                      mobileNumber.isEmpty || age.isEmpty || selectedRole == null ||
                      (selectedRole == 'patient' && selectedStatus == null)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all fields.')),
                    );
                    return;
                  }

                  // تحقق من صحة الإيميل
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid email address.')),
                    );
                    return;
                  }

                  // تحقق من قوة الباسورد
                  if (password.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password must be at least 6 characters.')),
                    );
                    return;
                  }

                  // تحقق من صحة رقم الموبايل (مصري)
                  if (!RegExp(r'^01[0-9]{9}$').hasMatch(mobileNumber)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid Egyptian mobile number.')),
                    );
                    return;
                  }

                  // تحقق من السن
                  int? parsedAge = int.tryParse(age);
                  if (parsedAge == null || parsedAge <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid age.')),
                    );
                    return;
                  }

                  try {
                    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
                      email: email.trim(),
                      password: password.trim(),
                    );

                    String newCode = await _generateNewCode();

                    Map<String, dynamic> userData = {
                      'firstName': firstName,
                      'lastName': lastName,
                      'email': email,
                      'mobileNumber': mobileNumber,
                      'role': selectedRole,
                      'age': age,
                    };

                    if (selectedRole == 'patient') {
                      userData['status'] = selectedStatus;
                    }

                    if (selectedRole == 'doctor') {
                      userData['D-code'] = newCode;
                    } else if (selectedRole == 'patient') {
                      userData['P-code'] = newCode;
                    } else if (selectedRole == 'shadow') {
                      userData['S-code'] = newCode;
                    }

                    await firestore.collection('users').doc(userCredential.user!.uid).set(userData);

                    if (selectedRole == 'patient') {
                      await firestore.collection('patient').doc(userCredential.user!.uid).set({
                        'P-code': newCode,
                        'name': '$firstName $lastName',
                        'email': email,
                        'mobile no': mobileNumber,
                        'age': age,
                        'status': selectedStatus,
                      });
                    }

                    // التنقل حسب الدور
                    if (selectedRole == "doctor") {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => DoctorHomeScreen(dCode: newCode)));
                    } else if (selectedRole == "patient") {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => HomeScreen(pCode: newCode)));
                    } else if (selectedRole == "shadow") {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => ShadowHomeScreen(sCode: newCode)));
                    } else {
                      print("Role not recognized");
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2260FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Sign Up', style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, Function(String) onChanged) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, Function(String) onChanged) {
    return TextField(
      obscureText: true,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Icon(Icons.visibility_off),
      ),
    );
  }

  Future<String> _generateNewCode() async {
    String prefix;

    if (selectedRole == 'doctor') {
      prefix = 'D';
    } else if (selectedRole == 'patient') {
      prefix = 'P';
    } else if (selectedRole == 'shadow') {
      prefix = 'S';
    } else {
      prefix = 'U';
    }

    try {
      QuerySnapshot snapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: selectedRole)
          .get();

      List<int> codeNumbers = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data =doc.data() as Map<String, dynamic>;
        String? code = data[_getCodeKey()];
        if (code != null && code.startsWith(prefix)) {
          String numberPart = code.substring(1);
          int? number = int.tryParse(numberPart);
          if (number != null) {
            codeNumbers.add(number);
          }
        }
      }

      int nextNumber = 1;
      if (codeNumbers.isNotEmpty) {
        nextNumber = codeNumbers.reduce((a, b) => a > b ? a : b) + 1;
      }

      return '$prefix${nextNumber.toString().padLeft(3, '0')}';

    } catch (e) {
      print('Error generating code: $e');
      return '${prefix}001';
    }
  }

  String _getCodeKey() {
    if (selectedRole == null || selectedRole!.isEmpty) {
      throw Exception("Role is not selected properly");
    }

    if (selectedRole == 'doctor') {
      return 'D-code';
    } else if (selectedRole == 'shadow') {
      return 'S-code';
    } else if (selectedRole == 'patient') {
      return 'P-code';
    } else {
      throw Exception("Unknown role: $selectedRole");
    }
  }
}