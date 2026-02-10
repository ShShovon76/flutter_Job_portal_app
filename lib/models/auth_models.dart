



import 'package:job_portal_app/models/user_model.dart';

/// -------- LOGIN REQUEST ----------
class AuthRequest {
  final String email;
  final String password;

  AuthRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

/// -------- AUTH RESPONSE ----------
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: User.fromJson(json['user']),
    );
  }
}

/// -------- REGISTER JOB SEEKER ----------
class RegisterJobSeekerRequest {
  final String fullName;
  final String email;
  final String password;

  RegisterJobSeekerRequest({
    required this.fullName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'password': password,
      };
}

/// -------- REGISTER EMPLOYER ----------
class RegisterEmployerRequest {
  final String fullName;
  final String email;
  final String password;
  final String companyName;

  RegisterEmployerRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.companyName,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'password': password,
        'companyName': companyName,
      };
}

/// -------- REFRESH TOKEN ----------
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest(this.refreshToken);

  Map<String, dynamic> toJson() => {
        'refreshToken': refreshToken,
      };
}
