import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SugarMeasurementsScreen extends StatefulWidget {
  final String pCode;

  SugarMeasurementsScreen({required this.pCode});

  @override
  _SugarMeasurementsScreenState createState() =>
      _SugarMeasurementsScreenState();
}

class _SugarMeasurementsScreenState extends State<SugarMeasurementsScreen> {
  TextEditingController firstMeasurementController =
  TextEditingController(text: '12:00 AM');
  TextEditingController secondMeasurementController =
  TextEditingController(text: '8:00 PM');

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  void _loadMeasurements() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Sugar Measurements')
          .doc(widget.pCode)
          .collection('BloodSugarReadings')
          .where('type', isEqualTo: 'first')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data();
        setState(() {
          firstMeasurementController.text =
              data['measurement']['value'].toString();
        });
      }

      snapshot = await FirebaseFirestore.instance
          .collection('Sugar Measurements')
          .doc(widget.pCode)
          .collection('BloodSugarReadings')
          .where('type', isEqualTo: 'second')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data();
        setState(() {
          secondMeasurementController.text =
              data['measurement']['value'].toString();
        });
      }
    } catch (e) {
      print("Error loading measurements: $e");
    }
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
      body: SingleChildScrollView(
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
                  'First measurement', firstMeasurementController),
              SizedBox(height: 40),
              _buildMeasurementSection(
                  'Second measurement', secondMeasurementController),
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
                          firstTime: firstMeasurementController.text,
                          secondTime: secondMeasurementController.text,
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
      ),
    );
  }

  Widget _buildMeasurementSection(
      String label, TextEditingController controller) {
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
              setState(() {
                controller.text = selectedTime.format(context);
              });
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
                    controller.text,
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
      var snapshot = await FirebaseFirestore.instance
          .collection('Sugar Measurements')
          .doc(widget.pCode)
          .collection('BloodSugarReadings')
          .where('type', isEqualTo: 'first')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data();
        String firstMeasurement = data['measurement']['value'].toString();
        setState(() {
          firstMeasurementController.text = firstMeasurement;
        });
      }
    } catch (e) {
      _showAlertDialog("Error loading data: $e");
    }
  }

  void _saveMeasurements({required bool isFirst}) async {
    String value = isFirst ? firstMeasurementController.text : secondMeasurementController.text;

    if (!_validateMeasurement(value)) return;

    try {
      await FirebaseFirestore.instance
          .collection('Sugar Measurements')
          .doc(widget.pCode)
          .collection('BloodSugarReadings')
          .add({ //
        'pCode': widget.pCode,
        'measurement': {
          'value': int.parse(value),
          'time': isFirst ? widget.firstTime : widget.secondTime,
          'type': isFirst ? 'first' : 'second',
        },
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showSuccessMessage("${isFirst ? "First" : "Second"} Measurement saved successfully!");
    } catch (e) {
      _showAlertDialog("Error saving data: $e");
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
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color: Colors.black54),
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

            SizedBox(height: 10),

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
    return StatefulBuilder(
      builder: (context, setState) {
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
                    onChanged: (value) {
                      setState(() {}); // تحديث لعرض القيمة الجديدة
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Entered: ${controller.text}',
              style: TextStyle(fontSize: 20, color: Colors.black87),
            ),
          ],
        );
      },
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