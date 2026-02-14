import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/core/services/storage_service.dart';
import 'package:job_portal_app/models/application_model.dart';


class ResumeApi {
  static const _base = '/api/resumes';

  // =============================
  // GET MY RESUMES
  // =============================
  static Future<List<Resume>> getMyResumes() async {
    final res = await ApiClient.get(
      _base,
      auth: true,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load resumes');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Resume.fromJson(e)).toList();
  }

  // =============================
  // UPLOAD RESUME (MULTIPART)
  // =============================
  static Future<Resume> uploadResume({
    required File file,
    String? title,
  }) async {
    final response = await ApiClient.multipart(
      'POST',
      _base,
      fields: {
        if (title != null) 'title': title,
      },
      files: {
        'file': file,
      },
      auth: true,
    );

    final body = await response.stream.bytesToString();

    if (response.statusCode != 201) {
      throw Exception('Resume upload failed');
    }

    return Resume.fromJson(jsonDecode(body));
  }

  // =============================
  // SET PRIMARY RESUME
  // =============================
  static Future<void> setPrimaryResume(int resumeId) async {
    final res = await ApiClient.put(
      '$_base/$resumeId/primary',
      auth: true,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to set primary resume');
    }
  }

  // =============================
  // DELETE RESUME
  // =============================
  static Future<void> deleteResume(int resumeId) async {
    final res = await ApiClient.delete(
      '$_base/$resumeId',
      auth: true,
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to delete resume');
    }
  }

  // =============================
  // DOWNLOAD RESUME (PDF BYTES)
  // =============================
  static Future<Uint8List> downloadResume(int resumeId) async {
    final token = await TokenStorage.getAccessToken();

    final uri = Uri.parse(
      '${AppConstants.baseUrl}$_base/$resumeId/download',
    );

    final response = await http.get(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to download resume');
    }

    return response.bodyBytes;
  }
}