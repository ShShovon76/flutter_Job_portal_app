import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/core/services/storage_service.dart';

class ApiClient {
  static bool _isRefreshing = false;
  static Completer<bool>? _refreshCompleter;

  // ---------------------------
  // GET
  // ---------------------------
  static Future<http.Response> get(
    String endpoint, {
    bool auth = false,
  }) {
    return _sendRequest(
      method: 'GET',
      endpoint: endpoint,
      auth: auth,
    );
  }

  // ---------------------------
  // POST
  // ---------------------------
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) {
    return _sendRequest(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      auth: auth,
    );
  }

  // ---------------------------
  // PUT
  // ---------------------------
  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) {
    return _sendRequest(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      auth: auth,
    );
  }

  // ---------------------------
  // DELETE
  // ---------------------------
  static Future<http.Response> delete(
    String endpoint, {
    bool auth = false,
  }) {
    return _sendRequest(
      method: 'DELETE',
      endpoint: endpoint,
      auth: auth,
    );
  }

  // ---------------------------
  // CORE REQUEST HANDLER
  // ---------------------------
  static Future<http.Response> _sendRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (auth) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    http.Response response;

    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }
    } catch (_) {
      throw Exception('Network error. Check internet connection.');
    }

    // 🔁 Auto refresh token
    if (response.statusCode == 401 && auth) {
      final refreshed = await _handleRefreshToken();
      if (refreshed) {
        return _sendRequest(
          method: method,
          endpoint: endpoint,
          body: body,
          auth: auth,
        );
      }
    }

    return response;
  }

  // ---------------------------
  // MULTIPART
  // ---------------------------
 static Future<http.StreamedResponse> multipart(
  String method,
  String endpoint, {
  Map<String, String>? fields,          // for @RequestParam String
  Map<String, dynamic>? jsonData,       // for @RequestPart JSON
  Map<String, File>? files,             // for MultipartFile
  bool auth = true,
}) async {
  final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
  final request = http.MultipartRequest(method, uri);

  if (auth) {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
  }

  // @RequestParam fields
  if (fields != null) {
    request.fields.addAll(fields);
  }

  // @RequestPart JSON
  if (jsonData != null) {
    request.files.add(
      http.MultipartFile.fromString(
        'data',
        jsonEncode(jsonData),
        contentType: MediaType('application', 'json'),
      ),
    );
  }

  // Files
  if (files != null) {
    for (final entry in files.entries) {
      request.files.add(
        await http.MultipartFile.fromPath(
          entry.key,
          entry.value.path,
        ),
      );
    }
  }

  final response = await request.send();
  return response;
}


  // ---------------------------
  // REFRESH TOKEN HANDLER
  // ---------------------------
  static Future<bool> _handleRefreshToken() async {
    if (_isRefreshing) {
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final refreshed = await _refreshToken();
      _refreshCompleter!.complete(refreshed);
      return refreshed;
    } catch (_) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  static Future<bool> _refreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) {
      await TokenStorage.clear();
      return false;
    }

    try {
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
    } catch (_) {}

    await TokenStorage.clear();
    return false;
  }
}
