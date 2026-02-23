import 'dart:convert';

import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/models/analytics_models.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';

class JobApi {
  static const String _base = '/jobs';

  /* =========================
     PUBLIC JOB APIs
     ========================= */

  // GET /jobs
  static Future<Pagination<Job>> getJobs({
    int page = 0,
    int size = 10,
    String sort = 'postedAt,desc',
  }) async {
    final res = await ApiClient.get('$_base?page=$page&size=$size&sort=$sort');

    final json = jsonDecode(res.body);
    return Pagination.fromJson(json, (e) => Job.fromJson(e));
  }

  // POST /jobs/search
  static Future<Pagination<Job>> searchJobs({
    required JobSearchFilter filter,
    int page = 0,
    int size = 10,
    String sort = 'postedAt,desc',
  }) async {
    final res = await ApiClient.post(
      '$_base/search?page=$page&size=$size&sort=$sort',
      body: filter.toJson(),
    );

    final json = jsonDecode(res.body);
    return Pagination.fromJson(json, (e) => Job.fromJson(e));
  }

  // GET /jobs/{jobId}
  static Future<Job> getJobById(int jobId) async {
    final res = await ApiClient.get('$_base/$jobId');
    return Job.fromJson(jsonDecode(res.body));
  }

  // GET /jobs/company/{companyId}
  static Future<Pagination<Job>> getJobsByCompany({
    required int companyId,
    int page = 0,
    int size = 10,
  }) async {
    final res = await ApiClient.get(
      '$_base/company/$companyId?page=$page&size=$size',
    );

    final json = jsonDecode(res.body);
    return Pagination.fromJson(json, (e) => Job.fromJson(e));
  }

  /* =========================
     EMPLOYER JOB APIs
     ========================= */

  // GET /jobs/employer/{employerId}
  static Future<Pagination<Job>> getJobsByEmployer({
    required int employerId,
    JobStatus? status,
    JobType? jobType,
    String? keyword,
    int page = 0,
    int size = 10,
  }) async {
    final query = _query({
      'status': status?.name,
      'jobType': jobType?.name,
      'keyword': keyword,
      'page': page.toString(),
      'size': size.toString(),
    });

    final res = await ApiClient.get(
      '$_base/employer/$employerId$query',
      auth: true,
    );

    final json = jsonDecode(res.body);
    return Pagination.fromJson(json, (e) => Job.fromJson(e));
  }

  // POST /jobs
  static Future<Job> createJob({
    required JobCreateRequest request,
    required int employerId,
  }) async {
    final res = await ApiClient.post(
      '$_base?employerId=$employerId',
      body: request.toJson(),
      auth: true,
    );

    return Job.fromJson(jsonDecode(res.body));
  }

  // PUT /jobs/{jobId}
  static Future<Job> updateJob({
    required int jobId,
    required JobUpdateRequest request,
    required int employerId,
  }) async {
    final res = await ApiClient.put(
      '$_base/$jobId?employerId=$employerId',
      body: request.toJson(),
      auth: true,
    );

    return Job.fromJson(jsonDecode(res.body));
  }

  // DELETE /jobs/{jobId}
  static Future<void> deleteJob({
    required int jobId,
    required int employerId,
  }) async {
    await ApiClient.delete('$_base/$jobId?employerId=$employerId', auth: true);
  }

  /* =========================
     JOB ANALYTICS
     ========================= */

  // POST /jobs/{jobId}/view
  static Future<void> recordJobView({
    required int jobId,
    required JobViewRequest request,
  }) async {
    await ApiClient.post('$_base/$jobId/view', body: request.toJson());
  }

  // GET /jobs/{jobId}/analytics
  static Future<JobAnalytics> getJobAnalytics(int jobId) async {
    final res = await ApiClient.get('$_base/$jobId/analytics', auth: true);

    return JobAnalytics.fromJson(jsonDecode(res.body));
  }

  /* =========================
     ADMIN APIs
     ========================= */

  // POST /jobs/close-expired
  static Future<void> closeExpiredJobs() async {
    await ApiClient.post('$_base/close-expired', auth: true);
  }

  // GET /jobs/search (ADMIN / fallback)
  static Future<Pagination<Job>> searchJobsGet({
    JobSearchFilter? filter,
    int page = 0,
    int size = 10,
  }) async {
    final query = _query({
      ...?filter?.toJson().map((k, v) => MapEntry(k, v?.toString())),
      'page': page.toString(),
      'size': size.toString(),
    });

    final res = await ApiClient.get('$_base/search$query');

    final json = jsonDecode(res.body);
    return Pagination.fromJson(json, (e) => Job.fromJson(e));
  }

  static String _query(Map<String, String?> params) {
    final filtered = params.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value!)}')
        .join('&');

    return filtered.isEmpty ? '' : '?$filtered';
  }
}
