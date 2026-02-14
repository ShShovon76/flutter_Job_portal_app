import 'package:flutter/material.dart';
import 'package:job_portal_app/core/api/job_api.dart';
import 'package:job_portal_app/models/analytics_models.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';

class JobProvider with ChangeNotifier {
  /* =====================
     STATE
     ===================== */

  bool loading = false;
  String? error;

  Pagination<Job>? jobPage;
  List<Job> jobs = [];

  Job? selectedJob;
  JobAnalytics? analytics;

  int currentPage = 0;
  int pageSize = 10;
  bool hasMore = true;

  /* =====================
     HELPERS
     ===================== */

  Future<T?> _safeCall<T>(Future<T> Function() action) async {
    try {
      loading = true;
      error = null;
      notifyListeners();
      return await action();
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void clearJobs() {
    jobs.clear();
    jobPage = null;
    currentPage = 0;
    hasMore = true;
    notifyListeners();
  }

  /* =====================
     PUBLIC JOBS
     ===================== */

  Future<void> loadJobs({bool refresh = false}) async {
    if (refresh) clearJobs();
    if (!hasMore || loading) return;

    final page = await _safeCall(() {
      return JobApi.getJobs(page: currentPage, size: pageSize);
    });

    if (page == null) return;

    jobPage = page;
    jobs.addAll(page.items);
    hasMore = page.page < page.totalPages - 1;
    currentPage++;
    notifyListeners();
  }

  Future<void> searchJobs(JobSearchFilter filter, {bool refresh = true}) async {
    if (refresh) clearJobs();

    final page = await _safeCall(() {
      return JobApi.searchJobs(
        filter: filter,
        page: currentPage,
        size: pageSize,
      );
    });

    if (page == null) return;

    jobPage = page;
    jobs = page.items;
    hasMore = false; // search = fixed result
    notifyListeners();
  }

  Future<void> loadJobById(int jobId) async {
    selectedJob = await _safeCall(() {
      return JobApi.getJobById(jobId);
    });
  }

  /* =====================
     COMPANY / EMPLOYER
     ===================== */

  Future<void> loadJobsByCompany(int companyId) async {
    final page = await _safeCall(() {
      return JobApi.getJobsByCompany(companyId: companyId);
    });

    if (page == null) return;

    jobs = page.items;
    notifyListeners();
  }

  // Inside JobProvider class
  Future<void> loadJobsByEmployer({
    required int employerId,
    JobStatus? status,
    JobType? jobType,
    String? keyword,
    bool refresh = false,
  }) async {
    if (refresh) clearJobs();
    if (!hasMore || loading) return;

    final page = await _safeCall(() {
      return JobApi.getJobsByEmployer(
        employerId: employerId,
        status: status,
        jobType: jobType,
        keyword: keyword,
        page: currentPage, // Use the provider's tracked page
        size: pageSize,
      );
    });

    if (page == null) return;

    jobPage = page;
    if (refresh) {
      jobs = page.items;
    } else {
      jobs.addAll(page.items);
    }

    // Update pagination state
    hasMore = page.page < page.totalPages - 1;
    currentPage++;
    notifyListeners();
  }

  /* =====================
     CRUD
     ===================== */

  Future<Job?> createJob(JobCreateRequest request, int employerId) async {
    final job = await _safeCall(() {
      return JobApi.createJob(request: request, employerId: employerId);
    });

    if (job != null) jobs.insert(0, job);
    return job;
  }

  Future<Job?> updateJob(
    int jobId,
    JobUpdateRequest request,
    int employerId,
  ) async {
    final updated = await _safeCall(() {
      return JobApi.updateJob(
        jobId: jobId,
        request: request,
        employerId: employerId,
      );
    });

    if (updated != null) {
      final index = jobs.indexWhere((j) => j.id == jobId);
      if (index != -1) jobs[index] = updated;
    }

    return updated;
  }

  // ✅ ADD THIS to your JobProvider class
  Future<void> updateJobInList(Job updatedJob) async {
    final index = jobs.indexWhere((j) => j.id == updatedJob.id);
    if (index != -1) {
      jobs[index] = updatedJob;
      notifyListeners();
    }
  }

  Future<void> deleteJob(int jobId, int employerId) async {
    await _safeCall(() {
      return JobApi.deleteJob(jobId: jobId, employerId: employerId);
    });

    jobs.removeWhere((j) => j.id == jobId);
    notifyListeners();
  }

  /* =====================
     ANALYTICS
     ===================== */

  Future<void> recordView(int jobId, JobViewRequest request) async {
    await JobApi.recordJobView(jobId: jobId, request: request);
  }

  Future<void> loadAnalytics(int jobId) async {
    analytics = await _safeCall(() {
      return JobApi.getJobAnalytics(jobId);
    });
  }

  /* =====================
     ADMIN
     ===================== */

  Future<void> closeExpiredJobs() async {
    await _safeCall(() {
      return JobApi.closeExpiredJobs();
    });
  }
}
