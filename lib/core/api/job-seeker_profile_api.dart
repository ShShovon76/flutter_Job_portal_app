import 'dart:convert';

import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/models/analytics_models.dart';
import 'package:job_portal_app/models/job_search_filter.dart';
import 'package:job_portal_app/models/job_seeker_profile.dart';

class JobSeekerProfileApi {
  static const String _base = '/job-seekers';

  // ==================================================
  // GET PROFILE BY USER ID
  // GET /api/job-seekers/profile/{userId}
  // ==================================================
  static Future<JobSeekerProfile> getProfile(int userId) async {
    final res = await ApiClient.get('$_base/profile/$userId', auth: true);

    if (res.statusCode == 200) {
      return JobSeekerProfile.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to load job seeker profile');
  }

  // ==================================================
  // GET JOB SEEKER DASHBOARD
  // GET /api/job-seekers/{userId}/dashboard
  // ==================================================
  static Future<JobSeekerDashboardResponse> getDashboard(int userId) async {
    final res = await ApiClient.get('$_base/$userId/dashboard', auth: true);

    if (res.statusCode == 200) {
      return JobSeekerDashboardResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to load dashboard');
  }

  // ==================================================
  // GET APPLICANT PROFILE (EMPLOYER)
  // GET /api/job-seekers/applicant/{userId}
  // ==================================================
  static Future<ApplicantProfile> getApplicantProfile(int jobseekerId) async {
    final res = await ApiClient.get(
      '$_base/Jobseeker/$jobseekerId',
      auth: true,
    );
    print('Response status: ${res.statusCode}');
    print('Response body: ${res.body}');

    if (res.statusCode == 200) {
      return ApplicantProfile.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to load applicant profile');
  }

  // ==================================================
  // SEARCH JOB SEEKER PROFILES (PAGINATED)
  // GET /api/job-seekers/search
  // ==================================================
  static Future<Pagination<JobSeekerProfile>> searchProfiles({
    String? keyword,
    int page = 0,
    int size = 10,
  }) async {
    final query = StringBuffer('$_base/search?page=$page&size=$size');
    if (keyword != null && keyword.isNotEmpty) {
      query.write('&keyword=$keyword');
    }

    final res = await ApiClient.get(query.toString(), auth: true);

    if (res.statusCode == 200) {
      final mapped = _springPage(jsonDecode(res.body));
      return Pagination.fromJson(mapped, (e) => JobSeekerProfile.fromJson(e));
    }
    throw Exception('Failed to search profiles');
  }

  // ==================================================
  // CREATE OR UPDATE PROFILE
  // POST /api/job-seekers/profile/{userId}
  // ==================================================
  static Future<JobSeekerProfile> saveProfile(
    int userId,
    JobSeekerProfile profile,
  ) async {
    final res = await ApiClient.post(
      '$_base/profile/$userId',
      auth: true,
      body: profile.toJson(),
    );

    if (res.statusCode == 200) {
      return JobSeekerProfile.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to save profile');
  }

  // ==================================================
  // EDUCATION
  // ==================================================
  static Future<Education> addEducation(int userId, Education education) async {
    final res = await ApiClient.post(
      '$_base/$userId/education',
      auth: true,
      body: education.toJson(),
    );

    if (res.statusCode == 201) {
      return Education.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to add education');
  }

  static Future<Education> updateEducation(
    int userId,
    int educationId,
    Education education,
  ) async {
    final res = await ApiClient.put(
      '$_base/$userId/education/$educationId',
      auth: true,
      body: education.toJson(),
    );

    if (res.statusCode == 200) {
      return Education.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to update education');
  }

  static Future<List<Education>> getEducations(int userId) async {
    final res = await ApiClient.get('$_base/$userId/education', auth: true);

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => Education.fromJson(e)).toList();
    }
    throw Exception('Failed to load educations');
  }

  static Future<void> deleteEducation(int userId, int educationId) async {
    final res = await ApiClient.delete(
      '$_base/$userId/education/$educationId',
      auth: true,
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to delete education');
    }
  }

  // ==================================================
  // EXPERIENCE
  // ==================================================
  static Future<Experience> addExperience(
    int userId,
    Experience experience,
  ) async {
    final res = await ApiClient.post(
      '$_base/$userId/experience',
      auth: true,
      body: experience.toJson(),
    );

    if (res.statusCode == 201) {
      return Experience.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to add experience');
  }

  static Future<Experience> updateExperience(
    int userId,
    int experienceId,
    Experience experience,
  ) async {
    final res = await ApiClient.put(
      '$_base/$userId/experience/$experienceId',
      auth: true,
      body: experience.toJson(),
    );

    if (res.statusCode == 200) {
      return Experience.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to update experience');
  }

  static Future<void> deleteExperience(int userId, int experienceId) async {
    final res = await ApiClient.delete(
      '$_base/$userId/experience/$experienceId',
      auth: true,
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to delete experience');
    }
  }

  static Future<List<Experience>> getExperiences(int userId) async {
    final res = await ApiClient.get('$_base/$userId/experience', auth: true);

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => Experience.fromJson(e)).toList();
    }
    throw Exception('Failed to load experiences');
  }

  // ==================================================
  // CERTIFICATIONS
  // ==================================================
  static Future<Certification> addCertification(
    int userId,
    Certification certification,
  ) async {
    final res = await ApiClient.post(
      '$_base/$userId/certifications',
      auth: true,
      body: certification.toJson(),
    );

    if (res.statusCode == 201) {
      return Certification.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to add certification');
  }

  static Future<Certification> updateCertification(
    int userId,
    int certificationId,
    Certification certification,
  ) async {
    final res = await ApiClient.put(
      '$_base/$userId/certifications/$certificationId',
      auth: true,
      body: certification.toJson(),
    );

    if (res.statusCode == 200) {
      return Certification.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to update certification');
  }

  static Future<void> deleteCertification(
    int userId,
    int certificationId,
  ) async {
    final res = await ApiClient.delete(
      '$_base/$userId/certifications/$certificationId',
      auth: true,
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to delete certification');
    }
  }

  static Future<List<Certification>> getCertifications(int userId) async {
    final res = await ApiClient.get(
      '$_base/$userId/certifications',
      auth: true,
    );

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => Certification.fromJson(e)).toList();
    }
    throw Exception('Failed to load certifications');
  }
}

Map<String, dynamic> _springPage(Map<String, dynamic> json) {
  return {
    'items': json['content'],
    'page': json['number'],
    'size': json['size'],
    'totalItems': json['totalElements'],
    'totalPages': json['totalPages'],
  };
}
