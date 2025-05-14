import 'package:flutter/material.dart';
import 'welc_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': "We Take-Care About You",
      'description': "A Personalized Health Companion For A Better You!",
      'image': 'images/image 1.jpg',
    },
    {
      'title': "Track Your Vital Signs",
      'description': "Monitor Your Blood Pressure And Sugar Levels With Our Service!",
      'image': 'images/image2.jpg',
    },
    {
      'title': "Stay Connected With Your Doctor!",
      'description': "Share Your Health Data Directly With Your Doctor And Receive Timely Medical Advice.",
      'image': 'images/image 5.jpg',
    },
    {
      'title': "Never Miss A Dose!",
      'description': "Organize Your Medications And Receive Timely Reminders To Stay On Track.",
      'image': 'images/image 6.jpg',
    },
    {
      'title': "Personalized Care, Every Step Of The Way!",
      'description': "Keep Yourself Safe By Sharing Your Location With Your Shadow Person.",
      'image': 'images/image5.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            page['title']!,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            page['description']!,
                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 30),
                          if (index == 1) ...[
                            Image.asset(
                              'images/image 2.jpg',
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    'images/image 3.jpg',
                                    height: 150,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Image.asset(
                                    'images/image 4.jpg',
                                    height: 150,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ] else if (index == 4) ...[

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    'images/image 8.jpg',
                                    height: 300,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Image.asset(
                                    'images/image 7.jpg',
                                    height: 300,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ] else

                            Image.asset(
                              page['image']!,
                              height: 500,
                              fit: BoxFit.contain,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      width: _currentIndex == index ? 12.0 : 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: _currentIndex == index ? Colors.indigo : Colors.grey,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),

          // زر Skip
            Positioned(
              top: 40.0,
              right: 20.0,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => welc()),
                  );
                },
                child: Text(
                  "Skip",
                  style: TextStyle(color: Colors.indigo, fontSize: 18,),
                ),
              ),
            ),
        ],
      ),
    );
  }
}