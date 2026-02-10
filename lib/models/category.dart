class Category {
  final int id;
  final String name;
  final String? description;
  final int? jobCount;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.jobCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      jobCount: json['jobCount'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'jobCount': jobCount,
      };
}
