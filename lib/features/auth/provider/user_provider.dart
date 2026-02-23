import 'dart:io';

import 'package:flutter/material.dart';
import 'package:job_portal_app/core/api/user_api.dart';
import 'package:job_portal_app/models/job_search_filter.dart';
import 'package:job_portal_app/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  Pagination<User>? _usersPage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Pagination<User>? get usersPage => _usersPage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  // ================================
  // LOAD USER BY ID
  // ================================
  Future<void> loadUser(int id) async {
    _setLoading(true);
    try {
      _currentUser = await UserApi.getUserById(id);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ================================
  // UPDATE USER
  // ================================
  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      _currentUser = await UserApi.updateUser(id, data);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ================================
  // CHANGE PASSWORD
  // ================================
  Future<void> changePassword(
    int id,
    String currentPassword,
    String newPassword,
  ) async {
    _setLoading(true);
    try {
      await UserApi.changePassword(id, currentPassword, newPassword);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ================================
  // DELETE USER
  // ================================
  Future<void> deleteUser(int id) async {
    _setLoading(true);
    try {
      await UserApi.deleteUser(id);
      _currentUser = null;
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ================================
  // ENABLE USER
  // ================================
  Future<void> enableUser(int id, bool enabled) async {
    _setLoading(true);
    try {
      await UserApi.enableUser(id, enabled);
      if (_currentUser != null) {
        _currentUser =
            _currentUser!.copyWith(enabled: enabled);
      }
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ================================
  // LOAD USERS (ADMIN)
  // ================================
  Future<void> loadUsers({
    int page = 0,
    int size = 10,
  }) async {
    _setLoading(true);
    try {
      _usersPage =
          await UserApi.getUsers(page: page, size: size);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ================================
  // SEARCH USERS
  // ================================
  Future<void> searchUsers({
    String? keyword,
    String? role,
    bool? enabled,
    int page = 0,
    int size = 10,
  }) async {
    _setLoading(true);
    try {
      _usersPage = await UserApi.searchUsers(
        keyword: keyword,
        role: role,
        enabled: enabled,
        page: page,
        size: size,
      );
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ================================
  // COUNT USERS BY ROLE
  // ================================
  Future<int> countUsersByRole(String role) async {
    try {
      return await UserApi.countUsersByRole(role);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // ================================
  // UPLOAD PROFILE PICTURE
  // ================================
  Future<void> uploadProfilePicture(int id, File file) async {
    _setLoading(true);
    try {
      _currentUser =
          await UserApi.uploadProfilePicture(id, file);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}