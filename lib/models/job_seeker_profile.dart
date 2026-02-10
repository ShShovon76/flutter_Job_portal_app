

import 'package:job_portal_app/models/application_model.dart';
import 'package:job_portal_app/models/saved_company.dart';
import 'package:job_portal_app/models/saved_job.dart';

class JobSeekerProfile {
  final int id;
  final int userId;
  final String? headline;
  final String? summary;

  final List<String> skills;
  final List<Education> education;
  final List<Experience> experience;
  final List<Certification> certifications;
  final List<String> portfolioLinks;

  final List<Resume>? resumes;
  final List<String> preferredJobTypes;
  final List<String> preferredLocations;

  final List<JobApplication>? applications;
  final List<SavedJob>? savedJobs;
  final List<SavedCompany>? savedCompanies;

  JobSeekerProfile({
    required this.id,
    required this.userId,
    this.headline,
    this.summary,
    required this.skills,
    required this.education,
    required this.experience,
    required this.certifications,
    required this.portfolioLinks,
    this.resumes,
    required this.preferredJobTypes,
    required this.preferredLocations,
    this.applications,
    this.savedJobs,
    this.savedCompanies,
  });

  factory JobSeekerProfile.fromJson(Map<String, dynamic> json) {
    return JobSeekerProfile(
      id: json['id'],
      userId: json['userId'],
      headline: json['headline'],
      summary: json['summary'],
      skills: List<String>.from(json['skills'] ?? []),
      education: (json['education'] as List)
          .map((e) => Education.fromJson(e))
          .toList(),
      experience: (json['experience'] as List)
          .map((e) => Experience.fromJson(e))
          .toList(),
      certifications: (json['certifications'] as List)
          .map((e) => Certification.fromJson(e))
          .toList(),
      portfolioLinks: List<String>.from(json['portfolioLinks'] ?? []),
      resumes: json['resumes'] != null
          ? (json['resumes'] as List).map((e) => Resume.fromJson(e)).toList()
          : null,
      preferredJobTypes: List<String>.from(json['preferredJobTypes'] ?? []),
      preferredLocations: List<String>.from(json['preferredLocations'] ?? []),
      applications: json['applications'] != null
          ? (json['applications'] as List)
                .map((e) => JobApplication.fromJson(e))
                .toList()
          : null,
      savedJobs: json['savedJobs'] != null
          ? (json['savedJobs'] as List)
                .map((e) => SavedJob.fromJson(e))
                .toList()
          : null,
      savedCompanies: json['savedCompanies'] != null
          ? (json['savedCompanies'] as List)
                .map((e) => SavedCompany.fromJson(e))
                .toList()
          : null,
    );
  }
}

class Certification {
  final String title;
  final String issuer;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? credentialUrl;

  Certification({
    required this.title,
    required this.issuer,
    required this.issueDate,
    this.expiryDate,
    this.credentialUrl,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      title: json['title'],
      issuer: json['issuer'],
      issueDate: DateTime.parse(json['issueDate']),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      credentialUrl: json['credentialUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'issuer': issuer,
    'issueDate': issueDate.toIso8601String(),
    'expiryDate': expiryDate?.toIso8601String(),
    'credentialUrl': credentialUrl,
  };
}

class Experience {
  final String companyName;
  final String jobTitle;
  final DateTime startDate;
  final DateTime? endDate;
  final String responsibilities;

  Experience({
    required this.companyName,
    required this.jobTitle,
    required this.startDate,
    this.endDate,
    required this.responsibilities,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      companyName: json['companyName'],
      jobTitle: json['jobTitle'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      responsibilities: json['responsibilities'],
    );
  }

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'jobTitle': jobTitle,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'responsibilities': responsibilities,
  };
}

class Education {
  final String degree;
  final String institution;
  final DateTime startDate;
  final DateTime? endDate;
  final String? grade;

  Education({
    required this.degree,
    required this.institution,
    required this.startDate,
    this.endDate,
    this.grade,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      degree: json['degree'],
      institution: json['institution'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      grade: json['grade'],
    );
  }

  Map<String, dynamic> toJson() => {
    'degree': degree,
    'institution': institution,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'grade': grade,
  };
}
