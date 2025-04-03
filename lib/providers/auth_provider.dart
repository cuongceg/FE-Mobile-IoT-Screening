import 'package:flutter/material.dart';
import 'package:speech_to_text_iot_screen/services/auth_service.dart';
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _accessToken;
  String? _username;
  String? _userId;
  String _state = "initial";
  String? _errorMessage;
  bool _isHidePassword = true;

  String? get accessToken => _accessToken;
  String? get username => _username;
  String? get userId => _userId;
  String get state => _state;
  String? get error => _errorMessage;

  bool get isAuthenticated => _accessToken != null;
  bool get isHidePassword => _isHidePassword;

  Future<void> login(String username, String password) async {
    _state = 'loading';
    notifyListeners();
    try{
      final data = await _authService.login(username, password);
      if (data != null) {
        _username = data["username"];
        _userId = data["user_id"];
        _accessToken = data["token"]["access_token"];
      }
      debugPrint("Access Token: $_accessToken");
      _state = 'initial';
    }catch(e){
      _state = 'error';
      _errorMessage = e.toString();
    }
    notifyListeners();
    return;
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

  Future<void> forgotPassword(String email) async {
    _state = 'loading';
    notifyListeners();
    try{
      // await _authService.forgotPassword(email);
      // Simulate a network call
      await Future.delayed(const Duration(seconds: 2));
      _state = 'initial';
    }catch(e){
      _state = 'error';
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> resetPassword({required String newPassword,required String resetToken}) async {
    _state = 'loading';
    notifyListeners();
    try{
      await _authService.resetPassword(newPassword: newPassword,resetToken: resetToken);
      _state = 'initial';
    }catch(e){
      _state = 'error';
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isHidePassword = !_isHidePassword;
    notifyListeners();
  }
}
