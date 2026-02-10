import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/models/user_model.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:provider/provider.dart';

// splash_screen.dart (Updated)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 2));

    // Get auth provider
    final auth = Provider.of<AuthProvider>(context, listen: false);

    await auth.tryAutoLogin();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = auth.isAuthenticated
          ? auth.getRoleBasedRoute()
          : RouteNames.login;

      Navigator.pushReplacementNamed(context, route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.work_outline,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            // App Name
            const Text(
              'Job Portal',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            // Tagline
            const Text(
              'Find Your Dream Job',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: AppSizes.xl),
            // Loading Indicator
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
