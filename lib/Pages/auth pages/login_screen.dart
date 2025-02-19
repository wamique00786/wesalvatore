import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../views/user_dashboard_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

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

  // Save auth token to local storage
  void _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
  }

  // Handle login
  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty || _selectedUserType == null) {
      Fluttertoast.showToast(
          msg: "Please fill all fields and select user type");
      return;
    }

    final Uri loginUrl = Uri.parse(
        "https://fb95-2409-40e3-3155-731-8ec-8191-1ca9-13a8.ngrok-free.app/api/accounts/login/");

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

      // Check if response is empty
      if (response.body.isEmpty) {
        Fluttertoast.showToast(msg: "Error: Empty response from server.");
        return;
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData.containsKey("token")) {
        _saveToken(responseData["token"]);
        Fluttertoast.showToast(msg: "Login successful!");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserDashBoardScreen()),
        );
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backgroundimg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Welcome to Rescue Animals",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: constraints.maxWidth * 0.12,
                      fontWeight: FontWeight.w900,
                      color: Colors.teal[900],
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),
                  _buildTextField(
                      Icons.person, "Username", _usernameController),
                  SizedBox(height: constraints.maxHeight * 0.01),
                  _buildTextField(Icons.lock, "Password", _passwordController,
                      isPassword: true),
                  SizedBox(height: constraints.maxHeight * 0.015),
                  _buildDropdownField(Icons.person, "Select User Type"),
                  SizedBox(height: constraints.maxHeight * 0.01),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.01),
                  _buildButton(
                      "Login", Colors.teal[900]!, _login, constraints.maxWidth),
                  SizedBox(height: constraints.maxHeight * 0.03),
                  Text("Or login with",
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.white)),
                  SizedBox(height: constraints.maxHeight * 0.015),
                  _buildSocialButtons(),
                  SizedBox(height: constraints.maxHeight * 0.01),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupScreen()),
                      );
                    },
                    child: Text(
                      "New here? Sign Up",
                      style: GoogleFonts.poppins(
                        color: Colors.teal[300],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton(
      String text, Color color, VoidCallback onTap, double width) {
    return SizedBox(
      width: width * 0.7,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 16),
          elevation: 6,
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDropdownField(IconData icon, String hint) {
    return DropdownButtonFormField<String>(
      value: _selectedUserType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal[300]),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: Colors.white.withOpacity(0.9),
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

  Widget _buildTextField(
      IconData icon, String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal[300]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIconButton("assets/icon/google.png", () {}),
      ],
    );
  }

  Widget _buildIconButton(String asset, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(asset, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
