import 'package:flutter/material.dart';
import 'package:wesalvatore/forgot_screen.dart';
import 'package:wesalvatore/sign_up.dart';
import 'package:wesalvatore/views/dashboard_screen.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    // Get the screen size and scale factor

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600; // Mobile screen size

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/login.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Top Heading Section
            Container(
              padding: EdgeInsets.only(
                left: isSmallScreen ? 20 : 55,
                top: isSmallScreen ? 100 : 170,
              ),
              child: Text(
                'Hello\n Sign in!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 24 : 33,
                ),
              ),
            ),

            // Form Section
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  top: screenSize.height * 0.5,
                  right: 35,
                  left: 35,
                ),
                child: Column(
                  children: [
                    // Username TextField
                    TextField(
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 15),

                    // Password TextField
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // User Type Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'User Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'User', child: Text('User')),
                        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                        DropdownMenuItem(
                            value: 'Volunteer', child: Text('Volunteer')),
                      ],
                      onChanged: (value) {},
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 15),

                    SizedBox(height: isSmallScreen ? 20 : 30),

                    // Sign In Button Section
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
                        CircleAvatar(
                          radius: isSmallScreen ? 25 : 30,
                          backgroundColor: Color(0xff4c505b),
                          child: IconButton(
                            color: Colors.white,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DashBoardScreen(),
                                  ));
                            },
                            icon: Icon(Icons.arrow_forward),
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
                                  builder: (context) => ForgotPasswordScreen(),
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
    );
  }
}
