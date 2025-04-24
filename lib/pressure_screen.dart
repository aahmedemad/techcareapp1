import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'choose_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PressureMeasurementScreen extends StatefulWidget {
  final String pCode;

  PressureMeasurementScreen({required this.pCode});

  @override
  _PressureMeasurementScreenState createState() =>
      _PressureMeasurementScreenState();
}

class _PressureMeasurementScreenState extends State<PressureMeasurementScreen> {
  TimeOfDay selectedTime = TimeOfDay.now();
  TextEditingController topMeasurementController = TextEditingController();
  TextEditingController bottomMeasurementController = TextEditingController();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  bool isValidBloodPressure(int sys, int dia) {
    return (sys >= 50 && sys <= 250) && (dia >= 30 && dia <= 150);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error",
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
          content: Text(message, style: TextStyle(fontSize: 21)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK",
                  style: TextStyle(fontSize: 22, color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // دالة عرض رسالة
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success",
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
          content: Text("Measurement submitted successfully",
              style: TextStyle(fontSize: 21)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK",
                  style: TextStyle(fontSize: 22, color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePressureMeasurement() async {
    String topMeasurement = topMeasurementController.text;
    String bottomMeasurement = bottomMeasurementController.text;

    if (topMeasurement.isEmpty || bottomMeasurement.isEmpty) {
      _showErrorDialog(context, "Please enter your measurement");
      return;
    }

    int? topValue = int.tryParse(topMeasurement);
    int? bottomValue = int.tryParse(bottomMeasurement);

    if (topValue == null || bottomValue == null || !isValidBloodPressure(topValue, bottomValue)) {
      _showErrorDialog(context, "Invalid measurement. Please enter a valid value.");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("pressure_measurements")
          .doc(widget.pCode)
          .collection("readings")
      .add({
        "pCode": widget.pCode,
        "systolic": topValue,
        "diastolic": bottomValue,
        "time": "${selectedTime.hour}:${selectedTime.minute}",
        "timestamp": FieldValue.serverTimestamp(),
      });

      _showSuccessDialog(context);
    } catch (e) {
      _showErrorDialog(context, "Error saving data. Please try again.");
    }
  }
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
                        Navigator.pop(context);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Pressure Measurement",
                        style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          fontSize: 31,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "P-Code: ${widget.pCode}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Enter your measurement",
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'LeagueSpartan',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFFDDEBFF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${selectedTime.format(context)}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.access_time, color: Colors.black),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 30),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        child: TextField(
                          controller: topMeasurementController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "120",
                            hintStyle: TextStyle(color: Colors.black38, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      Text(
                        "/",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black38,
                        ),
                      ),
                      Container(
                        width: 50,
                        child: TextField(
                          controller: bottomMeasurementController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "80",
                            hintStyle: TextStyle(color: Colors.black38, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2260FF),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
              ),
              onPressed: () {
                _savePressureMeasurement();
                String topMeasurement = topMeasurementController.text;
                String bottomMeasurement = bottomMeasurementController.text;

                if (topMeasurement.isEmpty || bottomMeasurement.isEmpty) {
                  _showErrorDialog(context, "Please enter your measurement");
                  return;
                }

                int? topValue = int.tryParse(topMeasurement);
                int? bottomValue = int.tryParse(bottomMeasurement);

                if (topValue == null || bottomValue == null || !isValidBloodPressure(topValue, bottomValue)) {
                  _showErrorDialog(context, "Invalid measurement. Please enter a valid value.");
                  return;
                }

                _showSuccessDialog(context);
                print("Measurement: $topValue/$bottomValue");
              },
              child: Text(
                "Save",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}