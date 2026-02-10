import 'dart:convert';

import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';

class SearchApi {
  /// POST /api/search/jobs
  static Future<Pagination<Job>> searchJobs(JobSearchFilter filter) async {
    final res = await ApiClient.post(
      '/search/jobs',
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

  /// GET /api/search/autocomplete/job-titles
  static Future<List<String>> autocompleteJobTitles(String keyword) async {
    final res = await ApiClient.get(
      '/search/autocomplete/job-titles?keyword=$keyword',
    );

    if (res.statusCode == 200) {
      return List<String>.from(jsonDecode(res.body));
    }
    throw Exception(res.body);
  }

  /// GET /api/search/categories
  static Future<List<SimpleCategory>> getCategories() async {
    final res = await ApiClient.get('/search/categories');

    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => SimpleCategory.fromJson(e))
          .toList();
    }
    throw Exception(res.body);
  }
}
