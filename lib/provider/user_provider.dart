import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _username;
  String? _userType;
  String? _authToken;
  String? _profileImagePath;

  String? get username => _username;
  String? get userType => _userType;
  String? get authToken => _authToken;
  String? get profileImagePath =>
      _profileImagePath ?? "assets/user.png"; // Default image

  void setUser(String username, String userType, String authToken) {
    _username = username;
    _userType = userType;
    _authToken = authToken;
    notifyListeners();
  }

  void setProfileImage(String imagePath) {
    _profileImagePath = imagePath;
    notifyListeners();
  }

  void logout() {
    _username = null;
    _userType = null;
    _authToken = null;
    _profileImagePath = null;
    notifyListeners();
  }
}
