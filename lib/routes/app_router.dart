import 'package:flutter/material.dart';
import 'package:job_portal_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:job_portal_app/features/auth/presentation/login_screen.dart';
import 'package:job_portal_app/features/auth/presentation/register_screen.dart';
import 'package:job_portal_app/features/auth/presentation/role_selection_screen.dart';
import 'package:job_portal_app/features/auth/presentation/splash_screen.dart';
import 'package:job_portal_app/routes/route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case RouteNames.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterJobSeekerScreen(),
        );

      case RouteNames.roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());

      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
