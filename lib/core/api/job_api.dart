import 'dart:convert';

import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';

class JobApi {
  /// GET /api/jobs
  static Future<Pagination<Job>> getJobs(int page, int size) async {
    final res = await ApiClient.get(
      '/jobs?page=$page&size=$size',
    );

    if (res.statusCode == 200) {
      return Pagination.fromJson(
        jsonDecode(res.body),
        (e) => Job.fromJson(e),
      );
    }
    throw Exception(res.body);
  }

  /// POST /api/jobs/search
  static Future<Pagination<Job>> searchJobs(JobSearchFilter filter) async {
    final res = await ApiClient.post(
      '/jobs/search',
      body: filter.toJson(),
    );

    if (res.statusCode == 200) {
      return Pagination.fromJson(
        jsonDecode(res.body),
        (e) => Job.fromJson(e),
      );
    }
    throw Exception(res.body);
  }

  /// GET /api/jobs/{id}
  static Future<Job> getJobById(int id) async {
    final res = await ApiClient.get('/jobs/$id');

    if (res.statusCode == 200) {
      return Job.fromJson(jsonDecode(res.body));
    }
    throw Exception(res.body);
  }

  /// GET /api/jobs/company/{companyId}
  static Future<Pagination<Job>> getJobsByCompany(int companyId, int page) async {
    final res = await ApiClient.get(
      '/jobs/company/$companyId?page=$page',
    );

    if (res.statusCode == 200) {
      return Pagination.fromJson(
        jsonDecode(res.body),
        (e) => Job.fromJson(e),
      );
    }
    throw Exception(res.body);
  }

  /// EMPLOYER: POST /api/jobs
  static Future<Job> createJob(
    Map<String, dynamic> body,
    int employerId,
  ) async {
    final res = await ApiClient.post(
      '/jobs?employerId=$employerId',
      body: body,
      auth: true,
    );

    if (res.statusCode == 201) {
      return Job.fromJson(jsonDecode(res.body));
    }
    throw Exception(res.body);
  }
}
