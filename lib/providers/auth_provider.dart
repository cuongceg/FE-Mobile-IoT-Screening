import 'package:flutter/material.dart';
import 'package:speech_to_text_iot_screen/services/auth_service.dart';
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _accessToken;
  String? _username;
  String? _userId;
  String _state = "initial";

  String? get accessToken => _accessToken;
  String? get username => _username;
  String? get userId => _userId;
  String get state => _state;

  bool get isAuthenticated => _accessToken != null;

  Future<void> login(String username, String password) async {
    _state = 'loading';
    notifyListeners();
    final data = await _authService.login(username, password);

    if (data != null) {
      _username = data["username"];
      _userId = data["user_id"];
      _accessToken = data["token"]["access_token"];
    }
    _state = 'initial';
    notifyListeners();
    if(_accessToken != null){
      debugPrint("LOGIN SUCCESSFUL");
    }else{
      debugPrint("LOGIN FAILED");
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _accessToken = null;
    _username = null;
    _userId = null;

    notifyListeners();
  }

  Future<void> loadUser() async {
    bool isExpired = await _authService.isTokenExpired();

    if (isExpired) {
      logout(); // Clear user data
      return;
    }

    _accessToken = await _authService.getAccessToken();
    _username = await _authService.getUsername();
    _userId = await _authService.getUserID();

    notifyListeners();
  }
}
