import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/models/job_search_filter.dart';
import 'package:job_portal_app/models/user_model.dart';

class UserApi {
  static const String _base = "/users";

  // ================================
  // GET USER BY ID
  // ================================
  static Future<User> getUserById(int id) async {
    final res = await ApiClient.get("$_base/$id", auth: true);

    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    }
    throw Exception("Failed to fetch user");
  }

  // ================================
  // GET USER BY EMAIL
  // ================================
  static Future<User> getUserByEmail(String email) async {
    final res = await ApiClient.get("$_base/email/$email", auth: true);

    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    }
    throw Exception("Failed to fetch user by email");
  }

  // ================================
  // GET USERS (PAGINATED)
  // ================================
  static Future<Pagination<User>> getUsers({
    int page = 0,
    int size = 10,
  }) async {
    final res = await ApiClient.get(
      "$_base?page=$page&size=$size",
      auth: true,
    );

    if (res.statusCode == 200) {
      return Pagination.fromJson(
        jsonDecode(res.body),
        (json) => User.fromJson(json),
      );
    }

    throw Exception("Failed to fetch users");
  }

  // ================================
  // SEARCH USERS
  // ================================
  static Future<Pagination<User>> searchUsers({
    String? keyword,
    String? role,
    bool? enabled,
    int page = 0,
    int size = 10,
  }) async {
    final query = {
      if (keyword != null) "keyword": keyword,
      if (role != null) "role": role,
      if (enabled != null) "enabled": enabled.toString(),
      "page": page.toString(),
      "size": size.toString(),
    };

    final uriQuery = Uri(queryParameters: query).query;

    final res = await ApiClient.get(
      "$_base/search?$uriQuery",
      auth: true,
    );

    if (res.statusCode == 200) {
      return Pagination.fromJson(
        jsonDecode(res.body),
        (json) => User.fromJson(json),
      );
    }

    throw Exception("Failed to search users");
  }

  // ================================
  // UPDATE USER
  // ================================
  static Future<User> updateUser(
    int id,
    Map<String, dynamic> data,
  ) async {
    final res = await ApiClient.put(
      "$_base/$id",
      body: data,
      auth: true,
    );

    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    }

    throw Exception("Failed to update user");
  }

  // ================================
  // CHANGE PASSWORD
  // ================================
  static Future<void> changePassword(
    int id,
    String currentPassword,
    String newPassword,
  ) async {
    final res = await ApiClient.put(
      "$_base/$id/change-password",
      body: {
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      },
      auth: true,
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to change password");
    }
  }

  // ================================
  // DELETE USER
  // ================================
  static Future<void> deleteUser(int id) async {
    final res = await ApiClient.delete(
      "$_base/$id",
      auth: true,
    );

    if (res.statusCode != 204) {
      throw Exception("Failed to delete user");
    }
  }

  // ================================
  // ENABLE / DISABLE USER
  // ================================
  static Future<void> enableUser(
    int id,
    bool enabled,
  ) async {
    final res = await ApiClient.put(
      "$_base/$id/enable?enabled=$enabled",
      auth: true,
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update user status");
    }
  }

  // ================================
  // COUNT USERS BY ROLE
  // ================================
  static Future<int> countUsersByRole(String role) async {
    final res = await ApiClient.get(
      "$_base/count-by-role?role=$role",
      auth: true,
    );

    if (res.statusCode == 200) {
      return int.parse(res.body);
    }

    throw Exception("Failed to count users");
  }

  // ================================
  // UPLOAD PROFILE PICTURE
  // ================================
  static Future<User> uploadProfilePicture(
    int id,
    File file,
  ) async {
    final streamed = await ApiClient.multipart(
      "POST",
      "$_base/$id/profile-picture",
      files: {"file": file},
      auth: true,
    );

    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }

    throw Exception("Failed to upload profile picture");
  }
}