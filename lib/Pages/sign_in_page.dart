import 'package:flutter/material.dart';
//import 'package:wesalvatore/Volunteer/volunteer_dashboard.dart';
import 'package:wesalvatore/forgot_screen.dart';
import 'package:wesalvatore/Pages/sign_up_page.dart';
//import 'package:wesalvatore/views/dashboard_screen.dart';
//import 'package:wesalvatore/Admin/admin_dashboard.dart';
import 'package:lottie/lottie.dart';
import 'package:wesalvatore/views/dashboard_screen.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  // Add controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedUserType;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = constraints.biggest;
        final isSmallScreen = screenSize.width < 600;

        // Updated padding calculations
        final double horizontalPadding = screenSize.width * 0.08;
        final double topPadding = screenSize.height * 0.12;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black45, Colors.black12],
            ),
          ),
          child: Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  // Top Heading Section
                  Container(
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      top:
                          isSmallScreen ? screenSize.height * 0.08 : topPadding,
                      right: horizontalPadding,
                    ),
                    child: Text(
                      'Hello\nSign in!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isSmallScreen
                            ? screenSize.width * 0.08
                            : screenSize.width * 0.04,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Lottie Animation Background
                  Positioned.fill(
                    child: Lottie.asset(
                      'assets/background_animation.json', // Replace with your animation file
                      fit: BoxFit.cover, // Covers entire screen
                    ),
                  ),

                  // Form Section
                  SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.only(
                        top: screenSize.height * 0.45,
                        right: horizontalPadding,
                        left: horizontalPadding,
                      ),
                      child: Column(
                        children: [
                          // Username TextField with updated design
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              fillColor: Colors.white.withOpacity(0.9),
                              filled: true,
                              hintText: 'Username',
                              prefixIcon:
                                  Icon(Icons.person, color: Color(0xff4c505b)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: Color(0xff4c505b), width: 2),
                              ),
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.02),

                          // Password TextField with updated design
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              fillColor: Colors.white.withOpacity(0.9),
                              filled: true,
                              hintText: 'Password',
                              prefixIcon:
                                  Icon(Icons.lock, color: Color(0xff4c505b)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: Color(0xff4c505b), width: 2),
                              ),
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.02),

                          // User Type Dropdown with updated design
                          DropdownButtonFormField<String>(
                            value: _selectedUserType,
                            decoration: InputDecoration(
                              fillColor: Colors.white.withOpacity(0.9),
                              filled: true,
                              hintText: 'User Type',
                              prefixIcon:
                                  Icon(Icons.people, color: Color(0xff4c505b)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: Color(0xff4c505b), width: 2),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'User', child: Text('User')),
                              DropdownMenuItem(
                                  value: 'Admin', child: Text('Admin')),
                              DropdownMenuItem(
                                  value: 'Volunteer', child: Text('Volunteer')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedUserType = value;
                              });
                            },
                          ),
                          SizedBox(height: screenSize.height * 0.04),

                          SizedBox(height: isSmallScreen ? 20 : 30),

                          // Updated Sign In Button Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Color(0xff4c505b),
                                  fontSize: isSmallScreen ? 24 : 30,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xff4c505b),
                                      Color(0xff4c505b).withOpacity(0.8)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 4),
                                      blurRadius: 5.0,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: isSmallScreen ? 25 : 30,
                                  backgroundColor: Colors.transparent,
                                  child: IconButton(
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DashBoardScreen(),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.arrow_forward),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 30),

                          // Sign Up and Forgot Password Links
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignUpPage(),
                                      ));
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: isSmallScreen ? 16 : 18,
                                    color: Color(0xff4c505b),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPasswordScreen(),
                                      ));
                                },
                                child: Text(
                                  'Forgot Password',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: isSmallScreen ? 16 : 18,
                                    color: Color(0xff4c505b),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
