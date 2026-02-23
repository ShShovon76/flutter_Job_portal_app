import 'package:flutter/material.dart';
import 'package:job_portal_app/core/api/category_api.dart';
import 'package:job_portal_app/models/category.dart';
import 'package:job_portal_app/models/job_search_filter.dart';

class CategoryProvider with ChangeNotifier {
  /* ============================================================
     STATE
     ============================================================ */

  bool loading = false;
  String? error;

  // Pagination
  Pagination<Category>? categoryPage;
  List<Category> categories = [];

  // Top categories
  Pagination<Category>? topCategoryPage;
  List<Category> topCategories = [];

  // Single
  Category? selectedCategory;

  int currentPage = 0;
  int pageSize = 10;
  bool hasMore = true;

  /* ============================================================
     INTERNAL SAFE CALL
     ============================================================ */

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

  /* ============================================================
     CLEAR METHODS
     ============================================================ */

  void clearPagination() {
    categories.clear();
    categoryPage = null;
    currentPage = 0;
    hasMore = true;
    notifyListeners();
  }

  void clearSelected() {
    selectedCategory = null;
    notifyListeners();
  }

  /* ============================================================
     GET ALL (NON PAGINATED)
     GET /categories/all
     ============================================================ */

  Future<void> loadAllCategories() async {
    final result = await _safeCall(() {
      return CategoryApi.getAllCategories();
    });

    if (result == null) return;

    categories = result;
    notifyListeners();
  }

  /* ============================================================
     PAGINATED CATEGORIES
     GET /categories
     ============================================================ */

  Future<void> loadCategories({bool refresh = false}) async {
    if (refresh) clearPagination();
    if (!hasMore || loading) return;

    final page = await _safeCall(() {
      return CategoryApi.getCategories(
        page: currentPage,
        size: pageSize,
      );
    });

    if (page == null) return;

    categoryPage = page;
    categories.addAll(page.items);

    hasMore = page.page < page.totalPages - 1;
    currentPage++;

    notifyListeners();
  }

  /* ============================================================
     TOP CATEGORIES
     GET /categories/top
     ============================================================ */

  Future<void> loadTopCategories({
    int page = 0,
    int size = 10,
  }) async {
    final pageResult = await _safeCall(() {
      return CategoryApi.getTopCategories(
        page: page,
        size: size,
      );
    });

    if (pageResult == null) return;

    topCategoryPage = pageResult;
    topCategories = pageResult.items;

    notifyListeners();
  }

  /* ============================================================
     SINGLE CATEGORY
     ============================================================ */

  Future<void> loadCategoryById(int id) async {
    selectedCategory = await _safeCall(() {
      return CategoryApi.getCategoryById(id);
    });
  }

  Future<void> loadCategoryByName(String name) async {
    selectedCategory = await _safeCall(() {
      return CategoryApi.getCategoryByName(name);
    });
  }

  /* ============================================================
     ADMIN CRUD
     ============================================================ */

  Future<Category?> createCategory(
      Category category) async {
    final created = await _safeCall(() {
      return CategoryApi.createCategory(category);
    });

    if (created != null) {
      categories.insert(0, created);
      notifyListeners();
    }

    return created;
  }

  Future<Category?> updateCategory(
      int id, Category category) async {
    final updated = await _safeCall(() {
      return CategoryApi.updateCategory(id, category);
    });

    if (updated != null) {
      final index =
          categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        categories[index] = updated;
        notifyListeners();
      }
    }

    return updated;
  }

  Future<void> deleteCategory(int id) async {
    await _safeCall(() {
      return CategoryApi.deleteCategory(id);
    });

    categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}