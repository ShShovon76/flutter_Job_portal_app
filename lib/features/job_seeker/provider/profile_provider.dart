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

  List<JobSeekerProfile> searchResults = [];
int searchPage = 0;
bool hasMoreSearch = true;

Future<void> searchProfiles({
  String? keyword,
  bool refresh = false,
}) async {
  if (refresh) {
    searchPage = 0;
    searchResults.clear();
    hasMoreSearch = true;
  }

  if (!hasMoreSearch) return;

  final result = await JobSeekerProfileApi.searchProfiles(
    keyword: keyword,
    page: searchPage,
  );

  searchResults.addAll(result.items);
  hasMoreSearch = searchPage + 1 < result.totalPages;
  searchPage++;
  notifyListeners();
}


ApplicantProfile? applicantProfile;

Future<void> loadApplicantProfile(int profileId) async {
  _setLoading(true);
  try {
    applicantProfile =
        await JobSeekerProfileApi.getApplicantProfile(profileId);
  } catch (e) {
    _setError(e.toString());
  } finally {
    _setLoading(false);
  }
}

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


  // ===================== CREATE OR UPDATE PROFILE =====================
Future<void> saveProfile(JobSeekerProfile updatedProfile) async {
  _setLoading(true);
  _error = null;

  try {
    final saved = await JobSeekerProfileApi.saveProfile(
      updatedProfile.userId,
      updatedProfile,
    );

    _profile = saved;
    notifyListeners();
  } catch (e) {
    _setError(e.toString());
    rethrow;
  } finally {
    _setLoading(false);
  }
}

// ===================== UPDATE BASIC PROFILE FIELDS =====================
Future<void> updateBasicInfo({
  required String headline,
  required String summary,
  required List<String> skills,
  required List<String> portfolioLinks,
  required List<String> preferredJobTypes,
  required List<String> preferredLocations,
}) async {
  if (_profile == null) return;

  final updated = _profile!.copyWith(
    headline: headline,
    summary: summary,
    skills: skills,
    portfolioLinks: portfolioLinks,
    preferredJobTypes: preferredJobTypes,
    preferredLocations: preferredLocations,
  );

  await saveProfile(updated);
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
        userId: _profile!.userId,
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

  _setLoading(true);

  try {
    final created = await JobSeekerProfileApi.addEducation(
      _profile!.userId,
      education,
    );

    _profile = _profile!.copyWith(
      education: [..._profile!.education, created],
    );
  } catch (e) {
    _setError(e.toString());
  } finally {
    _setLoading(false);
  }
}

  Future<void> updateEducation(int educationId, Education updated) async {
    if (_profile == null) return;

    try {
      final result = await JobSeekerProfileApi.updateEducation(
        _profile!.userId,
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
      await JobSeekerProfileApi.deleteEducation(_profile!.userId, educationId);

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

  Future<void> loadEducations() async {
    if (_profile == null) return;

    try {
      final list = await JobSeekerProfileApi.getEducations(_profile!.userId);

      _profile = _profile!.copyWith(education: list);
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
        _profile!.userId,
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
         _profile!.userId, 
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
      await JobSeekerProfileApi.deleteExperience(_profile!.userId, experienceId);

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

  Future<void> loadExperiences() async {
    if (_profile == null) return;

    try {
      final list = await JobSeekerProfileApi.getExperiences(_profile!.userId);

      _profile = _profile!.copyWith(experience: list);
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
        _profile!.userId,
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
        _profile!.userId,
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
        _profile!.userId,
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

  Future<void> loadCertifications() async {
    if (_profile == null) return;

    try {
      final list = await JobSeekerProfileApi.getCertifications(
        _profile!.userId,
      );

      _profile = _profile!.copyWith(certifications: list);
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
