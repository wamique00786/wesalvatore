import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:wesalvatore/Admin/admin_dashboard.dart';
import 'package:wesalvatore/Volunteer/volunteer_dashboard.dart';
import 'package:wesalvatore/auth%20pages/forgot_password_screen.dart';
import 'package:wesalvatore/auth%20pages/signup_screen.dart';
import 'package:wesalvatore/provider/user_provider.dart';
import 'package:wesalvatore/user/user_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedUserType;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<String?> getBaseUrl() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: "BASE_URL");
  }

  void _login(BuildContext context) async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty || _selectedUserType == null) {
      Fluttertoast.showToast(
          msg: "Please fill all fields and select user type");
      return;
    }
    final String? baseUrl = await getBaseUrl();
    final Uri loginUrl = Uri.parse("$baseUrl/login/");
    print(loginUrl);
    try {
      final response = await http.post(
        loginUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
          "user_type": _selectedUserType
        }),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.body.isEmpty) {
        Fluttertoast.showToast(msg: "Error: Empty response from server.");
        return;
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData.containsKey("token")) {
        String token = responseData["token"];
        String userType = responseData["user_type"];

        Provider.of<UserProvider>(context, listen: false)
            .setUser(username, userType, token);

        Fluttertoast.showToast(msg: "Login successful!");

        if (userType == "ADMIN") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => AdminDashboard()));
        } else if (userType == "USER") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => UserDashBoardScreen()));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => VolunteerDashboard()));
        }
      } else {
        Fluttertoast.showToast(
            msg: responseData["error"] ?? "Invalid login credentials");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backgroundimg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Login Form
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to Rescue Animals",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.w900,
                      color: Colors.teal[900],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  _buildTextField(
                      Icons.person, "Username", _usernameController),
                  SizedBox(height: screenHeight * 0.02),
                  _buildTextField(Icons.lock, "Password", _passwordController,
                      isPassword: true),
                  SizedBox(height: screenHeight * 0.02),
                  _buildDropdownField(Icons.person, "Select User Type"),

                  // Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen()));
                      },
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.teal[900]),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),
                  _buildButton("Login", Colors.teal[900]!,
                      () => _login(context), screenWidth),

                  // Sign Up Button
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupScreen()));
                    },
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      IconData icon, String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal[300]),
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.teal[300]),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildDropdownField(IconData icon, String hint) {
    return DropdownButtonFormField<String>(
      value: _selectedUserType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal[300]),
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'USER', child: Text('Regular User')),
        DropdownMenuItem(value: 'ADMIN', child: Text('Administrator')),
        DropdownMenuItem(value: 'VOLUNTEER', child: Text('Volunteer')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedUserType = value;
        });
      },
    );
  }

  Widget _buildButton(
      String text, Color color, VoidCallback onPressed, double width) {
    return SizedBox(
      width: width * 0.8,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
