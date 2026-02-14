import 'package:flutter/material.dart';
import 'package:job_portal_app/core/api/aplication_api.dart';
import 'package:job_portal_app/models/application_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';

class JobApplicationProvider with ChangeNotifier {
  // =============================
  // STATE
  // =============================

  Pagination<JobApplication>? _pagination;
  final List<JobApplication> _applications = [];

  JobApplication? _selectedApplication;
  List<ApplicationStatusHistory> _history = [];

  bool _isLoading = false;
  bool _isFetchingMore = false;
  String? _error;

  int _page = 0;
  final int _size = 10;
  bool _hasMore = true;

  // =============================
  // GETTERS
  // =============================

  List<JobApplication> get applications => _applications;
  Pagination<JobApplication>? get pagination => _pagination;

  JobApplication? get selectedApplication => _selectedApplication;
  List<ApplicationStatusHistory> get history => _history;

  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  // =============================
  // INTERNAL HELPERS
  // =============================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setFetchingMore(bool value) {
    _isFetchingMore = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void _resetPagination() {
    _page = 0;
    _hasMore = true;
    _applications.clear();
    _pagination = null;
  }

  // =============================
  // FETCH BY JOB
  // =============================

  Future<void> fetchByJob({
    required int jobId,
    bool refresh = false,
  }) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    if (refresh) {
      _resetPagination();
      _setLoading(true);
    } else {
      _setFetchingMore(true);
    }

    try {
      final result = await JobApplicationApi.getByJob(
        jobId: jobId,
        page: _page,
        size: _size,
      );

      _pagination = result;
      _applications.addAll(result.items);
      _hasMore = _page + 1 < result.totalPages;
      _page++;

      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
      _setFetchingMore(false);
    }
  }

  // =============================
  // FETCH BY JOB SEEKER
  // =============================

  Future<void> fetchByJobSeeker({
    required int userId,
    bool refresh = false,
  }) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    if (refresh) {
      _resetPagination();
      _setLoading(true);
    } else {
      _setFetchingMore(true);
    }

    try {
      final result = await JobApplicationApi.getByJobSeeker(
        userId: userId,
        page: _page,
        size: _size,
      );

      _pagination = result;
      _applications.addAll(result.items);
      _hasMore = _page + 1 < result.totalPages;
      _page++;

      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
      _setFetchingMore(false);
    }
  }

  // =============================
  // FETCH BY EMPLOYER
  // =============================

  Future<void> fetchByEmployer({
    required int employerId,
    bool refresh = false,
  }) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    if (refresh) {
      _resetPagination();
      _setLoading(true);
    } else {
      _setFetchingMore(true);
    }

    try {
      final result = await JobApplicationApi.getByEmployer(
        employerId: employerId,
        page: _page,
        size: _size,
      );

      _pagination = result;
      _applications.addAll(result.items);
      _hasMore = _page + 1 < result.totalPages;
      _page++;

      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
      _setFetchingMore(false);
    }
  }

  // =============================
  // FETCH RECENT (EMPLOYER)
  // =============================

  Future<void> fetchRecent({
    required int employerId,
    bool refresh = false,
  }) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    if (refresh) {
      _resetPagination();
      _setLoading(true);
    } else {
      _setFetchingMore(true);
    }

    try {
      final result = await JobApplicationApi.getRecentForEmployer(
        employerId: employerId,
        page: _page,
        size: _size,
      );

      _pagination = result;
      _applications.addAll(result.items);
      _hasMore = _page + 1 < result.totalPages;
      _page++;

      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
      _setFetchingMore(false);
    }
  }

  // =============================
  // GET SINGLE APPLICATION
  // =============================

  Future<void> loadApplication(int applicationId) async {
    _setLoading(true);
    try {
      _selectedApplication =
          await JobApplicationApi.getById(applicationId);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // =============================
  // GET APPLICATION HISTORY
  // =============================

  Future<void> loadHistory(int applicationId) async {
    _setLoading(true);
    try {
      _history =
          await JobApplicationApi.getHistory(applicationId);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // =============================
  // APPLY FOR JOB
  // =============================

  Future<JobApplication?> apply({
    required int jobId,
    required int resumeId,
    String? coverLetter,
  }) async {
    _setLoading(true);
    try {
      final application = await JobApplicationApi.apply(
        jobId: jobId,
        resumeId: resumeId,
        coverLetter: coverLetter,
      );

      _applications.insert(0, application);
      notifyListeners();
      return application;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // =============================
  // UPDATE STATUS
  // =============================

  Future<void> updateStatus({
    required int applicationId,
    required UpdateApplicationStatusRequest request,
    required int changedByUserId,
  }) async {
    _setLoading(true);
    try {
      final updated = await JobApplicationApi.updateStatus(
        applicationId: applicationId,
        request: request,
        changedByUserId: changedByUserId,
      );

      final index =
          _applications.indexWhere((e) => e.id == applicationId);
      if (index != -1) {
        _applications[index] = updated;
      }

      if (_selectedApplication?.id == applicationId) {
        _selectedApplication = updated;
      }

      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // =============================
  // WITHDRAW APPLICATION
  // =============================

  Future<void> withdraw(int applicationId) async {
    _setLoading(true);
    try {
      await JobApplicationApi.withdraw(applicationId);
      _applications.removeWhere((e) => e.id == applicationId);

      if (_selectedApplication?.id == applicationId) {
        _selectedApplication = null;
      }

      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // =============================
  // CHECK HAS APPLIED
  // =============================

  Future<bool> hasApplied(int jobId) async {
    try {
      return await JobApplicationApi.hasApplied(jobId);
    } catch (_) {
      return false;
    }
  }

  // =============================
  // COUNT BY JOB
  // =============================

  Future<int> countByJob(int jobId) async {
    try {
      return await JobApplicationApi.countByJob(jobId);
    } catch (_) {
      return 0;
    }
  }

  // =============================
  // CLEAR STATE
  // =============================

  void clear() {
    _applications.clear();
    _pagination = null;
    _selectedApplication = null;
    _history.clear();
    _page = 0;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }
}