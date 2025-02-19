import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wesalvatore/splash_screen.dart';
import 'package:wesalvatore/Volunteer/volunteer_dashboard.dart';
import 'package:wesalvatore/views/user_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  LocationPermission permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeSalvatore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, primary: Colors.teal[900]),
        useMaterial3: true,
      ),
      //home: VolunteerDashboard(),
      // home: UserDashBoardScreen()
      home: SplashScreen(),
    );
  }
}
