import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // إضافة الـ BlocProvider
import 'pressure_screen.dart';
import 'sugaur_mesurements_screen.dart';
import 'home_screen.dart';
import 'sugar_time_cubit.dart'; // تأكد من أنك استيردت الـ Cubit المناسب

class ChooseScreen extends StatelessWidget {
  final String pCode;

  const ChooseScreen({required this.pCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (context) => HomeScreen(pCode: pCode)),
                              (Route<dynamic> route) => false,);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 75.0),
                      child: Text(
                        "Choose Type",
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Please Select Your Type Of Measurements",
                style: TextStyle(
                  fontSize: 26,
                  fontFamily: 'LeagueSpartan',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 70),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2260FF),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => SugarTimeCubit(),
                        child: SugarMeasurementsScreen(pCode: pCode),
                      ),
                    ),
                  );
                },
                child: Text(
                  "Sugar Measurements",
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'LeagueSpartan',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB0D2FF),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PressureMeasurementScreen(pCode: pCode),
                    ),
                  );
                },
                child: Text(
                  "Pressure Measurements",
                  style: TextStyle(
                    fontSize: 27,
                    fontFamily: 'LeagueSpartan',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2260FF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}