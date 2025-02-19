import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl =
      "https://fb95-2409-40e3-3155-731-8ec-8191-1ca9-13a8.ngrok-free.app/api/accounts";

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

  Future<Map<String, dynamic>> signup(
      String username,
      String email,
      String password,
      String confirmPassword,
      String phone,
      String userType) async {
    try {
      final response = await http.post(
        Uri.parse(
            "https://fb95-2409-40e3-3155-731-8ec-8191-1ca9-13a8.ngrok-free.app/api/accounts/signup/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
          "password2": confirmPassword, // API requires this
          "mobile_number": phone, // API expects 'mobile_number', not 'phone'
          "user_type": userType,
        }),
      );

      print("Signup Response Code: ${response.statusCode}");
      print("Signup Response Body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return jsonDecode(response.body); // API error details
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
