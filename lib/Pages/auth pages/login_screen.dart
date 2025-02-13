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
  String? _selectedUserType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevent layout shift when keyboard opens
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backgroundimg.jpg"),
                fit: BoxFit.cover,
                //colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.05),
                // BlendMode.darken), // Reduced opacity
              ),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              //color: Colors.black.withOpacity(0.15), // Reduced overlay opacity
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    "Welcome to Rescue Animals",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: constraints.maxWidth * 0.08,
                      fontWeight: FontWeight.w900,
                      color: Colors.teal[900],
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),

                  // Email Input
                  _buildTextField(Icons.email, "Email"),
                  SizedBox(height: constraints.maxHeight * 0.015),

                  // Password Input
                  _buildTextField(Icons.lock, "Password", isPassword: true),
                  SizedBox(height: constraints.maxHeight * 0.015),

                  // User Type Selection (Now Styled Like Other Input Fields)
                  _buildDropdownField(Icons.person, "Select User Type"),
                  SizedBox(height: constraints.maxHeight * 0.02),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02),

                  // Login Button
                  _buildButton("Login", Colors.teal[900]!, () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DashBoardScreen()),
                    );
                  }),
                  SizedBox(height: constraints.maxHeight * 0.03),

                  // Social Login
                  Text("Or login with",
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.white)),
                  SizedBox(height: constraints.maxHeight * 0.015),
                  _buildSocialButtons(),
                  SizedBox(height: constraints.maxHeight * 0.02),

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
          );
        },
      ),
    );
  }

  // Styled Dropdown (Matches Input Fields)
  Widget _buildDropdownField(IconData icon, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25), // Lighter background for clarity
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedUserType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.teal[300]),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.85)),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        dropdownColor: Colors.black.withOpacity(0.3), // Reduced darkness
        style: TextStyle(color: Colors.white), // White text inside dropdown
        items: const [
          DropdownMenuItem(value: 'User', child: Text('Regular User')),
          DropdownMenuItem(value: 'Admin', child: Text('Admin')),
          DropdownMenuItem(value: 'Volunteer', child: Text('Volunteer')),
        ],
        onChanged: (value) {
          setState(() {
            _selectedUserType = value;
          });
        },
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
        prefixIcon: Icon(icon, color: Colors.teal[300]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withOpacity(0.85),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        hintText: hint,
        hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.85)), // Increased readability
        filled: true,
        fillColor: Colors.white.withOpacity(0.15), // Lighter fill color
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
        _buildIconButton("assets/icon/apple.png"),
        SizedBox(width: 15),
        _buildIconButton("assets/icon/google.png"),
        SizedBox(width: 15),
        _buildIconButton("assets/icon/facebook.png"),
      ],
    );
  }

  // Social Login Icons
  Widget _buildIconButton(String asset) {
    return GestureDetector(
      onTap: () {
        // Handle social login
      },
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
