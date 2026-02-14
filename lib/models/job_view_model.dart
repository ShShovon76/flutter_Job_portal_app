class JobView {
  final int id;
  final int jobId;
  final int? viewerId;
  final String? ipAddress;
  final String? userAgent;
  final DateTime viewDate;

  JobView({
    required this.id,
    required this.jobId,
    this.viewerId,
    this.ipAddress,
    this.userAgent,
    required this.viewDate,
  });

  factory JobView.fromJson(Map<String, dynamic> json) {
    return JobView(
      id: json['id'],
      jobId: json['jobId'],
      viewerId: json['viewerId'],
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      viewDate: DateTime.parse(json['viewDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'viewerId': viewerId,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'viewDate': viewDate.toIso8601String(),
    };
  }
}
