// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../views/dashboard_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/backgroundimg.jpg",
                fit: BoxFit.cover, colorBlendMode: BlendMode.modulate),
          ),
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 24,
              vertical: isSmallScreen ? 30 : 45,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Welcome to Rescue Animals",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 32 : (isMediumScreen ? 40 : 48),
                    fontWeight: FontWeight.w900,
                    color: Colors.teal[900],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 30),
                _buildTextField(Icons.email, "Email"),
                SizedBox(height: isSmallScreen ? 10 : 15),
                _buildTextField(Icons.lock, "Password", isPassword: true),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 15 : 20),
                _buildButton(
                    "Login", Colors.teal[900]!, screenSize, isSmallScreen, () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashBoardScreen(),
                    ),
                  );
                }),
                SizedBox(height: isSmallScreen ? 15 : 20),
                Text(
                  "Or login with",
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 10 : 15),
                _buildSocialButtons(),
                SizedBox(height: isSmallScreen ? 15 : 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
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
        ],
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint,
      {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword ? _obscurePassword : false,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: InputBorder.none,
        prefixIcon: Icon(icon, color: Colors.teal[300]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withOpacity(0.8),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, Size screenSize,
      bool isSmallScreen, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: screenSize.width * (isSmallScreen ? 0.15 : 0.2),
        ),
        elevation: 6,
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIconButton("assets/icon/apple.png"),
        SizedBox(width: 15),
        _buildIconButton("assets/icon/google.png"),
        SizedBox(width: 15),
        _buildIconButton("assets/icon/facebook.png"),
      ],
    );
  }

  Widget _buildIconButton(String asset) {
    return GestureDetector(
      onTap: () {},
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Image.asset(asset, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
