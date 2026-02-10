
class Job {
  final int id;

  final SimpleUser employer;
  final SimpleCompany company;
  final SimpleCategory category;

  final String title;
  final String description;

  final JobType jobType;
  final ExperienceLevel experienceLevel;

  final double? minSalary;
  final double? maxSalary;
  final SalaryType salaryType;

  final String location;
  final bool remoteAllowed;
  final List<String> skills;

  final DateTime postedAt;
  final DateTime deadline;

  final JobStatus status;

  final int? viewsCount;
  final int? applicantsCount;

  Job({
    required this.id,
    required this.employer,
    required this.company,
    required this.category,
    required this.title,
    required this.description,
    required this.jobType,
    required this.experienceLevel,
    this.minSalary,
    this.maxSalary,
    required this.salaryType,
    required this.location,
    required this.remoteAllowed,
    required this.skills,
    required this.postedAt,
    required this.deadline,
    required this.status,
    this.viewsCount,
    this.applicantsCount,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      employer: SimpleUser.fromJson(json['employer']),
      company: SimpleCompany.fromJson(json['company']),
      category: SimpleCategory.fromJson(json['category']),
      title: json['title'],
      description: json['description'],
      jobType: JobType.values.byName(json['jobType']),
      experienceLevel:
          ExperienceLevel.values.byName(json['experienceLevel']),
      minSalary: json['minSalary']?.toDouble(),
      maxSalary: json['maxSalary']?.toDouble(),
      salaryType: SalaryType.values.byName(json['salaryType']),
      location: json['location'],
      remoteAllowed: json['remoteAllowed'],
      skills: List<String>.from(json['skills']),
      postedAt: DateTime.parse(json['postedAt']),
      deadline: DateTime.parse(json['deadline']),
      status: JobStatus.values.byName(json['status']),
      viewsCount: json['viewsCount'],
      applicantsCount: json['applicantsCount'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employer': employer.toJson(),
        'company': company.toJson(),
        'category': category.toJson(),
        'title': title,
        'description': description,
        'jobType': jobType.name,
        'experienceLevel': experienceLevel.name,
        'minSalary': minSalary,
        'maxSalary': maxSalary,
        'salaryType': salaryType.name,
        'location': location,
        'remoteAllowed': remoteAllowed,
        'skills': skills,
        'postedAt': postedAt.toIso8601String(),
        'deadline': deadline.toIso8601String(),
        'status': status.name,
        'viewsCount': viewsCount,
        'applicantsCount': applicantsCount,
      };
}


// =======================
// SIMPLE MODELS
// =======================

class SimpleUser {
  final int id;
  final String fullName;

  SimpleUser({
    required this.id,
    required this.fullName,
  });

  factory SimpleUser.fromJson(Map<String, dynamic> json) {
    return SimpleUser(
      id: json['id'],
      fullName: json['fullName'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
      };
}

class SimpleCompany {
  final int id;
  final String name;
  final String? logoUrl;

  SimpleCompany({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  factory SimpleCompany.fromJson(Map<String, dynamic> json) {
    return SimpleCompany(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logoUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logoUrl': logoUrl,
      };
}

class SimpleCategory {
  final int id;
  final String name;

  SimpleCategory({
    required this.id,
    required this.name,
  });

  factory SimpleCategory.fromJson(Map<String, dynamic> json) {
    return SimpleCategory(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

enum JobType {
  FULL_TIME,
  PART_TIME,
  CONTRACT,
  REMOTE,
  INTERNSHIP,
  FREELANCE,
}

enum ExperienceLevel {
  ENTRY,
  MID,
  SENIOR,
  DIRECTOR,
  EXECUTIVE,
}

enum SalaryType {
  MONTHLY,
  YEARLY,
  HOURLY,
  WEEKLY,
}

enum JobStatus {
  ACTIVE,
  CLOSED,
  DRAFT,
}
