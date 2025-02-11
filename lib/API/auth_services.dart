import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static DatabaseReference get _databaseRef => FirebaseDatabase.instance.ref();

  // Sign in method
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } catch (e) {
      // ignore: avoid_print
      print("Error signing in: $e");
      return null;
    }
  }

  // Sign up method
  Future<String?> signUp(
      String username, String email, String password, String usertype) async {
    try {
      // Create user with email and password
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If user creation is successful, store additional data in Realtime Database
      if (userCredential.user != null) {
        await _databaseRef.child('users').child(userCredential.user!.uid).set({
          'username': username,
          'email': email,
          'usertype': usertype,
          'createdAt': DateTime.now().toString(),
        });
        return 'Sign up successful!';
      }
      return 'Error: Unable to create user';
    } on FirebaseAuthException catch (e) {
      return 'Error: ${e.message}';
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Sign out method
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get user type
  Future<String?> getUserType(String uid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc['userType'];
    }
    return null;
  }
}
