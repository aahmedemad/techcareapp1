import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingScreen extends StatefulWidget {
  final String pCode;
  const TrackingScreen({super.key, required this.pCode});

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  static const CameraPosition _kInitialCameraPosition = CameraPosition(
    target: LatLng(30.0444, 31.2357), // القاهرة
    zoom: 15.0,
  );

  StreamSubscription<QuerySnapshot>? _patientLocationSubscription;

  @override
  void initState() {
    super.initState();
    _loadPatientLocation();
    _subscribeToPatientLocation();
  }

  void _subscribeToPatientLocation() {
    _patientLocationSubscription = FirebaseFirestore.instance
        .collection('users')
        .where('P-code', isEqualTo: widget.pCode)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        double latitude = data['latitude'];
        double longitude = data['longitude'];
        Timestamp lastUpdated = data['lastUpdated'] ?? Timestamp.now();

        LatLng patientLocation = LatLng(latitude, longitude);
        _moveCameraToLocation(patientLocation);
        _updatePatientMarker(patientLocation, lastUpdated);
      }
    });
  }

  Future<void> _loadPatientLocation() async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('P-code', isEqualTo: widget.pCode)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data() as Map<String, dynamic>;
        double latitude = data['latitude'];
        double longitude = data['longitude'];
        LatLng patientLocation = LatLng(latitude, longitude);

        _moveCameraToLocation(patientLocation);
        _addPatientMarker(patientLocation);
      }
    } catch (e) {
      print("Error fetching patient location: $e");
    }
  }

  void _moveCameraToLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 17.0,
        ),
      ),
    );
  }

  void _addPatientMarker(LatLng location) {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('patient_location'),
          position: location,
          infoWindow: const InfoWindow(title: 'موقع المريض'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  void _updatePatientMarker(LatLng location, Timestamp lastUpdated) {
    final formattedTime = TimeOfDay.fromDateTime(lastUpdated.toDate()).format(context);

    setState(() {
      _markers.removeWhere((marker) => marker.markerId == MarkerId('patient_location'));
      _markers.add(
        Marker(
          markerId: const MarkerId('patient_location'),
          position: location,
          infoWindow: InfoWindow(
            title: 'موقع المريض',
            snippet: 'آخر تحديث: $formattedTime',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  @override
  void dispose() {
    _patientLocationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: Color(0xFFE8883C),
          leading: SizedBox.shrink(),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 100.0),
                      child: Text(
                        "Tracking",
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
      body: GoogleMap(
        initialCameraPosition: _kInitialCameraPosition,
        markers: _markers,
        myLocationEnabled: false, //  الموقع الحالي
        myLocationButtonEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }
}