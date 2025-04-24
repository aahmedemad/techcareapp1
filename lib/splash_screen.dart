import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_screen.dart';  // OnboardingScreen


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }
  void _startSplashSequence() async {
    for (int i = 0; i < 4; i++) {
      await Future.delayed(const Duration(milliseconds: 2000));
      setState(() {
        currentStep = i;
      });
    }
    await Future.delayed(const Duration(milliseconds: 550));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _getSplashContent(),
        ),
      ),
    );
  }
  Color _getBackgroundColor() {
    if (currentStep == 2 || currentStep == 3) {
      return Colors.white;
    }
    return Colors.white;
  }
  Widget _getSplashContent() {
    switch (currentStep) {
      case 0:
        return Image.asset(
          'images/image 11.jpg',
          width: 100,
          height: 100,
          key: ValueKey<int>(currentStep),
        );
      case 1:
        return Image.asset(
          'images/image 12.jpg',
          width: 300,
          height: 300,
          key: ValueKey<int>(currentStep),
        );
      case 2:
        return Image.asset(
          'images/image 13.jpg',
          width: 70,
          height: 70,
          key: ValueKey<int>(currentStep),
        );
      case 3:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'images/image 11.jpg',
              width: 100,
              height: 100,
              key: ValueKey<int>(currentStep),
            ),
            // const SizedBox(width: 0),
            const Text(
              'TechCare',
              style: TextStyle(
                fontFamily: "LeagueSpartan",
                fontSize: 50,
                color: Color(0xFF2260FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }
}