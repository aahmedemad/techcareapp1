  import 'dart:async';

  import 'package:flutter/material.dart';
  import 'package:google_maps_flutter/google_maps_flutter.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';

  class TrackingScreen extends StatefulWidget {
    final String pCode;
    const TrackingScreen({super.key,required this.pCode});

    @override
    _TrackingScreenState createState() => _TrackingScreenState();
  }

  class _TrackingScreenState extends State<TrackingScreen> {
    GoogleMapController? _mapController;
    final Set<Marker> _markers = {};
    LatLng? _currentLocation;
    bool _isTracking = true;
    StreamSubscription<Position>? _positionStreamSubscription;

    static const CameraPosition _kInitialCameraPosition = CameraPosition(
      target: LatLng(30.0444, 31.2357), //  موقع القاهرة
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
          LatLng patientLocation = LatLng(latitude, longitude);

          _moveCameraToLocation(patientLocation);
          _updatePatientMarker(patientLocation);
        }
      });
    }

    void _updatePatientMarker(LatLng location) {
      setState(() {
        _markers.removeWhere((marker) => marker.markerId == MarkerId('patient_location'));
        _markers.add(
          Marker(
            markerId: MarkerId('patient_location'),
            position: location,
            infoWindow: const InfoWindow(title: 'موقع المريض'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
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

    Future<void> _getCurrentLocation() async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        _currentLocation = LatLng(position.latitude, position.longitude);
        _moveCameraToLocation(_currentLocation!);
        _addCurrentUserMarker(_currentLocation!);
        if (_isTracking) {
          _startLocationTracking();
        }
      } catch (e) {
        print("Error getting location: $e");
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

    void _addCurrentUserMarker(LatLng location) {
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: location,
            infoWindow: const InfoWindow(title: 'موقعي الحالي'),
          ),
        );
      });
    }

    void _startLocationTracking() {
      final locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        if (_isTracking) {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _moveCameraToLocation(_currentLocation!);
          _updateCurrentUserMarker(_currentLocation!);
        }
      });
    }

    void _stopLocationTracking() {
      _positionStreamSubscription?.cancel();
    }

    void _updateCurrentUserMarker(LatLng location) {
      setState(() {
        _markers.removeWhere((marker) => marker.markerId == const MarkerId('current_location'));
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: location,
            infoWindow: const InfoWindow(title: 'موقعي الحالي'),
          ),
        );
      });
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

    @override
    void dispose() {
      _stopLocationTracking();
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
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
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
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _kInitialCameraPosition,
              markers: _markers,
              myLocationEnabled: _isTracking,
              myLocationButtonEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
            Positioned(
              bottom: 90,
              right: 16,
              child: FloatingActionButton(
                heroTag: "center_location",
                onPressed: () {
                  if (_currentLocation != null) {
                    _moveCameraToLocation(_currentLocation!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("الموقع الحالي غير متوفر بعد")),
                    );
                  }
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: Color(0xFFE8883C)),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "tracking_toggle",
          onPressed: () {
            setState(() {
              _isTracking = !_isTracking;
              if (_isTracking) {
                _startLocationTracking();
              } else {
                _stopLocationTracking();
              }
            });
          },
          child: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
          backgroundColor: Color(0xFFE8883C),
        ),
      );
    }
  }