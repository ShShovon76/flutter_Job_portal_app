

// Saved Job Model

import 'package:job_portal_app/models/job_model.dart';

class SavedJob {
  final int id;
  final int jobId;
  final int jobSeekerId;
  final DateTime savedAt;
  final Job? job;

  SavedJob({
    required this.id,
    required this.jobId,
    required this.jobSeekerId,
    required this.savedAt,
    this.job,
  });

  factory SavedJob.fromJson(Map<String, dynamic> json) {
    return SavedJob(
      id: json['id'],
      jobId: json['jobId'],
      jobSeekerId: json['jobSeekerId'],
      savedAt: DateTime.parse(json['savedAt']),
      job: json['job'] != null ? Job.fromJson(json['job']) : null,
    );
  }
}
