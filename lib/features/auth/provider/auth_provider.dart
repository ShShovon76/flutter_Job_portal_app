import 'package:flutter/material.dart';
import 'package:job_portal_app/core/api/auth_api.dart';
import 'package:job_portal_app/core/services/storage_service.dart';
import 'package:job_portal_app/models/auth_models.dart';
import 'package:job_portal_app/models/user_model.dart';


class AuthProvider with ChangeNotifier {
  User? user;
  bool isLoading = false;

  bool get isAuthenticated => user != null;

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    final response = await AuthApi.login(
      AuthRequest(email: email, password: password),
    );

    await TokenStorage.saveTokens(
        response.accessToken, response.refreshToken);

    user = response.user;
    isLoading = false;
    notifyListeners();
  }

  Future<void> registerJobSeeker(
      String fullName, String email, String password) async {
    isLoading = true;
    notifyListeners();

    final response = await AuthApi.registerJobSeeker(
      RegisterJobSeekerRequest(
        fullName: fullName,
        email: email,
        password: password,
      ),
    );

    await TokenStorage.saveTokens(
        response.accessToken, response.refreshToken);

    user = response.user;
    isLoading = false;
    notifyListeners();
  }

  Future<void> registerEmployer(
    String fullName,
    String email,
    String password,
    String companyName,
  ) async {
    isLoading = true;
    notifyListeners();

    final response = await AuthApi.registerEmployer(
      RegisterEmployerRequest(
        fullName: fullName,
        email: email,
        password: password,
        companyName: companyName,
      ),
    );

    await TokenStorage.saveTokens(
        response.accessToken, response.refreshToken);

    user = response.user;
    isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await TokenStorage.clear();
    user = null;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
  final token = await TokenStorage.getAccessToken();
  if (token == null) return;

  // Optional: decode token or call /me API
  notifyListeners();
}

}
