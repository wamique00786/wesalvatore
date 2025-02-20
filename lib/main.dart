import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wesalvatore/Admin/admin_dashboard.dart';

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
      // theme: ThemeData(
      //   colorScheme: const ColorScheme.light(
      //     primary: Color(0xFF4CAF50),
      //     secondary: Color(0xFFFF9800),
      //     background: Color(0xFFF5F5F5),
      //     surface: Colors.white,
      //     error: Color(0xFFF44336),
      //     onPrimary: Colors.white,
      //     onSecondary: Colors.black,
      //     onBackground: Colors.black,
      //     onSurface: Colors.black,
      //     onError: Colors.white,
      //   ),
      //   useMaterial3: true,
      // ),
      // darkTheme: ThemeData(
      //   colorScheme: const ColorScheme.dark(
      //     primary: Color(0xFF66BB6A),
      //     secondary: Color(0xFFFFA726),
      //     background: Color(0xFF121212),
      //     surface: Color(0xFF1E1E1E),
      //     error: Color(0xFFEF5350),
      //     onPrimary: Colors.black,
      //     onSecondary: Colors.black,
      //     onBackground: Colors.white,
      //     onSurface: Colors.white,
      //     onError: Colors.black,
      //   ),
      //   useMaterial3: true,
      // ),
      themeMode: ThemeMode.system, // System default, can be .light or .dark
      home: const AdminDashboard(),
    );
  }
}
