import 'dart:convert';

import 'package:job_portal_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessToken = 'accessToken';
  static const _refreshToken = 'refreshToken';

  static final FlutterSecureStorage _storage =
      const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    await _storage.write(key: _accessToken, value: accessToken);
    await _storage.write(key: _refreshToken, value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return _storage.read(key: _accessToken);
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshToken);
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
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