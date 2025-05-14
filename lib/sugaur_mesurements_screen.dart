import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sugar_time_cubit.dart';
import 'sugar_mesurements_detail.dart';

class SugarMeasurementsScreen extends StatefulWidget {
  final String pCode;

  SugarMeasurementsScreen({required this.pCode});

  @override
  _SugarMeasurementsScreenState createState() => _SugarMeasurementsScreenState();
}
class _SugarMeasurementsScreenState extends State<SugarMeasurementsScreen> {
  @override
  Widget build(BuildContext context) {
    final sugarTimeCubit = context.read<SugarTimeCubit>();
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                        Navigator.pop(context);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "Sugar Measurements",
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
      body: BlocBuilder<SugarTimeCubit, Map<String, String>>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "P-Code: ${widget.pCode}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 50),
                  Text(
                    'Enter the time of entering measurements',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontFamily: 'LeagueSpartan',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 100),
                  _buildMeasurementSection(
                    label: 'First measurement',
                    time: state['first'] ?? '12:00 AM',
                    onPressed: (newTime) {
                      sugarTimeCubit.updateFirst(newTime);
                    },
                  ),
                  SizedBox(height: 40),
                  _buildMeasurementSection(
                    label: 'Second measurement',
                    time: state['second'] ?? '8:00 PM',
                    onPressed: (newTime) {
                      sugarTimeCubit.updateSecond(newTime);
                    },
                  ),
                  SizedBox(height: 100),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2979FF),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SugarMeasurementsDetailScreen(
                              firstTime: state['first'] ?? '12:00 AM',
                              secondTime: state['second'] ?? '8:00 PM',
                              pCode: widget.pCode,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'LeagueSpartan',
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildMeasurementSection({
    required String label,
    required String time,
    required Function(String) onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontFamily: 'LeagueSpartan',
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        InkWell(
          onTap: () async {
            TimeOfDay? selectedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (selectedTime != null) {
              onPressed(selectedTime.format(context)); // Use context directly
            }
          },
          child: Container(
            width: 162,
            height: 45,
            decoration: BoxDecoration(
              color: Color(0xFFCAD6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'LeagueSpartan',
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Icon(
                  Icons.alarm,
                  color: Colors.black,
                  size: 25,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


