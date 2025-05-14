import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SugarMeasurementsDetailScreen extends StatefulWidget {
  final String firstTime;
  final String secondTime;
  final String pCode;

  SugarMeasurementsDetailScreen({
    required this.firstTime,
    required this.secondTime,
    required this.pCode,
  });

  @override
  _SugarMeasurementsDetailScreenState createState() => _SugarMeasurementsDetailScreenState();
}

class _SugarMeasurementsDetailScreenState extends State<SugarMeasurementsDetailScreen> {
  TextEditingController firstMeasurementController = TextEditingController();
  TextEditingController secondMeasurementController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  void _loadMeasurements() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // === تحميل القياس الأول من SharedPreferences ===
      String? firstMeasurement = prefs.getString('firstMeasurement');
      String? firstDate = prefs.getString('measurementDate');

      if (firstMeasurement != null && firstDate != null) {
        DateTime saved = DateTime.parse(firstDate);
        DateTime now = DateTime.now();

        if (saved.year == now.year && saved.month == now.month && saved.day == now.day) {
          firstMeasurementController.text = firstMeasurement;
        } else {
          await prefs.remove('firstMeasurement');
          await prefs.remove('measurementDate');
        }
      }

      if (firstMeasurementController.text.isEmpty) {
        var snapshotFirst = await FirebaseFirestore.instance
            .collection('Sugar Measurements')
            .doc(widget.pCode)
            .collection('BloodSugarReadings')
            .doc('first')
            .get();

        if (snapshotFirst.exists) {
          var data = snapshotFirst.data();
          String firestoreFirst = data?['measurement']['value'].toString() ?? '';
          firstMeasurementController.text = firestoreFirst;
        }
      }
      String? secondDate = prefs.getString('secondMeasurementDate');
      if (secondDate != null) {
        DateTime saved = DateTime.parse(secondDate);
        DateTime now = DateTime.now();

        if (saved.year == now.year && saved.month == now.month && saved.day == now.day) {

          secondMeasurementController.text = prefs.getString('secondMeasurement') ??'';
          var snapshotSecond = await FirebaseFirestore.instance
              .collection('Sugar Measurements')
              .doc(widget.pCode)
              .collection('BloodSugarReadings')
              .doc('second')
              .get();

          if (snapshotSecond.exists) {
            var data = snapshotSecond.data();
            String firestoreSecond = data?['measurement']['value'].toString() ?? '';
            secondMeasurementController.text = firestoreSecond;

            await prefs.setString('secondMeasurement', firestoreSecond);
          }
        } else {
          await prefs.remove('secondMeasurementDate');
          await prefs.remove('secondMeasurement');
        }
      }

    } catch (e) {
      _showAlertDialog("Error loading data: $e");
    }
  }

  void _saveFirstMeasurement() async {
    String value = firstMeasurementController.text;
    if (!_validateMeasurement(value)) return;

    try {
      // حفظ القياس في Firestore
      await FirebaseFirestore.instance
          .collection('Sugar Measurements')
          .doc(widget.pCode)
          .collection('BloodSugarReadings')
          .add({
        'pCode': widget.pCode,
        'measurement': {
          'value': int.parse(value),
          'time': widget.firstTime,
          'type': 'first',
        },
        'timestamp': FieldValue.serverTimestamp(),
      });

      // حفظ القيمة في SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('firstMeasurement', value);
      await prefs.setString('measurementDate', DateTime.now().toIso8601String());

      _showSuccessMessage("First Measurement saved successfully!");
    } catch (e) {
      _showAlertDialog("Error saving data: $e");
    }
  }

  void _saveMeasurements({required bool isFirst}) async {
    if (isFirst) {
      _saveFirstMeasurement();
    } else {
      String value = secondMeasurementController.text;
      if (!_validateMeasurement(value)) return;

      try {
        await FirebaseFirestore.instance
            .collection('Sugar Measurements')
            .doc(widget.pCode)
            .collection('BloodSugarReadings')
            .add({
          'pCode': widget.pCode,
          'measurement': {
            'value': int.parse(value),
            'time': widget.secondTime,
            'type': 'second',
          },
          'timestamp': FieldValue.serverTimestamp(),
        });

        _showSuccessMessage("Second Measurement saved successfully!");
        secondMeasurementController.clear();
        firstMeasurementController.clear();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('secondMeasurement', value);
        await prefs.setString('secondMeasurementDate', DateTime.now().toIso8601String());

      } catch (e) {
        _showAlertDialog("Error saving data: $e");
      }
    }
  }

  void _showAlertDialog(String message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 50, color: Colors.redAccent),
              SizedBox(height: 10),
              Text(
                "Error!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text(
                  "OK",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  bool _validateMeasurement(String value) {
    if (value.isEmpty) {
      _showAlertDialog("Please enter a measurement.");
      return false;
    }

    int? measurement = int.tryParse(value);
    if (measurement == null || measurement < 70 || measurement > 500) {
      _showAlertDialog("Measurement must be between 70 and 500.");
      return false;
    }

    return true;
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Measurements Details",
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildMeasurementField("First Measurement", widget.firstTime, firstMeasurementController),
              SizedBox(height: 30),
              _buildMeasurementField("Second Measurement", widget.secondTime, secondMeasurementController),
              SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSaveButton("Save First", () => _saveMeasurements(isFirst: true)),
                  _buildSaveButton("Save Second", () => _saveMeasurements(isFirst: false)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementField(String label, String time, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFFCAD6FF),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Text(time, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.blueGrey)),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(fontSize: 22, color: Colors.blueGrey),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter value',
                  hintStyle: TextStyle(color: Colors.blueGrey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.blueGrey, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          'Entered: ${controller.text.isNotEmpty ? controller.text : 'No measurement entered yet'}',
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildSaveButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2979FF),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white)),
    );
  }
}