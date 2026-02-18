import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:job_portal_app/core/api/job-seeker_profile_api.dart';
import 'package:job_portal_app/core/api/profile_api.dart';
import 'package:job_portal_app/core/services/storage_service.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/models/analytics_models.dart';
import 'package:job_portal_app/models/job_seeker_profile.dart';
import 'package:job_portal_app/models/user_model.dart';

class JobSeekerProfileProvider extends ChangeNotifier {
  // ===================== STATE =====================
  JobSeekerProfile? _profile;
  JobSeekerDashboardResponse? _dashboard;
  bool _isLoading = false;
  String? _error;

  // ===================== GETTERS =====================
  JobSeekerProfile? get profile => _profile;
  JobSeekerDashboardResponse? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ===================== HELPERS =====================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ===================== LOAD PROFILE + DASHBOARD =====================
  Future<void> loadProfileAndDashboard(int userId) async {
    _setLoading(true);
    _error = null;

    try {
      final results = await Future.wait([
        JobSeekerProfileApi.getProfile(userId),
        JobSeekerProfileApi.getDashboard(userId),
      ]);

      _profile = results[0] as JobSeekerProfile;
      _dashboard = results[1] as JobSeekerDashboardResponse;
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  // ===================== PROFILE PICTURE UPLOAD =====================
Future<void> uploadProfilePicture({
  required File file,
  required AuthProvider authProvider,
}) async {
  if (_profile == null) return;

  _setLoading(true);

  try {
    // 1️⃣ Upload & get UPDATED USER JSON
    final responseStr = await ProfileApi.uploadProfilePicture(
      userId: _profile!.userId!,
      file: file,
    );

    final Map<String, dynamic> updatedUserJson = jsonDecode(responseStr);

    // 2️⃣ Parse updated user
    final updatedUser = User.fromJson(updatedUserJson);

    // 3️⃣ Update AuthProvider (single source of truth)
    authProvider.user = updatedUser;

    // 4️⃣ Persist locally
    await UserStorage.save(updatedUser);

    authProvider.notifyListeners();
    notifyListeners();

  } catch (e) {
    _setError(e.toString());
    rethrow;
  } finally {
    _setLoading(false);
  }
}

  // ===================== EDUCATION =====================
  Future<void> addEducation(Education education) async {
    if (_profile == null) return;

    try {
      final created = await JobSeekerProfileApi.addEducation(
        _profile!.id,
        education,
      );

      _profile = _profile!.copyWith(
        education: [..._profile!.education, created],
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateEducation(int educationId, Education updated) async {
    if (_profile == null) return;

    try {
      final result = await JobSeekerProfileApi.updateEducation(
        _profile!.id,
        educationId,
        updated,
      );

      _profile = _profile!.copyWith(
        education: _profile!.education
            .map((e) => e.id == educationId ? result : e)
            .toList(),
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteEducation(int educationId) async {
    if (_profile == null) return;

    try {
      await JobSeekerProfileApi.deleteEducation(_profile!.id, educationId);

      _profile = _profile!.copyWith(
        education: _profile!.education
            .where((e) => e.id != educationId)
            .toList(),
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ===================== EXPERIENCE =====================
  Future<void> addExperience(Experience experience) async {
    if (_profile == null) return;

    try {
      final created = await JobSeekerProfileApi.addExperience(
        _profile!.id,
        experience,
      );

      _profile = _profile!.copyWith(
        experience: [..._profile!.experience, created],
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateExperience(int experienceId, Experience updated) async {
    if (_profile == null) return;

    try {
      final result = await JobSeekerProfileApi.updateExperience(
        _profile!.id,
        experienceId,
        updated,
      );

      _profile = _profile!.copyWith(
        experience: _profile!.experience
            .map((e) => e.id == experienceId ? result : e)
            .toList(),
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteExperience(int experienceId) async {
    if (_profile == null) return;

    try {
      await JobSeekerProfileApi.deleteExperience(_profile!.id, experienceId);

      _profile = _profile!.copyWith(
        experience: _profile!.experience
            .where((e) => e.id != experienceId)
            .toList(),
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ===================== CERTIFICATIONS =====================
  Future<void> addCertification(Certification certification) async {
    if (_profile == null) return;

    try {
      final created = await JobSeekerProfileApi.addCertification(
        _profile!.id,
        certification,
      );

      _profile = _profile!.copyWith(
        certifications: [..._profile!.certifications, created],
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateCertification(
    int certificationId,
    Certification updated,
  ) async {
    if (_profile == null) return;

    try {
      final result = await JobSeekerProfileApi.updateCertification(
        _profile!.id,
        certificationId,
        updated,
      );

      _profile = _profile!.copyWith(
        certifications: _profile!.certifications
            .map((c) => c.id == certificationId ? result : c)
            .toList(),
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteCertification(int certificationId) async {
    if (_profile == null) return;

    try {
      await JobSeekerProfileApi.deleteCertification(
        _profile!.id,
        certificationId,
      );

      _profile = _profile!.copyWith(
        certifications: _profile!.certifications
            .where((c) => c.id != certificationId)
            .toList(),
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ===================== CLEAR =====================
  void clearProfile() {
    _profile = null;
    _dashboard = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
