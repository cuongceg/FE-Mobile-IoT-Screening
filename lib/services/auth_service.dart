import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../network/api_urls.dart';

class AuthService{
  late final FlutterSecureStorage storage;
  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );
  AuthService() {
    storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
  }

  Future<void> saveToken(String userID,String username,String accessToken,String accessTokenExpiry) async {
    await storage.write(key: 'userID', value: userID);
    await storage.write(key: 'username', value: username);
    await storage.write(key: 'accessToken', value: accessToken);
    await storage.write(key: 'accessTokenExpiry', value: accessTokenExpiry);
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'username');
    await storage.delete(key: 'userID');
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'accessTokenExpiry');
  }

  Future<String?> getUserID() async {
    return await storage.read(key: 'userID');
  }

  Future<String?> getUsername() async{
    return await storage.read(key: 'username');
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  Future<bool> isTokenExpired() async {
    String? expiryAt = await storage.read(key: "accessTokenExpiry");

    if (expiryAt != null) {
      DateTime expiryTime = DateTime.parse(expiryAt);
      return DateTime.now().isAfter(expiryTime);
    }
    return true; // Assume expired if no expiry time is stored
  }

  Future<Map<String,dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(Uri.parse(loginURL),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "username": username,
            "password": password,
          })
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String userID = data['user_id'];
        String username = data['username'];
        String accessToken = data['token']['access_token'];
        String accessTokenExpiry = data['token']['expiry_at'];
        debugPrint("LOGIN SUCCESSFUL");
        await saveToken(userID,username, accessToken, accessTokenExpiry);
        return data;
      }
      debugPrint("LOGIN FAILED");
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
    } catch (e) {
      debugPrint(e.toString().toUpperCase());
      return null;
    }
    return null;
  }

  Future<void> logout() async {
    await deleteToken();
  }
}