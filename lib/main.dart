import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:wesalvatore/provider/themeprovider.dart';
import 'package:wesalvatore/provider/user_provider.dart';
import 'package:wesalvatore/splash_screen.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await storage.write(
      key: "BASE_URL", value: "https://wesalvator.com/api/accounts");

  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ThemeProvider()), // Theme Provider
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(camera: firstCamera),
    ),
  );
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'WeSalvatore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      home: SplashScreen(),
      //home: UserDashBoardScreen(),
    );
  }
}
