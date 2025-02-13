// import 'package:flutter/material.dart';
// import 'package:wesalvatore/forgot_screen.dart';
// import 'package:wesalvatore/sign_in.dart';

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});

//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//           image: DecorationImage(
//               image: AssetImage('assets/register.png'), fit: BoxFit.cover)),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: Stack(
//           children: [
//             Container(
//               padding: EdgeInsets.only(left: 55, top: 130),
//               child: Text(
//                 'Create Your\n Account',
//                 style: TextStyle(color: Colors.white, fontSize: 33),
//               ),
//             ),
//             SingleChildScrollView(
//               child: Container(
//                 padding: EdgeInsets.only(
//                     top: MediaQuery.of(context).size.height * 0.3,
//                     right: 35,
//                     left: 35),
//                 child: Column(
//                   children: [
//                     TextField(
//                       decoration: InputDecoration(
//                           fillColor: Colors.grey.shade100,
//                           filled: true,
//                           hintText: 'username',
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10))),
//                     ),
//                     SizedBox(
//                       height: 15,
//                     ),
//                     TextField(
//                       decoration: InputDecoration(
//                           fillColor: Colors.grey.shade100,
//                           filled: true,
//                           hintText: 'Email',
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10))),
//                     ),
//                     SizedBox(
//                       height: 15,
//                     ),
//                     TextField(
//                       decoration: InputDecoration(
//                           fillColor: Colors.grey.shade100,
//                           filled: true,
//                           hintText: 'Mobile Number',
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10))),
//                     ),
//                     SizedBox(
//                       height: 15,
//                     ),
//                     TextField(
//                       obscureText: true,
//                       decoration: InputDecoration(
//                           fillColor: Colors.grey.shade100,
//                           filled: true,
//                           hintText: 'Password',
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10))),
//                     ),
//                     SizedBox(
//                       height: 15,
//                     ),
//                     DropdownButtonFormField<String>(
//                       decoration: InputDecoration(
//                           fillColor: Colors.grey.shade100,
//                           filled: true,
//                           hintText: 'User Type',
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10))),
//                       items: const [
//                         DropdownMenuItem(value: 'User', child: Text('User')),
//                         DropdownMenuItem(value: 'Admin', child: Text('Admin')),
//                         DropdownMenuItem(
//                             value: 'Volunteer', child: Text('Volunteer'))
//                       ],
//                       onChanged: (value) {},
//                     ),
//                     SizedBox(
//                       height: 15,
//                     ),
//                     TextField(
//                       obscureText: true,
//                       decoration: InputDecoration(
//                           fillColor: Colors.grey.shade100,
//                           filled: true,
//                           hintText: 'Confirm Password',
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10))),
//                     ),
//                     SizedBox(
//                       height: 30,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Sign Up',
//                           style: TextStyle(
//                               color: Color(0xff4c505b),
//                               fontSize: 30,
//                               fontWeight: FontWeight.w700),
//                         ),
//                         CircleAvatar(
//                           radius: 30,
//                           backgroundColor: Color(0xff4c505b),
//                           child: IconButton(
//                               color: Colors.white,
//                               onPressed: () {},
//                               icon: Icon(Icons.arrow_forward)),
//                         )
//                       ],
//                     ),
//                     SizedBox(
//                       height: 30,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => SignIn(),
//                                   ));
//                             },
//                             child: Text(
//                               'Sign In',
//                               style: TextStyle(
//                                   decoration: TextDecoration.underline,
//                                   fontSize: 18,
//                                   color: Color(0xff4c505b)),
//                             )),
//                         TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         ForgotPasswordScreen(),
//                                   ));
//                             },
//                             child: Text(
//                               'Forgot Password',
//                               style: TextStyle(
//                                   decoration: TextDecoration.underline,
//                                   fontSize: 18,
//                                   color: Color(0xff4c505b)),
//                             ))
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
