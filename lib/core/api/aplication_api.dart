import 'dart:convert';
import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/models/application_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';



class JobApplicationApi {
  static const String _base = '/applications';

  // ================================
  // GET Application by ID
  // GET /api/applications/id/{id}
  // ================================
  static Future<JobApplication> getById(int id) async {
    final res = await ApiClient.get('$_base/id/$id', auth: true);

    if (res.statusCode == 200) {
      return JobApplication.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to load application');
  }

  // =====================================
  // GET Application Status History
  // GET /api/applications/{applicationId}/history
  // =====================================
  static Future<List<ApplicationStatusHistory>> getHistory(
    int applicationId,
  ) async {
    final res =
        await ApiClient.get('$_base/$applicationId/history', auth: true);

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list
          .map((e) => ApplicationStatusHistory.fromJson(e))
          .toList();
    }
    throw Exception('Failed to load application history');
  }

  // =====================================
  // GET Applications by Job
  // GET /api/applications/job/{jobId}
  // =====================================
  static Future<Pagination<JobApplication>> getByJob({
    required int jobId,
    int page = 0,
    int size = 10,
  }) async {
    final res = await ApiClient.get(
      '$_base/job/$jobId?page=$page&size=$size',
      auth: true,
    );

    final json = jsonDecode(res.body);
    return Pagination.fromJson(
      json,
      (e) => JobApplication.fromJson(e),
    );
  }

  // =====================================
  // GET Applications by Job Seeker
  // GET /api/applications/job-seeker/{userId}
  // =====================================
  static Future<Pagination<JobApplication>> getByJobSeeker({
    required int userId,
    int page = 0,
    int size = 10,
  }) async {
    final res = await ApiClient.get(
      '$_base/job-seeker/$userId?page=$page&size=$size',
      auth: true,
    );

    final json = jsonDecode(res.body);
    return Pagination.fromJson(
      json,
      (e) => JobApplication.fromJson(e),
    );
  }

  // =====================================
  // GET Applications by Employer
  // GET /api/applications/employer/{employerId}
  // =====================================
  static Future<Pagination<JobApplication>> getByEmployer({
    required int employerId,
    int page = 0,
    int size = 10,
  }) async {
    final res = await ApiClient.get(
      '$_base/employer/$employerId?page=$page&size=$size',
      auth: true,
    );

    final json = jsonDecode(res.body);
    return Pagination.fromJson(
      json,
      (e) => JobApplication.fromJson(e),
    );
  }

  // =====================================
  // APPLY FOR A JOB
  // POST /api/applications/apply/{jobId}
  // =====================================
  static Future<JobApplication> apply({
    required int jobId,
    required int resumeId,
    String? coverLetter,
  }) async {
    final res = await ApiClient.post(
      '$_base/apply/$jobId',
      auth: true,
      body: {
        'resumeId': resumeId,
        'coverLetter': coverLetter,
      },
    );

    if (res.statusCode == 200) {
      return JobApplication.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to apply for job');
  }

  // =====================================
  // CHECK IF USER HAS APPLIED
  // GET /api/applications/jobs/{jobId}/applied
  // =====================================
  static Future<bool> hasApplied(int jobId) async {
    final res = await ApiClient.get(
      '$_base/jobs/$jobId/applied',
      auth: true,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as bool;
    }
    throw Exception('Failed to check application status');
  }

  // =====================================
  // UPDATE APPLICATION STATUS
  // PUT /api/applications/{applicationId}/status
  // =====================================
  static Future<JobApplication> updateStatus({
    required int applicationId,
    required UpdateApplicationStatusRequest request,
    required int changedByUserId,
  }) async {
    final res = await ApiClient.put(
      '$_base/$applicationId/status?changedByUserId=$changedByUserId',
      auth: true,
      body: request.toJson(),
    );

    if (res.statusCode == 200) {
      return JobApplication.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to update application status');
  }

  // =====================================
  // COUNT APPLICATIONS BY JOB
  // GET /api/applications/job/{jobId}/count
  // =====================================
  static Future<int> countByJob(int jobId) async {
    final res =
        await ApiClient.get('$_base/job/$jobId/count', auth: true);

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as int;
    }
    throw Exception('Failed to count applications');
  }

  // =====================================
  // WITHDRAW APPLICATION
  // DELETE /api/applications/{applicationId}
  // =====================================
  static Future<void> withdraw(int applicationId) async {
    final res = await ApiClient.delete(
      '$_base/$applicationId',
      auth: true,
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to withdraw application');
    }
  }

  // =====================================
  // GET RECENT APPLICATIONS (EMPLOYER)
  // GET /api/applications/employer/recent
  // =====================================
  static Future<Pagination<JobApplication>> getRecentForEmployer({
    required int employerId,
    int page = 0,
    int size = 10,
  }) async {
    final res = await ApiClient.get(
      '$_base/employer/recent'
      '?employerId=$employerId&page=$page&size=$size',
      auth: true,
    );

    final json = jsonDecode(res.body);
    return Pagination.fromJson(
      json,
      (e) => JobApplication.fromJson(e),
    );
  }
}

