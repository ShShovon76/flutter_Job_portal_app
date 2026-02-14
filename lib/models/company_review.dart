

class CompanyReview  {
  final int id;
  final int companyId;
  final int reviewerId;
  final double rating;
  final String title;
  final String comment;
  final DateTime createdAt;

  const CompanyReview({
    required this.id,
    required this.companyId,
    required this.reviewerId,
    required this.rating,
    required this.title,
    required this.comment,
    required this.createdAt,
  });

  
  // Optional: Create a copyWith method for immutability
  CompanyReview copyWith({
    int? id,
    int? companyId,
    int? reviewerId,
    double? rating,
    String? title,
    String? comment,
    DateTime? createdAt,
  }) {
    return CompanyReview(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      reviewerId: reviewerId ?? this.reviewerId,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CompanyReview.fromJson(Map<String, dynamic> json) {
    return CompanyReview(
      id: json['id'] as int,
      companyId: json['companyId'] as int,
      reviewerId: json['reviewerId'] as int,
      rating: (json['rating'] as num).toDouble(),
      title: json['title'] as String,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'reviewerId': reviewerId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}