import 'dart:convert';
import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/models/analytics_models.dart';

class AnalyticsApi {
  static const String _base = '/analytics';

  // --------------------------------------------------
  // 1️⃣ Job Views Analytics
  // GET /analytics/jobs/{jobId}/views
  // --------------------------------------------------
  static Future<JobViewsResponse> getJobViews({
    required int jobId,
    DateTime? from,
    DateTime? to,
  }) async {
    final query = _buildQuery({
      'from': from?.toIso8601String(),
      'to': to?.toIso8601String(),
    });

    final res = await ApiClient.get(
      '$_base/jobs/$jobId/views$query',
      auth: true,
    );

    return JobViewsResponse.fromJson(jsonDecode(res.body));
  }

  // --------------------------------------------------
  // 2️⃣ Application Trends
  // GET /analytics/applications/trends
  // --------------------------------------------------
  static Future<ApplicationTrendsResponse> getApplicationTrends({
    int? jobId,
    int? employerId,
    DateTime? from,
    DateTime? to,
  }) async {
    final query = _buildQuery({
      'jobId': jobId?.toString(),
      'employerId': employerId?.toString(),
      'from': from?.toIso8601String(),
      'to': to?.toIso8601String(),
    });

    final res = await ApiClient.get(
      '$_base/applications/trends$query',
      auth: true,
    );

    return ApplicationTrendsResponse.fromJson(jsonDecode(res.body));
  }

  // --------------------------------------------------
  // 3️⃣ Employer Dashboard
  // GET /analytics/employers/{employerId}/dashboard
  // --------------------------------------------------
  static Future<EmployerDashboardResponse> getEmployerDashboard(
      int employerId) async {
    final res = await ApiClient.get(
      '$_base/employers/$employerId/dashboard',
      auth: true,
    );

    return EmployerDashboardResponse.fromJson(jsonDecode(res.body));
  }

  // --------------------------------------------------
  // 4️⃣ Site Metrics (ADMIN)
  // GET /analytics/site-metrics
  // --------------------------------------------------
  static Future<SiteMetricsResponse> getSiteMetrics() async {
    final res = await ApiClient.get(
      '$_base/site-metrics',
      auth: true,
    );

    return SiteMetricsResponse.fromJson(jsonDecode(res.body));
  }

  // --------------------------------------------------
  // 5️⃣ Job Seeker Dashboard
  // GET /analytics/job-seekers/{jobSeekerId}/dashboard
  // --------------------------------------------------
  static Future<JobSeekerDashboardResponse> getJobSeekerDashboard(
      int jobSeekerId) async {
    final res = await ApiClient.get(
      '$_base/job-seekers/$jobSeekerId/dashboard',
      auth: true,
    );

    return JobSeekerDashboardResponse.fromJson(jsonDecode(res.body));
  }

  // --------------------------------------------------
  // 🔧 Helper: Query builder
  // --------------------------------------------------
  static String _buildQuery(Map<String, String?> params) {
    final filtered = params.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value!)}')
        .toList();

    if (filtered.isEmpty) return '';
    return '?${filtered.join('&')}';
  }
}
