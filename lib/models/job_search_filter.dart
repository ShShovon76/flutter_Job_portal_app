class SalaryRange {
  final double? min;
  final double? max;

  SalaryRange({this.min, this.max});

  Map<String, dynamic> toJson() => {
        'min': min,
        'max': max,
      };
}


class JobSearchFilter {
  final String? keyword;
  final String? location;
  final int? categoryId;
  final JobType? jobType;
  final SalaryRange? salaryRange;
  final ExperienceLevel? experienceLevel;
  final bool? remote;
  final int? page;
  final int? size;
  final int? companyId;

  JobSearchFilter({
    this.keyword,
    this.location,
    this.categoryId,
    this.jobType,
    this.salaryRange,
    this.experienceLevel,
    this.remote,
    this.page,
    this.size,
    this.companyId,
  });

  Map<String, dynamic> toJson() => {
        'keyword': keyword,
        'location': location,
        'categoryId': categoryId,
        'jobType': jobType?.name,
        'salaryRange': salaryRange?.toJson(),
        'experienceLevel': experienceLevel?.name,
        'remote': remote,
        'page': page,
        'size': size,
        'companyId': companyId,
      };
}
class Pagination<T> {
  final List<T> items;
  final int page;
  final int size;
  final int totalItems;
  final int totalPages;

  Pagination({
    required this.items,
    required this.page,
    required this.size,
    required this.totalItems,
    required this.totalPages,
  });

  factory Pagination.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return Pagination(
      items: (json['items'] as List).map(fromJsonT).toList(),
      page: json['page'],
      size: json['size'],
      totalItems: json['totalItems'],
      totalPages: json['totalPages'],
    );
  }
}
enum JobType {
  FULL_TIME,
  PART_TIME,
  CONTRACT,
  INTERNSHIP,
  FREELANCE,
}

enum ExperienceLevel {
  ENTRY,
  MID,
  SENIOR,
}

JobType? jobTypeFromString(String? value) {
  if (value == null) return null;
  return JobType.values.firstWhere(
    (e) => e.name == value,
  );
}

ExperienceLevel? experienceLevelFromString(String? value) {
  if (value == null) return null;
  return ExperienceLevel.values.firstWhere(
    (e) => e.name == value,
  );
}
