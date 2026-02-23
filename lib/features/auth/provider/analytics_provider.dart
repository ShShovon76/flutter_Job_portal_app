import 'package:flutter/material.dart';
import 'package:job_portal_app/core/api/analytics_api.dart';
import 'package:job_portal_app/models/analytics_models.dart';

class AnalyticsProvider extends ChangeNotifier {
  // ============================================================
  // 🔹 STATES
  // ============================================================

  bool _isLoading = false;
  String? _error;

  JobViewsResponse? _jobViews;
  ApplicationTrendsResponse? _applicationTrends;
  EmployerDashboardResponse? _employerDashboard;
  SiteMetricsResponse? _siteMetrics;
  JobSeekerDashboardResponse? _jobSeekerDashboard;

  // ============================================================
  // 🔹 GETTERS
  // ============================================================

  bool get isLoading => _isLoading;
  String? get error => _error;

  JobViewsResponse? get jobViews => _jobViews;
  ApplicationTrendsResponse? get applicationTrends => _applicationTrends;
  EmployerDashboardResponse? get employerDashboard => _employerDashboard;
  SiteMetricsResponse? get siteMetrics => _siteMetrics;
  JobSeekerDashboardResponse? get jobSeekerDashboard =>
      _jobSeekerDashboard;

  // ============================================================
  // 🔹 INTERNAL HELPERS
  // ============================================================

  void _startLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _handleError(Object e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
  }

  // ============================================================
  // 1️⃣ JOB VIEWS
  // GET /analytics/jobs/{jobId}/views
  // ============================================================

  Future<void> fetchJobViews({
    required int jobId,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      _startLoading();

      _jobViews = await AnalyticsApi.getJobViews(
        jobId: jobId,
        from: from,
        to: to,
      );

      _stopLoading();
    } catch (e) {
      _handleError(e);
    }
  }

  // ============================================================
  // 2️⃣ APPLICATION TRENDS
  // GET /analytics/applications/trends
  // ============================================================

  Future<void> fetchApplicationTrends({
    int? jobId,
    int? employerId,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      _startLoading();

      _applicationTrends =
          await AnalyticsApi.getApplicationTrends(
        jobId: jobId,
        employerId: employerId,
        from: from,
        to: to,
      );

      _stopLoading();
    } catch (e) {
      _handleError(e);
    }
  }

  // ============================================================
  // 3️⃣ EMPLOYER DASHBOARD
  // GET /analytics/employers/{employerId}/dashboard
  // ============================================================

  Future<void> fetchEmployerDashboard(int employerId) async {
    try {
      _startLoading();

      _employerDashboard =
          await AnalyticsApi.getEmployerDashboard(
        employerId,
      );

      _stopLoading();
    } catch (e) {
      _handleError(e);
    }
  }

  // ============================================================
  // 4️⃣ SITE METRICS (ADMIN)
  // GET /analytics/site-metrics
  // ============================================================

  Future<void> fetchSiteMetrics() async {
    try {
      _startLoading();

      _siteMetrics =
          await AnalyticsApi.getSiteMetrics();

      _stopLoading();
    } catch (e) {
      _handleError(e);
    }
  }

  // ============================================================
  // 5️⃣ JOB SEEKER DASHBOARD
  // GET /analytics/job-seekers/{id}/dashboard
  // ============================================================

  Future<void> fetchJobSeekerDashboard(int jobSeekerId) async {
    try {
      _startLoading();

      _jobSeekerDashboard =
          await AnalyticsApi.getJobSeekerDashboard(
        jobSeekerId,
      );

      _stopLoading();
    } catch (e) {
      _handleError(e);
    }
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clear() {
    _jobViews = null;
    _applicationTrends = null;
    _employerDashboard = null;
    _siteMetrics = null;
    _jobSeekerDashboard = null;
    _error = null;
    notifyListeners();
  }
}