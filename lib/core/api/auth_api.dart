

import 'dart:convert';
import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/models/auth_models.dart';


class AuthApi {
  static Future<AuthResponse> login(AuthRequest request) async {
    final res = await ApiClient.post(
      '/auth/login',
      body: request.toJson(),
    );

    if (res.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception(res.body);
  }

  static Future<AuthResponse> registerJobSeeker(
      RegisterJobSeekerRequest request) async {
    final res = await ApiClient.post(
      '/auth/register/job-seeker',
      body: request.toJson(),
    );

    if (res.statusCode == 201) {
      return AuthResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception(res.body);
  }

  static Future<AuthResponse> registerEmployer(
      RegisterEmployerRequest request) async {
    final res = await ApiClient.post(
      '/auth/register/employer',
      body: request.toJson(),
    );

    if (res.statusCode == 201) {
      return AuthResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception(res.body);
  }
}
