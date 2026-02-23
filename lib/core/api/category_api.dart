import 'dart:convert';

import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/models/category.dart';
import 'package:job_portal_app/models/job_search_filter.dart';


class CategoryApi {
  static const String _base = '/categories';

  // ------------------------------------------------------------
  // GET /categories/all
  // ------------------------------------------------------------
  static Future<List<Category>> getAllCategories() async {
    final res = await ApiClient.get('$_base/all');

    final List data = jsonDecode(res.body);
    return data.map((e) => Category.fromJson(e)).toList();
  }

  // ------------------------------------------------------------
  // GET /categories?page=&size=
  // ------------------------------------------------------------
  static Future<Pagination<Category>> getCategories({
    int page = 0,
    int size = 10,
    String sort = 'name,asc',
  }) async {
    final res = await ApiClient.get(
      '$_base?page=$page&size=$size&sort=$sort',
    );

    final json = jsonDecode(res.body);

    return Pagination.fromJson(
      json,
      (e) => Category.fromJson(e),
    );
  }

  // ------------------------------------------------------------
  // GET /categories/top?page=&size=
  // ------------------------------------------------------------
  static Future<Pagination<Category>> getTopCategories({
    int page = 0,
    int size = 10,
  }) async {
    final res = await ApiClient.get(
      '$_base/top?page=$page&size=$size',
    );

    final json = jsonDecode(res.body);

    return Pagination.fromJson(
      json,
      (e) => Category.fromJson(e),
    );
  }

  // ------------------------------------------------------------
  // GET /categories/{id}
  // ------------------------------------------------------------
  static Future<Category> getCategoryById(int id) async {
    final res = await ApiClient.get('$_base/$id');

    return Category.fromJson(jsonDecode(res.body));
  }

  // ------------------------------------------------------------
  // GET /categories/name/{name}
  // ------------------------------------------------------------
  static Future<Category> getCategoryByName(String name) async {
    final encoded = Uri.encodeComponent(name);

    final res = await ApiClient.get('$_base/name/$encoded');

    return Category.fromJson(jsonDecode(res.body));
  }

  /* ============================================================
     ADMIN / CRUD ENDPOINTS
     ============================================================ */

  // ------------------------------------------------------------
  // POST /categories
  // ------------------------------------------------------------
  static Future<Category> createCategory(
      Category category) async {
    final res = await ApiClient.post(
      _base,
      body: category.toJson(),
      auth: true,
    );

    return Category.fromJson(jsonDecode(res.body));
  }

  // ------------------------------------------------------------
  // PUT /categories/{id}
  // ------------------------------------------------------------
  static Future<Category> updateCategory(
      int id, Category category) async {
    final res = await ApiClient.put(
      '$_base/$id',
      body: category.toJson(),
      auth: true,
    );

    return Category.fromJson(jsonDecode(res.body));
  }

  // ------------------------------------------------------------
  // DELETE /categories/{id}
  // ------------------------------------------------------------
  static Future<void> deleteCategory(int id) async {
    await ApiClient.delete(
      '$_base/$id',
      auth: true,
    );
  }
}