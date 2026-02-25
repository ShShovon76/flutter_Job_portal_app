import 'dart:convert';

import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';

class SearchApi {
  static const String base = '/search';

  // ---------------- SEARCH JOBS ----------------
  static Future<Pagination<Job>> searchJobs(
    JobSearchFilter filter,
  ) async {
    final res = await ApiClient.post(
      '$base/jobs?page=${filter.page ?? 0}&size=${filter.size ?? 10}',
      body: filter.toJson(),
      auth: true,
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return Pagination.fromJson(
        json,
        (e) => Job.fromJson(e),
      );
    }

    throw Exception('Failed to search jobs');
  }

  // ---------------- AUTOCOMPLETE JOB TITLES ----------------
  static Future<List<String>> autocompleteJobTitles(
      String keyword) async {
    final res = await ApiClient.get(
      '$base/autocomplete/job-titles?keyword=$keyword',
      auth: true,
    );

    if (res.statusCode == 200) {
      return List<String>.from(jsonDecode(res.body));
    }

    throw Exception('Failed to autocomplete job titles');
  }

  // ---------------- AUTOCOMPLETE COMPANIES ----------------
  static Future<List<String>> autocompleteCompanies(
      String keyword) async {
    final res = await ApiClient.get(
      '$base/autocomplete/companies?keyword=$keyword',
      auth: true,
    );

    if (res.statusCode == 200) {
      return List<String>.from(jsonDecode(res.body));
    }

    throw Exception('Failed to autocomplete companies');
  }

  // ---------------- CATEGORIES ----------------
  static Future<List<dynamic>> getCategories() async {
    final res = await ApiClient.get(
      '$base/categories',
      auth: true,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception('Failed to load categories');
  }

  // ---------------- POPULAR SKILLS ----------------
  static Future<List<String>> getPopularSkills() async {
    final res = await ApiClient.get(
      '$base/popular-skills',
      auth: true,
    );

    if (res.statusCode == 200) {
      return List<String>.from(jsonDecode(res.body));
    }

    throw Exception('Failed to load popular skills');
  }
}