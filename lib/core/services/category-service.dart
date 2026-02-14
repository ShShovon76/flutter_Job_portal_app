import 'dart:convert';
import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/models/category.dart';
import 'package:job_portal_app/models/job_search_filter.dart';

class CategoryService {
  // ---------------------------
  // GET ALL CATEGORIES (No Pagination)
  // ---------------------------
  Future<List<Category>> getAllCategories() async {
    try {
      final response = await ApiClient.get(
        '/categories/all',
        auth: false, // Public endpoint
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching all categories: $e');
    }
  }

  // ---------------------------
  // GET CATEGORIES (Paginated)
  // ---------------------------
  Future<Pagination<Category>> getCategories({
    int page = 0,
    int size = 10,
    String sortBy = 'id',
    String sortDirection = 'asc',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        'sort': '$sortBy,$sortDirection',
      };

      final uri = Uri.parse(
        '${AppConstants.baseUrl}/categories',
      ).replace(queryParameters: queryParams);

      final response = await ApiClient.get(
        '${uri.path}${uri.query}',
        auth: false,
      );

      if (response.statusCode == 200) {
        return Pagination<Category>.fromJson(
          jsonDecode(response.body),
          (json) => Category.fromJson(json),
        );
      } else {
        throw Exception(
          'Failed to load paginated categories: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching paginated categories: $e');
    }
  }

  // ---------------------------
  // GET TOP CATEGORIES
  // ---------------------------
  Future<Pagination<Category>> getTopCategories({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final queryParams = {'page': page.toString(), 'size': size.toString()};

      final uri = Uri.parse(
        '${AppConstants.baseUrl}/categories/top',
      ).replace(queryParameters: queryParams);

      final response = await ApiClient.get(
        '${uri.path}${uri.query}',
        auth: false,
      );

      if (response.statusCode == 200) {
        return Pagination<Category>.fromJson(
          jsonDecode(response.body),
          (json) => Category.fromJson(json),
        );
      } else {
        throw Exception(
          'Failed to load top categories: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching top categories: $e');
    }
  }

  // ---------------------------
  // GET CATEGORY BY ID
  // ---------------------------
  Future<Category> getCategoryById(int id) async {
    try {
      final response = await ApiClient.get('/categories/$id', auth: false);

      if (response.statusCode == 200) {
        return Category.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Category not found with ID: $id');
      } else {
        throw Exception('Failed to load category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching category by ID: $e');
    }
  }

  // ---------------------------
  // GET CATEGORY BY NAME
  // ---------------------------
  Future<Category> getCategoryByName(String name) async {
    try {
      final encodedName = Uri.encodeComponent(name);
      final response = await ApiClient.get(
        '/categories/name/$encodedName',
        auth: false,
      );

      if (response.statusCode == 200) {
        return Category.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Category not found with name: $name');
      } else {
        throw Exception('Failed to load category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching category by name: $e');
    }
  }

  // ---------------------------
  // CREATE CATEGORY (Admin only)
  // ---------------------------
  Future<Category> createCategory(Category category) async {
    try {
      final response = await ApiClient.post(
        '/categories',
        body: category.toJson(),
        auth: true, // Requires authentication
      );

      if (response.statusCode == 201) {
        return Category.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        throw Exception('Invalid category data');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to create category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating category: $e');
    }
  }

  // ---------------------------
  // UPDATE CATEGORY (Admin only)
  // ---------------------------
  Future<Category> updateCategory(int id, Category category) async {
    try {
      final response = await ApiClient.put(
        '/categories/$id',
        body: category.toJson(),
        auth: true,
      );

      if (response.statusCode == 200) {
        return Category.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        throw Exception('Invalid category data');
      } else if (response.statusCode == 404) {
        throw Exception('Category not found with ID: $id');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to update category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  // ---------------------------
  // DELETE CATEGORY (Admin only)
  // ---------------------------
  Future<void> deleteCategory(int id) async {
    try {
      final response = await ApiClient.delete('/categories/$id', auth: true);

      if (response.statusCode == 204) {
        return; // Success - No content
      } else if (response.statusCode == 404) {
        throw Exception('Category not found with ID: $id');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden - Admin access required');
      } else {
        throw Exception('Failed to delete category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }
}
