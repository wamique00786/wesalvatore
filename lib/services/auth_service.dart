import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl =
      "https://c218-2409-40e3-48-e232-dd14-2ff6-4d3b-da82.ngrok-free.app/api/accounts";

  // Login Function
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Invalid credentials"};
      }
    } catch (e) {
      return {"error": "Network error. Please try again."};
    }
  }

  // Signup Function
  Future<Map<String, dynamic>> signup(
      String email, String password, String phone, String userType) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "phone": phone,
          "user_type": userType,
        }),
      );

      // Print response for debugging
      print("Signup Response Code: ${response.statusCode}");
      print("Signup Response Body: ${response.body}");

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return jsonDecode(response.body); // Return the API error message
      }
    } catch (e) {
      print("Signup Error: $e");
      return {"error": "Signup failed. Please try again."};
    }
  }

  // Password Reset Function
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/password_reset/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        return {"success": "Password reset link sent"};
      } else {
        return jsonDecode(response.body);
      }
    } catch (e) {
      return {"error": "Error sending reset email"};
    }
  }
}
