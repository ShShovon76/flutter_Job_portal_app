import 'dart:convert';

import 'package:job_portal_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _accessToken = 'accessToken';
  static const _refreshToken = 'refreshToken';

  static Future<void> saveTokens(
      String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessToken, accessToken);
    await prefs.setString(_refreshToken, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshToken);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
class UserStorage {
  static const _currentUserKey = 'currentUser';

  static Future<void> save(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _currentUserKey,
      jsonEncode(user.toJson()),
    );
  }

  static Future<User?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_currentUserKey);
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
}