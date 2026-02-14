import 'dart:convert';

import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/models/job_search_filter.dart';
import 'package:job_portal_app/models/saved_job.dart';

class SavedJobApi {
  static const String _base = '/saved-jobs';

  /* ======================================================
     GET MY SAVED JOBS (PAGINATED)
     GET /api/saved-jobs
     ====================================================== */
  static Future<Pagination<SavedJob>> getSavedJobs({
    int page = 0,
    int size = 10,
    String sort = 'savedAt,desc',
  }) async {
    final res = await ApiClient.get(
      '$_base?page=$page&size=$size&sort=$sort',
      auth: true,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load saved jobs');
    }

    final json = jsonDecode(res.body);

    return Pagination.fromJson(
      {
        'items': json['content'],
        'page': json['page'],
        'size': json['size'],
        'totalItems': json['totalElements'],
        'totalPages': json['totalPages'],
      },
      (e) => SavedJob.fromJson(e),
    );
  }

  /* ======================================================
     CHECK IF JOB IS SAVED
     GET /api/saved-jobs/check?jobId=
     ====================================================== */
  static Future<bool> isJobSaved(int jobId) async {
    final res = await ApiClient.get(
      '$_base/check?jobId=$jobId',
      auth: true,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to check saved job');
    }

    return jsonDecode(res.body) as bool;
  }

  /* ======================================================
     SAVE A JOB
     POST /api/saved-jobs?jobId=
     ====================================================== */
  static Future<SavedJob> saveJob(int jobId) async {
    final res = await ApiClient.post(
      '$_base?jobId=$jobId',
      auth: true,
    );

    if (res.statusCode != 201) {
      throw Exception('Failed to save job');
    }

    return SavedJob.fromJson(jsonDecode(res.body));
  }

  /* ======================================================
     UNSAVE JOB (BY JOB ID)
     DELETE /api/saved-jobs/unsave?jobId=
     ====================================================== */
  static Future<void> unsaveJobByJobId(int jobId) async {
    final res = await ApiClient.delete(
      '$_base/unsave?jobId=$jobId',
      auth: true,
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to unsave job');
    }
  }

  /* ======================================================
     UNSAVE JOB (BY SAVED JOB ID)
     DELETE /api/saved-jobs/{savedJobId}
     ====================================================== */
  static Future<void> unsaveJobById(int savedJobId) async {
    final res = await ApiClient.delete(
      '$_base/$savedJobId',
      auth: true,
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to unsave job');
    }
  }

  /* ======================================================
     GET SAVE COUNT FOR A JOB
     GET /api/saved-jobs/{jobId}/count
     ====================================================== */
  static Future<int> getSaveCountForJob(int jobId) async {
    final res = await ApiClient.get(
      '$_base/$jobId/count',
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to get save count');
    }

    return jsonDecode(res.body) as int;
  }
}