import 'dart:io';
import 'package:flutter/material.dart';
import 'package:job_portal_app/core/api/company_api.dart';
import 'package:job_portal_app/models/company_model.dart';
import 'package:job_portal_app/models/company_review.dart';

class CompanyProvider extends ChangeNotifier {
  final CompanyApi _api = CompanyApi();

  bool loading = false;
  String? error;

  Company? myCompany;
  List<CompanyReview> reviews = [];

  // ----------------------------
  // Core safe call
  // ----------------------------
  Future<T?> _run<T>(Future<T> Function() action) async {
    loading = true;
    error = null;

    // 🔒 notify only if widget already built
    if (hasListeners) notifyListeners();

    try {
      return await action();
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      loading = false;
      if (hasListeners) notifyListeners();
    }
  }

  // ----------------------------
  // Company
  // ----------------------------
  Future<void> loadMyCompany(int ownerId) async {
    final page = await _run(() => _api.getCompaniesByOwner(ownerId: ownerId));
    myCompany = page?.items.isNotEmpty == true ? page!.items.first : null;
  }

  Future<void> createCompany(Company company, {File? logo}) async {
    myCompany = await _run(
      () => _api.createCompany(company: company, logo: logo),
    );
  }

  Future<void> updateCompany(
    CompanyUpdateRequest request, {
    File? logo,
    File? cover,
  }) async {
    if (myCompany == null) return;

    myCompany = await _run(
      () => _api.updateCompany(
        id: myCompany!.id,
        request: request,
        logo: logo,
        cover: cover,
      ),
    );
  }

  Future<void> uploadLogo(File file) async {
    if (myCompany == null) return;
    myCompany = await _run(() => _api.uploadLogo(myCompany!.id, file));
  }

  Future<void> uploadCover(File file) async {
    if (myCompany == null) return;
    myCompany = await _run(() => _api.uploadCover(myCompany!.id, file));
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

  // ----------------------------
  // Reviews
  // ----------------------------
  Future<void> loadReviews(int companyId) async {
    final page = await _run(() => _api.getReviews(companyId: companyId));
    reviews = page?.items ?? [];
  }

  Future<void> addReview(
    int companyId,
    int reviewerId,
    CompanyReview review,
  ) async {
    await _run(
      () => _api.addReview(
        companyId: companyId,
        reviewerId: reviewerId,
        review: review,
      ),
    );
    await loadReviews(companyId);
  }

  // ----------------------------
  // Admin
  // ----------------------------
  Future<void> verifyCompany(int companyId, int adminId) async {
    await _run(
      () => _api.verifyCompany(companyId: companyId, adminId: adminId),
    );
  }

  Future<void> deleteCompany(int companyId, int ownerId) async {
    await _run(
      () => _api.deleteCompany(companyId: companyId, ownerId: ownerId),
    );
    myCompany = null;
  }
}
