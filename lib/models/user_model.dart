
enum UserRole {
  ADMIN,
  EMPLOYER,
  JOB_SEEKER,
}

extension UserRoleExtension on UserRole {
  String get value => toString().split('.').last;

  static UserRole? fromString(String? role) {
    if (role == null) return null;

    return UserRole.values.firstWhere(
      (e) => e.value == role,
      orElse: () => UserRole.JOB_SEEKER,
    );
  }
}

// --------------------
// User Model
// --------------------

class User {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final UserRole? role;
  final String? profilePictureUrl;
  final DateTime? createdAt;
  final bool? enabled;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.role,
    this.profilePictureUrl,
    this.createdAt,
    this.enabled,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      role: UserRoleExtension.fromString(json['role']),
      profilePictureUrl: json['profilePictureUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      enabled: json['enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role?.value,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt?.toIso8601String(),
      'enabled': enabled,
    };
  }

  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    String? profilePictureUrl,
    DateTime? createdAt,
    bool? enabled,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      enabled: enabled ?? this.enabled,
    );
  }
}