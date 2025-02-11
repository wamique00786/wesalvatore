import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFD1E8E2),
        appBar: AppBar(
          title:
              Text("Sign Up", style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.teal[900],
        ),
        body: Stack(
          children: [
            Positioned.fill(
                child: Image.asset(
              "assets/plainyellow.jpg",
              fit: BoxFit.cover,
            )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 45,
                  ),
                  _buildTextField(Icons.email, "Email"),
                  SizedBox(height: 10),
                  _buildTextField(Icons.lock, "Password", isPassword: true),
                  SizedBox(height: 10),
                  _buildTextField(Icons.lock, "Confirm Password",
                      isPassword: true),
                  SizedBox(height: 10),
                  _buildTextField(Icons.phone, "Phone"),
                  SizedBox(height: 20),
                  _buildButton("Sign Up", Colors.teal[900]!),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildTextField(IconData icon, String hint,
      {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal[900]),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
      ),
      onPressed: () {},
      child: Text(text,
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
    );
  }
}
