import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'choose_pharmacy_screen.dart';
import 'addres_screen.dart';

class OrderMethodScreen extends StatelessWidget {
  final String pCode;
  final Map<String, dynamic> prescriptionData;
  final String selectedPharmacy;

  const OrderMethodScreen({
    required this.pCode,
    required this.prescriptionData,
    required this.selectedPharmacy,
  });

  Future<void> _sendOrderToFirestore(String orderMethod, BuildContext context) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      await FirebaseFirestore.instance.collection('PharmacyOrders').add({
        'pCode': pCode,
        'prescription': prescriptionData,
        'pharmacy': selectedPharmacy,
        'orderMethod': orderMethod,
        'orderDate': Timestamp.now(),
      });

      // إغلاق مؤشر التحميل
      Navigator.pop(context);

      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order sent to pharmacy successfully!')),
      );

      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ChooseFarmacyScreen(pCode: pCode, prescriptionData: prescriptionData),
          ),
              (Route<dynamic> route) => false,
        );
      });
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending order: $e')),
      );
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
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChooseFarmacyScreen(pCode: pCode, prescriptionData: prescriptionData)),
                              (Route<dynamic> route) => false,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50.0),
                      child: Text(
                        "Choose Pharmacy",
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'How Would You Like To Receive Your Order?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 70),
            // Pick Up Option
            Card(
              elevation: 5,
              color: Color(0xFFCAD6FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () {
                  _sendOrderToFirestore('Pick Up', context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_shipping, color: Colors.black),
                      SizedBox(width: 10),
                      Text(
                        'Pick Up',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 50),
            // Delivery Option
            Card(
              elevation: 5,
              color: Color(0xFFCAD6FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnterAddressScreen(
                        pCode: pCode,
                        prescriptionData: prescriptionData,
                        selectedPharmacy: selectedPharmacy,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delivery_dining, color: Colors.black),
                      SizedBox(width: 10),
                      Text(
                        'Delivery',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}