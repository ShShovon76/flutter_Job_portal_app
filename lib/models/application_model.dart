// application_models.dart

// --------------------
// Application Status Enum
// --------------------



import 'package:job_portal_app/models/user_model.dart';

enum ApplicationStatus {
  APPLIED,
  UNDER_REVIEW,
  SHORTLISTED,
  INTERVIEW,
  OFFERED,
  REJECTED,
  CANCELLED,
}

extension ApplicationStatusExtension on ApplicationStatus {
  String get value {
    return toString().split('.').last;
  }

  static ApplicationStatus fromString(String status) {
    return ApplicationStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => ApplicationStatus.APPLIED,
    );
  }
}

// --------------------
// Job Application Model
// --------------------

class JobApplication {
  final int id;

  final int jobId;
  final String? jobTitle;
  final String? companyName;

  final int jobSeekerId;
  final String? jobSeekerName;
  final String? jobSeekerEmail;
  final String? jobSeekerProfilePicture;

  final int? resumeId;
  final String? resumeUrl;
  final String? resumeTitle;

  final String? coverLetter;
  final ApplicationStatus status;
  final String appliedAt;

  JobApplication({
    required this.id,
    required this.jobId,
    this.jobTitle,
    this.companyName,
    required this.jobSeekerId,
    this.jobSeekerName,
    this.jobSeekerEmail,
    this.jobSeekerProfilePicture,
    this.resumeId,
    this.resumeUrl,
    this.resumeTitle,
    this.coverLetter,
    required this.status,
    required this.appliedAt,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'],
      jobId: json['jobId'],
      jobTitle: json['jobTitle'],
      companyName: json['companyName'],
      jobSeekerId: json['jobSeekerId'],
      jobSeekerName: json['jobSeekerName'],
      jobSeekerEmail: json['jobSeekerEmail'],
      jobSeekerProfilePicture: json['jobSeekerProfilePicture'],
      resumeId: json['resumeId'],
      resumeUrl: json['resumeUrl'],
      resumeTitle: json['resumeTitle'],
      coverLetter: json['coverLetter'],
      status: ApplicationStatusExtension.fromString(json['status']),
      appliedAt: json['appliedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'jobSeekerId': jobSeekerId,
      'jobSeekerName': jobSeekerName,
      'jobSeekerEmail': jobSeekerEmail,
      'jobSeekerProfilePicture': jobSeekerProfilePicture,
      'resumeId': resumeId,
      'resumeUrl': resumeUrl,
      'resumeTitle': resumeTitle,
      'coverLetter': coverLetter,
      'status': status.value,
      'appliedAt': appliedAt,
    };
  }
}

// --------------------
// Resume Model
// --------------------

class Resume {
  final int id;
  final String title;
  final String fileUrl;
  final String uploadedAt;
  final bool primaryResume;

  Resume({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.uploadedAt,
    required this.primaryResume,
  });

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      id: json['id'],
      title: json['title'],
      fileUrl: json['fileUrl'],
      uploadedAt: json['uploadedAt'],
      primaryResume: json['primaryResume'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fileUrl': fileUrl,
      'uploadedAt': uploadedAt,
      'primaryResume': primaryResume,
    };
  }
}
// Application Status History
// --------------------

class ApplicationStatusHistory {
  final int id;
  final int applicationId;
  final ApplicationStatus fromStatus;
  final ApplicationStatus toStatus;
  final String? note;
  final DateTime changedAt;
  final User? changedBy;

  ApplicationStatusHistory({
    required this.id,
    required this.applicationId,
    required this.fromStatus,
    required this.toStatus,
    this.note,
    required this.changedAt,
    this.changedBy,
  });

  factory ApplicationStatusHistory.fromJson(Map<String, dynamic> json) {
    return ApplicationStatusHistory(
      id: json['id'],
      applicationId: json['applicationId'],
      fromStatus:
          ApplicationStatusExtension.fromString(json['fromStatus']),
      toStatus:
          ApplicationStatusExtension.fromString(json['toStatus']),
      note: json['note'],
      changedAt: DateTime.parse(json['changedAt']),
      changedBy: json['changedBy'] != null
          ? User.fromJson(json['changedBy'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicationId': applicationId,
      'fromStatus': fromStatus.value,
      'toStatus': toStatus.value,
      'note': note,
      'changedAt': changedAt.toIso8601String(),
      'changedBy': changedBy?.toJson(),
    };
  }
}

// --------------------
// Update Application Status Request
// --------------------

class UpdateApplicationStatusRequest {
  final ApplicationStatus status;

  UpdateApplicationStatusRequest({
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status.value,
    };
  }
}