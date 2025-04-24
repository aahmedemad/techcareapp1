import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'welcome_patient_screen.dart';
import 'welcome_shadow_screen.dart';
import 'welcome_doctor_screen.dart';
class welc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //
              Column(
                children: [
                  SizedBox(height: 60),
                  Image.asset(
                    'images/image 10.jpg', //
                    height: 150,
                    width: 149,
                  ),
                  //const SizedBox(height: 16),
                  Text(
                    'TechCare',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2260FF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We Take-Care About You',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2260FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 100),

              //
              Text(
                'Join as a...',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 50),

              CustomButton(
                text: 'Patient',
                onPressed: () {
                  //
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomePatientScreen()), //
                  );
                },
              ),
              const SizedBox(height: 16),
              CustomButton(

                text: 'Shadow',
                onPressed: () {
                  //
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeShadowScreen()), //
                  );
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Doctor',

                onPressed: () {
                  //
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeDoctorScreen()), //
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 60), backgroundColor: Color(0xFF2260FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),

        ),
        elevation: 3
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}