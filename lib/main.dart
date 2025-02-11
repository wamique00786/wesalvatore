import 'package:flutter/material.dart';
import 'package:wesalvatore/Pages/sign_in_page.dart';
import 'package:wesalvatore/Pages/sign_up_page.dart';
import 'package:wesalvatore/Pages/splash_screen.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint("Firebase initialized successfully!");
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFE0B2),
                    Color(0xFFB2DFDB)
                  ], // Soft peach & mint
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 40),
                buildButton(context, 'Sign In', Icons.login_rounded,
                    Colors.white, Colors.deepPurple, SignInPage()),
                const SizedBox(height: 20),
                buildButton(context, 'Sign Up', Icons.person_add_rounded,
                    Colors.white, Colors.blueAccent, SignUpPage()),
                const SizedBox(height: 20),
                buildGoogleButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, String text, IconData icon,
      Color bgColor, Color textColor, Widget page) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGoogleButton(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement Google Sign-In
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.google,
              size: 20,
            ),
            const SizedBox(width: 10),
            const Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
