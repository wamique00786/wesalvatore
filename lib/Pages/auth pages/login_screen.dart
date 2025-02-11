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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Image (Ensure image is inside "assets" folder and listed in pubspec.yaml)
          Positioned.fill(
            child: Image.asset("assets/backgroundimg.jpg", // Correct path
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.modulate),
          ),

          Container(
            color: Colors.black
                .withOpacity(0.01), // Dark overlay for better readability
          ),

          Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 45),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    "Welcome to Rescue Animals",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.teal[900],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email Input
                  _buildTextField(Icons.email, "Email"),
                  const SizedBox(height: 15),

                  // Password Input
                  _buildTextField(Icons.lock, "Password", isPassword: true),

                  // Forgot Password
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
                  const SizedBox(height: 20),

                  // Login Button
                  _buildButton("Login", Colors.teal[900]!, () {
                    // Handle login logic here
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashBoardScreen(),
                        ));
                  }),
                  const SizedBox(height: 20),

                  // Social Login
                  Text("Or login with",
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.white)),
                  const SizedBox(height: 15),
                  _buildSocialButtons(),
                  const SizedBox(height: 20),

                  // Sign Up
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
          ),
        ],
      ),
    );
  }

  // Standard TextField
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
        fillColor: Colors.white.withOpacity(0.2), // Soft white background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Login Button
  Widget _buildButton(String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 80),
        elevation: 6,
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
      ),
    );
  }

  // Social Login Buttons
  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIconButton(
          "assets/icon/apple.png",
        ),
        const SizedBox(width: 15),
        _buildIconButton(
          "assets/icon/google.png",
        ),
        const SizedBox(width: 15),
        _buildIconButton(
          "assets/icon/facebook.png",
        ),
      ],
    );
  }

  // Social Login Icons
  Widget _buildIconButton(
    String asset,
  ) {
    return GestureDetector(
      onTap: () {
        // Handle social login here
      },
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
