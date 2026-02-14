import 'dart:io';
import 'package:flutter/material.dart';
import 'package:job_portal_app/core/api/company_api.dart';
import 'package:job_portal_app/models/company_model.dart';


class CompanyProvider extends ChangeNotifier {
  final CompanyApi _api = CompanyApi();

  // =====================
  // STATE
  // =====================
  bool loading = false;
  String? error;

  Company? _myCompany;
  Company? get myCompany => _myCompany;

  // =====================
  // HELPERS
  // =====================
  Future<T?> _safeCall<T>(Future<T> Function() action) async {
    try {
      loading = true;
      error = null;
      notifyListeners();
      return await action();
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =====================
  // COMPANY OPERATIONS
  // =====================

  /// Load the current user's company
  Future<void> loadMyCompany(int ownerId) async {
    final page = await _safeCall(
      () => _api.getCompaniesByOwner(ownerId: ownerId),
    );

    if (page != null && page.items.isNotEmpty) {
      _myCompany = page.items.first; // assuming user has only one company
    } else {
      _myCompany = null;
    }
    notifyListeners();
  }

  /// Create a new company
  Future<Company?> createCompany(Company company, {File? logo}) async {
    final c = await _safeCall(
      () => _api.createCompany(company: company, logo: logo),
    );
    if (c != null) _myCompany = c;
    return c;
  }

  /// Update the current company
  Future<Company?> updateCompany(
    Map<String, dynamic> data, {
    File? logo,
    File? cover,
  }) async {
    if (_myCompany == null) return null;

    final updated = await _safeCall(
      () => _api.updateCompany(
        id: _myCompany!.id,
        updateData: data,
        logo: logo,
        cover: cover,
      ),
    );

    if (updated != null) _myCompany = updated;
    return updated;
  }

  /// Refresh the company
  Future<void> refreshCompany(int ownerId) async {
    await loadMyCompany(ownerId);
  }
}
