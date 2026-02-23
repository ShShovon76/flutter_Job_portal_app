import 'dart:io';
import 'package:flutter/material.dart';
import 'package:job_portal_app/core/api/company_api.dart';
import 'package:job_portal_app/models/company_model.dart';
import 'package:job_portal_app/models/company_review.dart';

class CompanyProvider extends ChangeNotifier {
  final CompanyApi _api = CompanyApi();

  bool loading = false;
  String? error;

  // =====================================================
  // STATE
  // =====================================================

  /// Public list (GET /companies, /search)
  List<Company> companies = [];
  int page = 0;
  int size = 10;
  int totalPages = 0;
  bool hasMore = true;

  /// Selected company (GET /{id})
  Company? selectedCompany;

  /// Owner company (GET /owner/{ownerId})
  Company? myCompany;

  /// Reviews
  List<CompanyReview> reviews = [];
  int reviewPage = 0;
  int reviewTotalPages = 0;

  // =====================================================
  // SAFE RUNNER
  // =====================================================

  Future<T?> _run<T>(Future<T> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      return await action();
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =====================================================
  // 1️⃣ GET COMPANIES
  // =====================================================

  Future<void> loadCompanies({bool refresh = false}) async {
    if (refresh) {
      page = 0;
      companies.clear();
      hasMore = true;
    }

    if (!hasMore) return;

    final result = await _run(
      () => _api.getCompanies(page: page, size: size),
    );

    if (result != null) {
      companies.addAll(result.items);
      totalPages = result.totalPages;
      hasMore = page + 1 < totalPages;
      page++;
    }
  }

  // =====================================================
  // 2️⃣ SEARCH
  // =====================================================

  Future<void> searchCompanies({
    String? keyword,
    String? industry,
    bool? verified,
    bool refresh = false,
  }) async {
    if (refresh) {
      page = 0;
      companies.clear();
      hasMore = true;
    }

    if (!hasMore) return;

    final result = await _run(
      () => _api.searchCompanies(
        keyword: keyword,
        industry: industry,
        verified: verified,
        page: page,
        size: size,
      ),
    );

    if (result != null) {
      companies.addAll(result.items);
      totalPages = result.totalPages;
      hasMore = page + 1 < totalPages;
      page++;
    }
  }

  // =====================================================
  // 3️⃣ GET COMPANY BY ID
  // =====================================================

  Future<void> loadCompanyById(int id) async {
    selectedCompany = await _run(() => _api.getCompanyById(id));
  }

  // =====================================================
  // 4️⃣ OWNER
  // =====================================================

  Future<void> loadMyCompany(int ownerId) async {
    final pageData =
        await _run(() => _api.getCompaniesByOwner(ownerId: ownerId));

    myCompany =
        pageData?.items.isNotEmpty == true ? pageData!.items.first : null;
  }

  // =====================================================
  // 5️⃣ CREATE
  // =====================================================

  Future<void> createCompany(Company company, {File? logo}) async {
    myCompany =
        await _run(() => _api.createCompany(company: company, logo: logo));
  }

  // =====================================================
  // 6️⃣ UPDATE
  // =====================================================

  Future<void> updateCompany(
    CompanyUpdateRequest request, {
    File? logo,
    File? cover,
  }) async {
    if (myCompany == null) return;

    myCompany = await _run(() => _api.updateCompany(
          id: myCompany!.id,
          request: request,
          logo: logo,
          cover: cover,
        ));
  }

  // =====================================================
  // 7️⃣ LOGO / COVER
  // =====================================================

  Future<void> uploadLogo(File file) async {
    if (myCompany == null) return;
    myCompany =
        await _run(() => _api.uploadLogo(myCompany!.id, file));
  }

  Future<void> uploadCover(File file) async {
    if (myCompany == null) return;
    myCompany =
        await _run(() => _api.uploadCover(myCompany!.id, file));
  }

  Future<void> deleteLogo() async {
    if (myCompany == null) return;
    await _run(() => _api.deleteLogo(myCompany!.id));
    myCompany = myCompany!.copyWith(logoUrl: null);
  }

  Future<void> deleteCover() async {
    if (myCompany == null) return;
    await _run(() => _api.deleteCover(myCompany!.id));
    myCompany = myCompany!.copyWith(coverImageUrl: null);
  }

  // =====================================================
  // 8️⃣ REVIEWS
  // =====================================================

  Future<void> loadReviews(int companyId, {bool refresh = false}) async {
    if (refresh) {
      reviewPage = 0;
      reviews.clear();
    }

    final result = await _run(
      () => _api.getReviews(companyId: companyId, page: reviewPage),
    );

    if (result != null) {
      reviews.addAll(result.items);
      reviewTotalPages = result.totalPages;
      reviewPage++;
    }
  }

  Future<void> addReview(
    int companyId,
    int reviewerId,
    CompanyReview review,
  ) async {
    await _run(() => _api.addReview(
          companyId: companyId,
          reviewerId: reviewerId,
          review: review,
        ));

    await loadReviews(companyId, refresh: true);
  }

  // =====================================================
  // 9️⃣ ADMIN
  // =====================================================

  Future<void> verifyCompany(int companyId, int adminId) async {
    await _run(() =>
        _api.verifyCompany(companyId: companyId, adminId: adminId));
  }

  Future<void> deleteCompany(int companyId, int ownerId) async {
    await _run(() =>
        _api.deleteCompany(companyId: companyId, ownerId: ownerId));
    myCompany = null;
  }
}
