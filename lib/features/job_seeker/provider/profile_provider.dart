
import 'package:flutter/foundation.dart';
import 'package:job_portal_app/core/api/job-seeker_profile_api.dart';
import 'package:job_portal_app/models/analytics_models.dart';
import 'package:job_portal_app/models/job_search_filter.dart';
import 'package:job_portal_app/models/job_seeker_profile.dart';

class JobSeekerProfileProvider extends ChangeNotifier {
  JobSeekerProfile? _profile;
  JobSeekerDashboardResponse? _dashboard;
  Pagination<JobSeekerProfile>? _searchResult;
  bool _isLoading = false;
  String? _error;

  // ==========================
  // GETTERS
  // ==========================
  JobSeekerProfile? get profile => _profile;
  JobSeekerDashboardResponse? get dashboard => _dashboard;
  Pagination<JobSeekerProfile>? get searchResult => _searchResult;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ==========================
  // INTERNAL LOADING STATE
  // ==========================
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? err) {
    _error = err;
    notifyListeners();
  }

  void _setProfile(JobSeekerProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void _setDashboard(JobSeekerDashboardResponse dashboard) {
    _dashboard = dashboard;
    notifyListeners();
  }

  void _setSearchResult(Pagination<JobSeekerProfile> result) {
    _searchResult = result;
    notifyListeners();
  }

  // ==========================
  // LOAD PROFILE
  // GET /profile/{userId}
  // ==========================
  Future<void> loadProfile(int userId) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await JobSeekerProfileApi.getProfile(userId);
      _setProfile(result);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  Future<void> saveProfile(int userId, JobSeekerProfile profile) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await JobSeekerProfileApi.saveProfile(userId, profile);
      _setProfile(result);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // ==========================
  // DASHBOARD
  // GET /{userId}/dashboard
  // ==========================
  Future<void> loadDashboard(int userId) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await JobSeekerProfileApi.getDashboard(userId);
      _setDashboard(result);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // ==========================
  // SEARCH PROFILES
  // GET /search
  // ==========================
  Future<void> searchProfiles({
    String? keyword,
    int page = 0,
    int size = 10,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await JobSeekerProfileApi.searchProfiles(
        keyword: keyword,
        page: page,
        size: size,
      );
      _setSearchResult(result);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // ==========================
  // EDUCATION CRUD
  // ==========================
  Future<void> addEducation(int userId, Education edu) async {
    try {
      final created = await JobSeekerProfileApi.addEducation(userId, edu);
      _profile?.education.add(created);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateEducation(int userId, int eduId, Education edu) async {
    try {
      final updated = await JobSeekerProfileApi.updateEducation(
        userId,
        eduId,
        edu,
      );
      final index = _profile!.education.indexWhere((e) => e.hashCode == eduId);
      if (index != -1) {
        _profile!.education[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadEducations(int userId) async {
    try {
      final list = await JobSeekerProfileApi.getEducations(userId);
      _profile = _profile?.copyWith(education: list) ?? _profile;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ==========================
  // EXPERIENCE CRUD
  // ==========================
  Future<void> addExperience(int userId, Experience exp) async {
    try {
      final created = await JobSeekerProfileApi.addExperience(userId, exp);
      _profile?.experience.add(created);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateExperience(int userId, int expId, Experience exp) async {
    try {
      final updated = await JobSeekerProfileApi.updateExperience(
        userId,
        expId,
        exp,
      );
      final index = _profile!.experience.indexWhere((e) => e.hashCode == expId);
      if (index != -1) {
        _profile!.experience[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteExperience(int userId, int expId) async {
    try {
      await JobSeekerProfileApi.deleteExperience(userId, expId);
      _profile?.experience.removeWhere((e) => e.hashCode == expId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadExperiences(int userId) async {
    try {
      final list = await JobSeekerProfileApi.getExperiences(userId);
      _profile = _profile?.copyWith(experience: list) ?? _profile;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ==========================
  // CERTIFICATIONS CRUD
  // ==========================
  Future<void> addCertification(int userId, Certification cert) async {
    try {
      final created = await JobSeekerProfileApi.addCertification(userId, cert);
      _profile?.certifications.add(created);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateCertification(
    int userId,
    int certId,
    Certification cert,
  ) async {
    try {
      final updated = await JobSeekerProfileApi.updateCertification(
        userId,
        certId,
        cert,
      );
      final index = _profile!.certifications.indexWhere(
        (c) => c.hashCode == certId,
      );
      if (index != -1) {
        _profile!.certifications[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteCertification(int userId, int certId) async {
    try {
      await JobSeekerProfileApi.deleteCertification(userId, certId);
      _profile?.certifications.removeWhere((c) => c.hashCode == certId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadCertifications(int userId) async {
    try {
      final list = await JobSeekerProfileApi.getCertifications(userId);
      _profile = _profile?.copyWith(certifications: list) ?? _profile;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
}
