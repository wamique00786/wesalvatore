import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedUserType;
  final bool _isLoading = false; // Loading state

  void _signup() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String phone = _phoneController.text.trim();
    String? userType = _selectedUserType;

    if (email.isEmpty ||
        password.isEmpty ||
        phone.isEmpty ||
        userType == null) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      return;
    }
    if (password != confirmPassword) {
      Fluttertoast.showToast(msg: "Passwords do not match");
      return;
    }

    var response = await authService.signup(email, password, phone, userType);

    if (response.containsKey("error")) {
      Fluttertoast.showToast(msg: response["error"]); // Show API error message
    } else {
      print(response);
      Fluttertoast.showToast(msg: "Signup successful! Please login.");
      Navigator.pop(context); // Close the signup screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/plainyellow.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Sign Up",
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[900],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(Icons.email, "Email", _emailController),
                const SizedBox(height: 10),
                _buildTextField(Icons.lock, "Password", _passwordController,
                    isPassword: true),
                const SizedBox(height: 10),
                _buildTextField(
                    Icons.lock, "Confirm Password", _confirmPasswordController,
                    isPassword: true),
                const SizedBox(height: 10),
                _buildTextField(Icons.phone, "Phone", _phoneController),
                const SizedBox(height: 10),
                _buildDropdownField(Icons.person, "Select User Type"),
                const SizedBox(height: 20),
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Colors.teal[900]) // Show loading spinner
                      : _buildButton("Sign Up", Colors.teal[900]!, _signup),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      IconData icon, String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
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

  Widget _buildDropdownField(IconData icon, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedUserType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.teal[900]),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.85)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        dropdownColor: Colors.white,
        style: TextStyle(color: Colors.black),
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

  Widget _buildButton(String text, Color color, void Function() signup) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
      ),
      onPressed: signup,
      child: Text(text,
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
    );
  }
}
