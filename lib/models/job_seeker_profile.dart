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
    final userIdValue = json['userId'];

    if (userIdValue == null) {
      throw Exception("JobSeekerProfile JSON missing required field: userId");
    }

    return JobSeekerProfile(
      id: json['id'] as int,
      userId: userIdValue as int,
      headline: json['headline'] as String?,
      summary: json['summary'] as String?,
      skills: List<String>.from(json['skills'] ?? []),
      education: (json['education'] as List? ?? [])
          .map((e) => Education.fromJson(e))
          .toList(),
      experience: (json['experience'] as List? ?? [])
          .map((e) => Experience.fromJson(e))
          .toList(),
      certifications: (json['certifications'] as List? ?? [])
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'headline': headline,
    'summary': summary,
    'skills': skills,
    'education': education.map((e) => e.toJson()).toList(),
    'experience': experience.map((e) => e.toJson()).toList(),
    'certifications': certifications.map((e) => e.toJson()).toList(),
    'portfolioLinks': portfolioLinks,
    'resumes': resumes?.map((e) => e.toJson()).toList(),
    'preferredJobTypes': preferredJobTypes,
    'preferredLocations': preferredLocations,
    'applications': applications?.map((e) => e.toJson()).toList(),
    'savedJobs': savedJobs?.map((e) => e.toJson()).toList(),
    'savedCompanies': savedCompanies?.map((e) => e.toJson()).toList(),
  };

  JobSeekerProfile copyWith({
    int? id,
    int? userId,
    String? headline,
    String? summary,
    List<String>? skills,
    List<Education>? education,
    List<Experience>? experience,
    List<Certification>? certifications,
    List<String>? portfolioLinks,
    List<Resume>? resumes,
    List<String>? preferredJobTypes,
    List<String>? preferredLocations,
    List<JobApplication>? applications,
    List<SavedJob>? savedJobs,
    List<SavedCompany>? savedCompanies,
  }) {
    return JobSeekerProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      headline: headline ?? this.headline,
      summary: summary ?? this.summary,
      skills: skills ?? this.skills,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      certifications: certifications ?? this.certifications,
      portfolioLinks: portfolioLinks ?? this.portfolioLinks,
      resumes: resumes ?? this.resumes,
      preferredJobTypes: preferredJobTypes ?? this.preferredJobTypes,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      applications: applications ?? this.applications,
      savedJobs: savedJobs ?? this.savedJobs,
      savedCompanies: savedCompanies ?? this.savedCompanies,
    );
  }
}

class Certification {
  final int? id;
  final String title;
  final String issuer;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? credentialUrl;

  Certification({
    this.id,
    required this.title,
    required this.issuer,
    required this.issueDate,
    this.expiryDate,
    this.credentialUrl,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      id: json['id'],
      title: json['title'],
      issuer: json['issuer'],
      issueDate: DateTime.parse(json['issueDate']),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      credentialUrl: json['credentialUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'title': title,
      'issuer': issuer,
      'issueDate': _formatDate(issueDate),
      'expiryDate': expiryDate != null ? _formatDate(expiryDate!) : null,
      'credentialUrl': credentialUrl,
    };
    
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
extension CertificationCopy on Certification {
  Certification copyWith({
    int? id,
    String? title,
    String? issuer,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? credentialUrl,
  }) {
    return Certification(
      id: id ?? this.id,
      title: title ?? this.title,
      issuer: issuer ?? this.issuer,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      credentialUrl: credentialUrl ?? this.credentialUrl,
    );
  }
}

class Experience {
  final int? id;
  final String companyName;
  final String jobTitle;
  final DateTime startDate;
  final DateTime? endDate;
  final String responsibilities;

  Experience({
    this.id,
    required this.companyName,
    required this.jobTitle,
    required this.startDate,
    this.endDate,
    required this.responsibilities,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'],
      companyName: json['companyName'],
      jobTitle: json['jobTitle'],
      startDate: DateTime.parse('${json['startDate']}T00:00:00'),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      responsibilities: json['responsibilities'],
    );
  }

 Map<String, dynamic> toJson() {
  final Map<String, dynamic> map = {
    'companyName': companyName,
    'jobTitle': jobTitle,
    'startDate': _formatDate(startDate),
    'endDate': endDate != null ? _formatDate(endDate!) : null,
    'responsibilities': responsibilities,
  };

  if (id != null) {
    map['id'] = id;
  }

  return map;
}
}

extension ExperienceCopy on Experience {
  Experience copyWith({
    int? id,
    String? companyName,
    String? jobTitle,
    DateTime? startDate,
    DateTime? endDate,
    String? responsibilities,
  }) {
    return Experience(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      responsibilities: responsibilities ?? this.responsibilities,
    );
  }
}

class Education {
  final int? id;
  final String degree;
  final String institution;
  final DateTime startDate;
  final DateTime? endDate;
  final String? grade;

  Education({
    this.id,
    required this.degree,
    required this.institution,
    required this.startDate,
    this.endDate,
    this.grade,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'],
      degree: json['degree'],
      institution: json['institution'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      grade: json['grade'],
    );
  }

 Map<String, dynamic> toJson() {
  final Map<String, dynamic> map = {
    'degree': degree,
    'institution': institution,
    'startDate': _formatDate(startDate),
    'endDate': endDate != null ? _formatDate(endDate!) : null,
    'grade': grade,
  };

  if (id != null) {
    map['id'] = id;
  }

  return map;
}
}

String _formatDate(DateTime date) {
  return "${date.year.toString().padLeft(4, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')}";
}

extension EducationCopy on Education {
  Education copyWith({
    int? id,
    String? degree,
    String? institution,
    DateTime? startDate,
    DateTime? endDate,
    String? grade,
  }) {
    return Education(
      id: id ?? this.id,
      degree: degree ?? this.degree,
      institution: institution ?? this.institution,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      grade: grade ?? this.grade,
    );
  }
}


class ApplicantProfile {
  final int? userId;
  final String fullName;
  final String email;
  final String? phone;
  final String? profilePictureUrl;

  final String? headline;
  final String? summary;

  final List<String> skills;
  final List<Education> education;
  final List<Experience> experience;
  final List<Certification> certifications;
  final List<Resume> resumes;

  final List<String> preferredJobTypes;
  final List<String> preferredLocations;

  ApplicantProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phone,
    this.profilePictureUrl,
    this.headline,
    this.summary,
    required this.skills,
    required this.education,
    required this.experience,
    required this.certifications,
    required this.resumes,
    required this.preferredJobTypes,
    required this.preferredLocations,
  });

  factory ApplicantProfile.fromJson(Map<String, dynamic> json) {
    return ApplicantProfile(
      userId: json['userId'] as int?,
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      profilePictureUrl: json['profilePictureUrl'],
      headline: json['headline'],
      summary: json['summary'],
      skills: List<String>.from(json['skills'] ?? []),
      education: (json['education'] as List? ?? [])
          .map((e) => Education.fromJson(e))
          .toList(),
      experience: (json['experience'] as List? ?? [])
          .map((e) => Experience.fromJson(e))
          .toList(),
      certifications: (json['certifications'] as List? ?? [])
          .map((e) => Certification.fromJson(e))
          .toList(),
      resumes: (json['resumes'] as List? ?? [])
          .map((e) => Resume.fromJson(e))
          .toList(),
      preferredJobTypes: List<String>.from(json['preferredJobTypes'] ?? []),
      preferredLocations: List<String>.from(json['preferredLocations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profilePictureUrl': profilePictureUrl,
      'headline': headline,
      'summary': summary,
      'skills': skills,
      'education': education.map((e) => e.toJson()).toList(),
      'experience': experience.map((e) => e.toJson()).toList(),
      'certifications': certifications.map((e) => e.toJson()).toList(),
      'resumes': resumes.map((e) => e.toJson()).toList(),
      'preferredJobTypes': preferredJobTypes,
      'preferredLocations': preferredLocations,
    };
  }
}

extension ApplicantProfileCopy on ApplicantProfile {
  ApplicantProfile copyWith({
    int? userId,
    String? fullName,
    String? email,
    String? phone,
    String? profilePictureUrl,
    String? headline,
    String? summary,
    List<String>? skills,
    List<Education>? education,
    List<Experience>? experience,
    List<Certification>? certifications,
    List<Resume>? resumes,
    List<String>? preferredJobTypes,
    List<String>? preferredLocations,
  }) {
    return ApplicantProfile(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      headline: headline ?? this.headline,
      summary: summary ?? this.summary,
      skills: skills ?? this.skills,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      certifications: certifications ?? this.certifications,
      resumes: resumes ?? this.resumes,
      preferredJobTypes: preferredJobTypes ?? this.preferredJobTypes,
      preferredLocations: preferredLocations ?? this.preferredLocations,
    );
  }
}
