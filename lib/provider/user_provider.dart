import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String? _username;
  String? _userType;
  String? _authToken;

  String? get username => _username;
  String? get userType => _userType;
  String? get authToken => _authToken;

  void setUser(String username, String userType, String authToken) {
    _username = username;
    _userType = userType;
    _authToken = authToken;
    notifyListeners();
  }

  void logout() {
    _username = null;
    _userType = null;
    _authToken = null;
    notifyListeners();
  }
}
