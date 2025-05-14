import 'package:flutter/material.dart';
import 'package:techcareapp1/notification_screen.dart';
import 'choose_screen.dart';
import 'medicine_reminder_screen.dart';
import 'setting_screen.dart';
import 'choose_clinics.dart';
import 'pharmacy_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techcareapp1/reminder_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'add_doctor_request.dart';
import 'my_doctor.dart';
class HomeScreen extends StatefulWidget {
  final String pCode;

  HomeScreen({required this.pCode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String patientName = '';

  @override
  void initState() {
    super.initState();
    fetchPatientName();
    _startLiveLocationUpdates();
    _sendLocationToFirestore(widget.pCode);
  }

  Future<void> _sendLocationToFirestore(String pCode) async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .where('P-code', isEqualTo: pCode)
        .get()
        .then((query) {
      if (query.docs.isNotEmpty) {
        query.docs.first.reference.update({
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      }
    });
  }

  void fetchPatientName() async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('P-code', isEqualTo: widget.pCode)
          .where('role', isEqualTo: 'patient')
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data() as Map<String, dynamic>;
        setState(() {
          patientName = "${data['firstName']} ${data['lastName']}";
        });
      } else {
        setState(() {
          patientName = 'Unknown';
        });
      }
    } catch (e) {
      print("Error fetching name: $e");
      setState(() {
        patientName = 'Error';
      });
    }
  }
  
  void _startLiveLocationUpdates() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).listen((Position position) {
        FirebaseFirestore.instance.collection('users').where('P-code', isEqualTo: widget.pCode).get().then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            String userId = querySnapshot.docs.first.id;
            FirebaseFirestore.instance.collection('users').doc(userId).update({
              'latitude': position.latitude,
              'longitude': position.longitude,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160),
        child: Container(
          color: Color(0xFF2260FF),
          child: Column(
            children: [
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage('images/image 32.jpg'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, Welcome Back",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(height: 5),
                            Text(
                             patientName.isEmpty ? "Loading... " : patientName,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "P-Code: ${widget.pCode}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('images/image 11.jpg'),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Patient",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            GestureDetector(
                              onTap:(){
                                Navigator.push(context,
                                MaterialPageRoute(builder: (context)=> ReminderScreen (pCode: widget.pCode)),);
                  },
                             child:  Icon(Icons.notifications, color: Colors.white, size: 28),
                            ),
                            SizedBox(width: 20),
                            GestureDetector(
                              onTap:(){
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (context)=> SettingsScreen(userRole: 'patient',)),);
                              },
                              child: Icon(Icons.settings, color: Colors.white, size: 28),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [

          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChooseScreen(pCode: widget.pCode)),
                  );
                },
                child: buildFeatureCard('images/image 28.jpg', "Enter Measurements"),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MedicineReminderScreen(pCode: widget.pCode)),
                  );
                },
                child: buildFeatureCard('images/image 29.jpg', "Medicine's Reminder"),
              ),
            ],
          ),
          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChooseClinicScreen(pCode: widget.pCode)),
                  );
                },
                child: buildFeatureCard('images/image 30.jpg', "Clinics"),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PharmacyScreen(pCode:widget.pCode)),
                  );
                },
                child: buildFeatureCard('images/image 31.jpg', "Pharmacy"),
              ),
            ],
          ),
          Spacer(),
          BottomNavigationBarWidget(pCode: widget.pCode ,patientName: patientName,),
        ],
      ),
    );
  }

  Widget buildFeatureCard(String imagePath, String title) {
    return Container(
      width: 160,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 95,
            height: 95,
            fit: BoxFit.cover,
          ),
          Container(
            width: 130,
            height: 45,
            decoration: BoxDecoration(
              color: Color(0x9E2260FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final String pCode;
  final String patientName;
  const BottomNavigationBarWidget({required this.pCode , required this.patientName});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        margin: EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          color: Color(0xFF2260FF),
          borderRadius: BorderRadius.circular(35),
        ),
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen (pCode: pCode)),
                );

              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddDoctorScreen(pCode: pCode ,patientName: patientName,)),
                );

              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyDoctorScreen (pCode: pCode)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.black, size: 30),
              onPressed: () {

              },
            ),
          ],
        ),
      ),
    );
  }
}







/*import 'package:flutter/material.dart';
import 'package:techcareapp1/notification_screen.dart';
import 'choose_screen.dart';
import 'medicine_reminder_screen.dart';
import 'setting_screen.dart';
import 'choose_clinics.dart';
import 'pharmacy_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techcareapp1/reminder_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'add_doctor_request.dart';
import 'my_doctor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:workmanager/workmanager.dart';

// 1. Background task handler for WorkManager (works even when app is terminated)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Get pCode from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final pCode = prefs.getString('user_pcode');

      if (pCode == null) {
        print("No pCode found in SharedPreferences");
        return true;
      }

      print("Headless task triggered for pCode: $pCode");

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("Headless location update: ${position.latitude}, ${position.longitude}");

      // Update Firestore with new location
      await FirebaseFirestore.instance
          .collection('users')
          .where('P-code', isEqualTo: pCode)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          String userId = querySnapshot.docs.first.id;
          FirebaseFirestore.instance.collection('users').doc(userId).update({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'lastUpdated': FieldValue.serverTimestamp(),
            'updateSource': 'headless_task', // Indicates update came from terminated app
          });
          print("Location updated in Firestore from headless task");
        }
      });

      return true;
    } catch (e) {
      print("Error in headless task: $e");
      return false;
    }
  });
}

// 2. Background service handler for foreground service (when app is in background)
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Get stored pCode
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? pCode = prefs.getString('user_pcode');

  if (pCode == null) {
    print("No pCode found in SharedPreferences");
    return;
  }

  print("Background service started with pCode: $pCode");

  // This timer runs our location updates periodically
  Timer.periodic(Duration(seconds: 30), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        // Update the foreground service notification
        service.setForegroundNotificationInfo(
          title: "TechCare App",
          content: "Monitoring your location in background",
        );
      }
    }

    // Get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("Background location update: ${position.latitude}, ${position.longitude}");

      // Update Firestore with new location
      await FirebaseFirestore.instance
          .collection('users')
          .where('P-code', isEqualTo: pCode)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          String userId = querySnapshot.docs.first.id;
          FirebaseFirestore.instance.collection('users').doc(userId).update({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'lastUpdated': FieldValue.serverTimestamp(),
            'updateSource': 'foreground_service', // Indicates update came from background app
          });
          print("Location updated in Firestore from foreground service");
        }
      });

    } catch (e) {
      print("Error updating location in background: $e");
    }
  });
}

// iOS background handler
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

class HomeScreen extends StatefulWidget {
  final String pCode;

  HomeScreen({required this.pCode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String patientName = '';
  StreamSubscription<Position>? _positionStreamSubscription;
  final FlutterBackgroundService _backgroundService = FlutterBackgroundService();
  bool _isServiceRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _savePCodeToPrefs(); // First save pCode for background tasks
    _initializeWorkManager(); // Initialize headless task for terminated app
    _initializeService(); // Initialize foreground service for background app
    fetchPatientName();
    _startLiveLocationUpdates();
    _sendLocationToFirestore(widget.pCode);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // Save pCode for background service to use
  Future<void> _savePCodeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pcode', widget.pCode);
    print("Saved pCode to SharedPreferences: ${widget.pCode}");
  }

  // Initialize WorkManager for headless tasks (when app is terminated)
  void _initializeWorkManager() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    // Register periodic task
    await Workmanager().registerPeriodicTask(
      'locationUpdaterTask',
      'locationUpdater',
      frequency: Duration(minutes: 15), // Minimum interval for Android
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      initialDelay: Duration(seconds: 10),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: Duration(minutes: 1),
    );

    // For iOS, register a background fetch task
    if (Platform.isIOS) {
      await Workmanager().registerOneOffTask(
        'iosBackgroundFetch',
        'backgroundFetch',
        initialDelay: Duration(seconds: 10),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    }

    print("WorkManager initialized for headless tasks");
  }

  // Initialize the background service and notification
  Future<void> _initializeService() async {
    // Setup notification channel for Android
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'techcare_location_channel', // id
        'Location Tracking', // title
        description: 'Used for location tracking service', // description
        importance: Importance.low,
      );

      // Fixed syntax error for createNotificationChannel
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // Configure the background service
    await _backgroundService.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'techcare_location_channel',
        initialNotificationTitle: 'TechCare App',
        initialNotificationContent: 'Location Monitoring Active',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    print("Background service initialized");
  }

  // Check if the service is running
  Future<bool> _isServiceRunningCheck() async {
    return await _backgroundService.isRunning();
  }

  // Start the background service
  Future<void> _startBackgroundService() async {
    bool isRunning = await _isServiceRunningCheck();
    if (!isRunning) {
      // Fixed method call for startService
      await _backgroundService.startService();
      _isServiceRunning = true;
      print("Background service started");
    } else {
      print("Background service already running");
    }
  }

  // Stop the background service
  Future<void> _stopBackgroundService() async {
    bool isRunning = await _isServiceRunningCheck();
    if (isRunning) {
      // Fixed method call for stopService
      _backgroundService.invoke("stopService");
      _isServiceRunning = false;
      print("Background service stopped");
    } else {
      print("Background service already stopped");
    }
  }

  // App lifecycle state change handler
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      // App is in background
      print("App is in background - starting foreground service");
      _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
      _startBackgroundService();

    } else if (state == AppLifecycleState.resumed) {
      // App is in foreground
      print("App is in foreground - stopping foreground service");
      _stopBackgroundService();
      _startLiveLocationUpdates();
    }
  }

  // One-time location update
  Future<void> _sendLocationToFirestore(String pCode) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("Sending initial location to Firestore: ${position.latitude}, ${position.longitude}");

      await FirebaseFirestore.instance
          .collection('users')
          .where('P-code', isEqualTo: pCode)
          .get()
          .then((query) {
        if (query.docs.isNotEmpty) {
          query.docs.first.reference.update({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'lastUpdated': FieldValue.serverTimestamp(),
            'updateSource': 'foreground_app', // Indicates update came from active app
          });
          print("Initial location updated in Firestore");
        }
      });
    } catch (e) {
      print("Error sending location to Firestore: $e");
    }
  }

  // Fetch patient name from Firestore
  void fetchPatientName() async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('P-code', isEqualTo: widget.pCode)
          .where('role', isEqualTo: 'patient')
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data() as Map<String, dynamic>;
        setState(() {
          patientName = "${data['firstName']} ${data['lastName']}";
        });
        print("Patient name fetched: $patientName");
      } else {
        setState(() {
          patientName = 'Unknown';
        });
        print("No patient found with pCode: ${widget.pCode}");
      }
    } catch (e) {
      print("Error fetching name: $e");
      setState(() {
        patientName = 'Error';
      });
    }
  }

  // Start location updates when app is in foreground
  void _startLiveLocationUpdates() async {
    print("Starting live location updates");

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      print("Location permission requested: $permission");
    }

    // Request background location permission
    if (permission == LocationPermission.whileInUse) {
      try {
        permission = await Geolocator.requestPermission();
        print("Background location permission requested: $permission");
      } catch (e) {
        print("Error requesting background permission: $e");
      }
    }

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      // Cancel existing subscription if any
      await _positionStreamSubscription?.cancel();

      // Start new position stream
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        print("Live position update: ${position.latitude}, ${position.longitude}");

        FirebaseFirestore.instance
            .collection('users')
            .where('P-code', isEqualTo: widget.pCode)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            String userId = querySnapshot.docs.first.id;
            FirebaseFirestore.instance.collection('users').doc(userId).update({
              'latitude': position.latitude,
              'longitude': position.longitude,
              'lastUpdated': FieldValue.serverTimestamp(),
              'updateSource': 'foreground_app', // Indicates update came from active app
            });
            print("Location updated in Firestore");
          }
        }).catchError((error) {
          print("Error updating location: $error");
        });
      }, onError: (error) {
        print("Error with location stream: $error");
      });

      print("Location stream started");
    } else {
      print("Location permission denied: $permission");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160),
        child: Container(
          color: Color(0xFF2260FF),
          child: Column(
            children: [
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage('images/image 32.jpg'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, Welcome Back",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(height: 5),
                            Text(
                              patientName.isEmpty ? "Loading... " : patientName,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "P-Code: ${widget.pCode}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('images/image 11.jpg'),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Patient",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            GestureDetector(
                              onTap:(){
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (context)=> ReminderScreen (pCode: widget.pCode)),);
                              },
                              child:  Icon(Icons.notifications, color: Colors.white, size: 28),
                            ),
                            SizedBox(width: 20),
                            GestureDetector(
                              onTap:(){
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (context)=> SettingsScreen()),);
                              },
                              child: Icon(Icons.settings, color: Colors.white, size: 28),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChooseScreen(pCode: widget.pCode)),
                  );
                },
                child: buildFeatureCard('images/image 28.jpg', "Enter Measurements"),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MedicineReminderScreen(pCode: widget.pCode)),
                  );
                },
                child: buildFeatureCard('images/image 29.jpg', "Medicine's Reminder"),
              ),
            ],
          ),
          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChooseClinicScreen(pCode: widget.pCode)),
                  );
                },
                child: buildFeatureCard('images/image 30.jpg', "Clinics"),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PharmacyScreen(pCode:widget.pCode)),
                  );
                },
                child: buildFeatureCard('images/image 31.jpg', "Pharmacy"),
              ),
            ],
          ),
          Spacer(),
          BottomNavigationBarWidget(pCode: widget.pCode, patientName: patientName),
        ],
      ),
    );
  }

  Widget buildFeatureCard(String imagePath, String title) {
    return Container(
      width: 160,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 95,
            height: 95,
            fit: BoxFit.cover,
          ),
          Container(
            width: 130,
            height: 45,
            decoration: BoxDecoration(
              color: Color(0x9E2260FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final String pCode;
  final String patientName;
  const BottomNavigationBarWidget({required this.pCode, required this.patientName});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        margin: EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          color: Color(0xFF2260FF),
          borderRadius: BorderRadius.circular(35),
        ),
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(pCode: pCode)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddDoctorScreen(pCode: pCode, patientName: patientName)),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyDoctorScreen(pCode: pCode)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.black, size: 30),
              onPressed: () {
                // Calendar functionality (currently empty)
              },
            ),
          ],
        ),
      ),
    );
  }
}*/