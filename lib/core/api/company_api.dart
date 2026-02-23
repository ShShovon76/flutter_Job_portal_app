import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/core/services/storage_service.dart';
import 'package:job_portal_app/models/company_model.dart';
import 'package:job_portal_app/models/company_review.dart';
import 'package:job_portal_app/models/job_search_filter.dart';

class CompanyApi {
  // ----------------------------
  // 1️⃣ Get companies
  // ----------------------------
  Future<Pagination<Company>> getCompanies({
    int page = 0,
    int size = 10,
    String sort = 'createdAt,desc',
  }) async {
    final res = await ApiClient.get(
      '/companies?page=$page&size=$size&sort=$sort',
    );

    final json = jsonDecode(res.body);
    return Pagination.fromJson(
      json,
      (e) => Company.fromJson(e as Map<String, dynamic>),
    );
  }

  // ----------------------------
  // 2️⃣ Search companies
  // ----------------------------
  Future<Pagination<Company>> searchCompanies({
    String? keyword,
    String? industry,
    bool? verified,
    int page = 0,
    int size = 10,
    String sort = 'createdAt,desc',
  }) async {
    final query = _query({
      'keyword': keyword,
      'industry': industry,
      'verified': verified?.toString(),
      'page': '$page',
      'size': '$size',
      'sort': sort,
    });

    final res = await ApiClient.get('/companies/search$query');
    final json = jsonDecode(res.body);

    return Pagination.fromJson(
      json,
      (e) => Company.fromJson(e as Map<String, dynamic>),
    );
  }

  // ----------------------------
  // 3️⃣ Get company by id
  // ----------------------------
  Future<Company> getCompanyById(int id) async {
    final res = await ApiClient.get('/companies/$id');
    return Company.fromJson(jsonDecode(res.body));
  }

  // ----------------------------
  // 4️⃣ Get companies by owner
  // ----------------------------
  Future<Pagination<Company>> getCompaniesByOwner({
    required int ownerId,
    int page = 0,
    int size = 10,
  }) async {
    final res = await ApiClient.get(
      '/companies/owner/$ownerId?page=$page&size=$size',
      auth: true,
    );

    final json = jsonDecode(res.body);
    return Pagination.fromJson(
      json,
      (e) => Company.fromJson(e as Map<String, dynamic>),
    );
  }

  // ----------------------------
  // 5️⃣ Create company
  // ----------------------------
  Future<Company> createCompany({required Company company, File? logo}) async {
    final res = await ApiClient.multipart(
      'POST',
      '/companies',
      fields: {'data': jsonEncode(company.toJson())},
      files: logo != null ? {'logo': logo} : null,
      auth: true,
    );

    final body = await res.stream.bytesToString();
    return Company.fromJson(jsonDecode(body));
  }

  // ----------------------------
  // 6️⃣ Update company
  // ----------------------------
 Future<Company> updateCompany({
  required int id,
  required CompanyUpdateRequest request,
  File? logo,
  File? cover,
}) async {
  final uri = Uri.parse('${AppConstants.baseUrl}/companies/$id');
  final multipartRequest = http.MultipartRequest('PUT', uri);

  // AUTH
  final token = await TokenStorage.getAccessToken();
  if (token != null) {
    multipartRequest.headers['Authorization'] = 'Bearer $token';
  }

  // JSON part for `data`
  multipartRequest.files.add(
    http.MultipartFile.fromString(
      'data',
      jsonEncode(request.toJson()),
      contentType: MediaType('application', 'json'), // ✅ must be application/json
    ),
  );

  // LOGO
  if (logo != null) {
    multipartRequest.files.add(
      await http.MultipartFile.fromPath('logo', logo.path),
    );
  }

  // COVER
  if (cover != null) {
    multipartRequest.files.add(
      await http.MultipartFile.fromPath('cover', cover.path),
    );
  }

  final streamedResponse = await multipartRequest.send();
  final responseBody = await streamedResponse.stream.bytesToString();

  if (streamedResponse.statusCode >= 200 &&
      streamedResponse.statusCode < 300) {
    return Company.fromJson(jsonDecode(responseBody));
  } else {
    throw Exception(
        'Failed to update company: ${streamedResponse.statusCode} - $responseBody');
  }
}



  // ----------------------------
  // 7️⃣ Upload logo
  // ----------------------------
  Future<Company> uploadLogo(int companyId, File file) async {
    final res = await ApiClient.multipart(
      'POST',
      '/companies/$companyId/logo',
      files: {'file': file},
      auth: true,
    );

    final body = await res.stream.bytesToString();
    return Company.fromJson(jsonDecode(body));
  }

  // ----------------------------
  // 8️⃣ Upload cover
  // ----------------------------
  Future<Company> uploadCover(int companyId, File file) async {
    final res = await ApiClient.multipart(
      'POST',
      '/companies/$companyId/cover',
      files: {'file': file},
      auth: true,
    );

    final body = await res.stream.bytesToString();
    return Company.fromJson(jsonDecode(body));
  }

  // ----------------------------
  // 9️⃣ Delete logo
  // ----------------------------
  Future<void> deleteLogo(int companyId) async {
    await ApiClient.delete('/companies/$companyId/logo', auth: true);
  }

  // ----------------------------
  // 🔟 Delete cover
  // ----------------------------
  Future<void> deleteCover(int companyId) async {
    await ApiClient.delete('/companies/$companyId/cover', auth: true);
  }

  // ----------------------------
  // 1️⃣1️⃣ Add review
  // ----------------------------
  Future<CompanyReview> addReview({
    required int companyId,
    required int reviewerId,
    required CompanyReview review,
  }) async {
    final res = await ApiClient.post(
      '/companies/$companyId/reviews?reviewerId=$reviewerId',
      body: review.toJson(),
      auth: true,
    );

    return CompanyReview.fromJson(jsonDecode(res.body));
  }

  // ----------------------------
  // 1️⃣2️⃣ Get reviews
  // ----------------------------
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
      json,
      (e) => CompanyReview.fromJson(e as Map<String, dynamic>),
    );
  }

  // ----------------------------
  // 1️⃣3️⃣ Verify company
  // ----------------------------
  Future<void> verifyCompany({
    required int companyId,
    required int adminId,
  }) async {
    await ApiClient.post(
      '/companies/$companyId/verify?adminId=$adminId',
      auth: true,
    );
  }

  // ----------------------------
  // 1️⃣4️⃣ Delete company
  // ----------------------------
  Future<void> deleteCompany({
    required int companyId,
    required int ownerId,
  }) async {
    await ApiClient.delete(
      '/companies/$companyId?ownerId=$ownerId',
      auth: true,
    );
  }

  
  String _query(Map<String, String?> params) {
    final q = params.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value!)}')
        .join('&');
    return q.isEmpty ? '' : '?$q';
  }
}
