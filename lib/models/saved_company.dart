// Saved Company Model

import 'package:job_portal_app/models/company_model.dart';

class SavedCompany {
  final int id;
  final int companyId;
  final int jobSeekerId;
  final DateTime savedAt;
  final Company? company;

  SavedCompany({
    required this.id,
    required this.companyId,
    required this.jobSeekerId,
    required this.savedAt,
    this.company,
  });

  factory SavedCompany.fromJson(Map<String, dynamic> json) {
    return SavedCompany(
      id: json['id'],
      companyId: json['companyId'],
      jobSeekerId: json['jobSeekerId'],
      savedAt: DateTime.parse(json['savedAt']),
      company:
          json['company'] != null ? Company.fromJson(json['company']) : null,
    );
  }
}
