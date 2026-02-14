import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/models/company_model.dart';
import 'package:job_portal_app/models/company_review.dart';
import 'package:job_portal_app/models/job_search_filter.dart';

class CompanyApi {
  // --------------------------------------------------
  // 1️⃣ Get companies
  // --------------------------------------------------
  Future<Pagination<Company>> getCompanies({
    int page = 0,
    int size = 10,
    String sort = 'createdAt,desc',
  }) async {
    final res = await ApiClient.get(
      '/companies?page=$page&size=$size&sort=$sort',
    );

    final json = jsonDecode(res.body);

    return Pagination.fromJson(_springPage(json), (e) => Company.fromJson(e));
  }

  // --------------------------------------------------
  // 2️⃣ Search companies
  // --------------------------------------------------
  Future<Pagination<Company>> searchCompanies({
    String? keyword,
    String? industry,
    bool? verified,
    int page = 0,
    int size = 10,
  }) async {
    final query = _query({
      'keyword': keyword,
      'industry': industry,
      'verified': verified?.toString(),
      'page': page.toString(),
      'size': size.toString(),
    });

    final res = await ApiClient.get('/companies/search$query');

    final json = jsonDecode(res.body);

    return Pagination.fromJson(_springPage(json), (e) => Company.fromJson(e));
  }

  // --------------------------------------------------
  // 3️⃣ Get company by id
  // --------------------------------------------------
  Future<Company> getCompanyById(int id) async {
    final res = await ApiClient.get('/companies/$id');
    return Company.fromJson(jsonDecode(res.body));
  }

  // --------------------------------------------------
  // 4️⃣ Get companies by owner
  // --------------------------------------------------
  Future<Pagination<Company>> getCompaniesByOwner({
    required int ownerId,
    int page = 0,
    int size = 10,
  }) async {
    // Ensure this path matches the pattern you used to fix Categories
    // If Categories fixed by removing '/api', ensure this doesn't have a double slash
    final res = await ApiClient.get(
      '/companies/owner/$ownerId?page=$page&size=$size',
      auth: true, // MUST be true to access owner-specific data
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return Pagination.fromJson(_springPage(json), (e) => Company.fromJson(e));
    } else {
      // This will help you see why it's failing in the console
      debugPrint('Company API Failed: ${res.statusCode} - ${res.body}');
      throw Exception('Failed to load companies');
    }
  }

  // --------------------------------------------------
  // 5️⃣ Create company (Multipart)
  // --------------------------------------------------
  Future<Company> createCompany({required Company company, File? logo}) async {
    final res = await ApiClient.multipart(
      'POST',
      '/companies',
      fields: {'data': jsonEncode(company.toJson())},
      files: logo != null ? {'logo': logo} : null,
    );

    final body = await res.stream.bytesToString();
    return Company.fromJson(jsonDecode(body));
  }

  // --------------------------------------------------
  // 6️⃣ Update company
  // --------------------------------------------------
  Future<Company> updateCompany({
    required int id,
    required Map<String, dynamic> updateData,
    File? logo,
    File? cover,
  }) async {
    final res = await ApiClient.multipart(
      'PUT',
      '/companies/$id',
      fields: {'data': jsonEncode(updateData)},
      files: {
        if (logo != null) 'logo': logo,
        if (cover != null) 'cover': cover,
      },
    );

    final body = await res.stream.bytesToString();
    return Company.fromJson(jsonDecode(body));
  }

  // --------------------------------------------------
  // 7️⃣ Add review
  // --------------------------------------------------
  Future<CompanyReview> addReview({
    required int companyId,
    required int reviewerId,
    required CompanyReview review,
  }) async {
    final res = await ApiClient.post(
      '/companies/$companyId/reviews?reviewerId=$reviewerId',
      body: review.toJson(),
    );

    return CompanyReview.fromJson(jsonDecode(res.body));
  }

  // --------------------------------------------------
  // 8️⃣ Get reviews
  // --------------------------------------------------
  Future<Pagination<CompanyReview>> getReviews({
    required int companyId,
    int page = 0,
    int size = 10,
  }) async {
    final res = await ApiClient.get(
      '/companies/$companyId/reviews?page=$page&size=$size',
    );

    final json = jsonDecode(res.body);

    return Pagination.fromJson(
      _springPage(json),
      (e) => CompanyReview.fromJson(e),
    );
  }

  // --------------------------------------------------
  // 9️⃣ Verify company
  // --------------------------------------------------
  Future<void> verifyCompany({
    required int companyId,
    required int adminId,
  }) async {
    await ApiClient.post('/companies/$companyId/verify?adminId=$adminId');
  }

  // --------------------------------------------------
  // 🔟 Delete company
  // --------------------------------------------------
  Future<void> deleteCompany({
    required int companyId,
    required int ownerId,
  }) async {
    await ApiClient.delete('/companies/$companyId?ownerId=$ownerId');
  }

  // --------------------------------------------------
  // Helpers
  // --------------------------------------------------
  Map<String, dynamic> _springPage(Map<String, dynamic> json) {
    return {
      'items': json['content'],
      'page': json['number'],
      'size': json['size'],
      'totalItems': json['totalElements'],
      'totalPages': json['totalPages'],
    };
  }

  String _query(Map<String, String?> params) {
    final q = params.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value!)}')
        .join('&');
    return q.isEmpty ? '' : '?$q';
  }
}
