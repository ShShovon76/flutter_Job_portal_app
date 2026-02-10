import 'dart:convert';
import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/models/company_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';

class CompanyApi {
  /// GET /api/companies
  static Future<Pagination<Company>> getCompanies(int page) async {
    final res = await ApiClient.get('/companies?page=$page');

    if (res.statusCode == 200) {
      return Pagination.fromJson(
        jsonDecode(res.body),
        (e) => Company.fromJson(e),
      );
    }
    throw Exception(res.body);
  }

  /// GET /api/companies/{id}
  static Future<Company> getCompanyById(int id) async {
    final res = await ApiClient.get('/companies/$id');

    if (res.statusCode == 200) {
      return Company.fromJson(jsonDecode(res.body));
    }
    throw Exception(res.body);
  }

  /// POST /api/companies/{companyId}/reviews
  static Future<void> addReview(
    int companyId,
    Map<String, dynamic> body,
    int reviewerId,
  ) async {
    final res = await ApiClient.post(
      '/companies/$companyId/reviews?reviewerId=$reviewerId',
      body: body,
      auth: true,
    );

    if (res.statusCode != 201) {
      throw Exception(res.body);
    }
  }
}
