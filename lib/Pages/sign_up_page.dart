import 'package:flutter/material.dart';
import 'package:wesalvatore/forgot_screen.dart';
import 'package:wesalvatore/Pages/sign_in_page.dart';
import 'package:wesalvatore/API/auth_services.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usertypeController = TextEditingController();

  void _signUp() async {
    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String usertype = _usertypeController.text.trim();

    final String? message = await FirebaseAuthServices()
        .signUp(username, email, password, usertype);

    if (message == 'Sign up successful!') {
      Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => SignInPage()));
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message!),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade900, Colors.blueAccent.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Your\nAccount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  _buildTextField('Username', _usernameController),
                  _buildTextField('Email', _emailController),
                  _buildTextField('Password', _passwordController,
                      isPassword: true),
                  _buildDropdown(),
                  SizedBox(height: screenHeight * 0.03),
                  _buildSignUpButton(),
                  SizedBox(height: screenHeight * 0.03),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        items: const [
          DropdownMenuItem(value: 'User', child: Text('User')),
          DropdownMenuItem(value: 'Admin', child: Text('Admin')),
          DropdownMenuItem(value: 'Volunteer', child: Text('Volunteer')),
        ],
        onChanged: (value) {
          _usertypeController.text = value!;
        },
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _signUp,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Colors.blueAccent.shade700,
          elevation: 5,
        ),
        child: Text(
          'Sign Up',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SignInPage())),
          child: Text(
            'Sign In',
            style: TextStyle(
                decoration: TextDecoration.underline, color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => ForgotPasswordScreen())),
          child: Text(
            'Forgot Password',
            style: TextStyle(
                decoration: TextDecoration.underline, color: Colors.white),
          ),
        )
      ],
    );
  }
}
