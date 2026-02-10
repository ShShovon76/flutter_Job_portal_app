import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/core/services/storage_service.dart';


class ApiClient {
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    return _sendRequest(
      () => http.post,
      endpoint,
      body: body,
      auth: auth,
    );
  }

  static Future<http.Response> get(
    String endpoint, {
    bool auth = false,
  }) async {
    return _sendRequest(
      () => http.get,
      endpoint,
      auth: auth,
    );
  }

  static Future<http.Response> _sendRequest(
    Function requestFn,
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final headers = {'Content-Type': 'application/json'};

    if (auth) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    http.Response response = await requestFn()(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    // 🔁 AUTO REFRESH
    if (response.statusCode == 401 && auth) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final newToken = await TokenStorage.getAccessToken();
        headers['Authorization'] = 'Bearer $newToken';

        response = await requestFn()(
          Uri.parse('${AppConstants.baseUrl}$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      }
    }

    return response;
  }

  static Future<bool> _refreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      await TokenStorage.saveTokens(
        json['accessToken'],
        refreshToken,
      );
      return true;
    }

    await TokenStorage.clear();
    return false;
  }
}