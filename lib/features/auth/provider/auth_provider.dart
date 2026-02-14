

import 'package:flutter/material.dart';
import 'package:job_portal_app/core/api/auth_api.dart';
import 'package:job_portal_app/core/services/storage_service.dart';
import 'package:job_portal_app/models/auth_models.dart';
import 'package:job_portal_app/models/user_model.dart';
import 'package:job_portal_app/routes/route_names.dart';

// auth_provider.dart
class AuthProvider with ChangeNotifier {
  User? user;
  bool isLoading = false;
  bool isInitialized = false;

  bool get isAuthenticated => user != null;
  UserRole? get userRole => user?.role;

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await AuthApi.login(
        AuthRequest(email: email, password: password),
      );

      await TokenStorage.saveTokens(
        response.accessToken,
        response.refreshToken,
      );

      user = response.user;
      await UserStorage.save(user!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerJobSeeker(
    String fullName,
    String email,
    String password,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await AuthApi.registerJobSeeker(
        RegisterJobSeekerRequest(
          fullName: fullName,
          email: email,
          password: password,
        ),
      );

      await TokenStorage.saveTokens(
        response.accessToken,
        response.refreshToken,
      );

      user = response.user;
      await UserStorage.save(user!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerEmployer(
    String fullName,
    String email,
    String password,
    String companyName,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await AuthApi.registerEmployer(
        RegisterEmployerRequest(
          fullName: fullName,
          email: email,
          password: password,
          companyName: companyName,
        ),
      );

      await TokenStorage.saveTokens(
        response.accessToken,
        response.refreshToken,
      );

      user = response.user;
      await UserStorage.save(user!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await TokenStorage.clear();
    await UserStorage.clear();
    user = null;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final token = await TokenStorage.getAccessToken();

    if (token == null) {
      await logout();
      isInitialized = true;
      return;
    }

    final storedUser = await UserStorage.get();
    if (storedUser == null) {
      await logout();
    } else {
      user = storedUser;
    }

    isInitialized = true;
    notifyListeners();
  }

  String getRoleBasedRoute() {
    if (!isAuthenticated) return RouteNames.login;

    switch (user!.role) {
      case UserRole.JOB_SEEKER:
        return RouteNames.jobSeekerShell;
      case UserRole.EMPLOYER:
        return RouteNames.employerShell;
      case UserRole.ADMIN:
        return RouteNames.adminShell;
        default:
        return RouteNames.login;
    }
  }
}

