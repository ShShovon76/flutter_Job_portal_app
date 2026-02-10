// // route_guard.dart
// import 'package:flutter/material.dart';
// import 'package:job_portal_app/core/utils/role_wrapper.dart';
// import 'package:job_portal_app/features/auth/presentation/login_screen.dart';
// import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
// import 'package:job_portal_app/models/user_model.dart';
// import 'package:job_portal_app/routes/route_names.dart';
// import 'package:provider/provider.dart';


// class RouteGuard {
//   static bool canAccess(String routeName, UserRole? userRole) {
//     // Public routes accessible to everyone
//     final publicRoutes = [
//       RouteNames.splash,
//       RouteNames.login,
//       RouteNames.register,
//       RouteNames.roleSelection,
//       RouteNames.forgotPassword,
//       RouteNames.otpVerification,
//       RouteNames.noInternet,
//       RouteNames.error,
//     ];

//     if (publicRoutes.contains(routeName)) {
//       return true;
//     }

//     // Check role-based access
//     if (userRole == null) return false;

//     switch (userRole) {
//       case UserRole.JOB_SEEKER:
//         return routeName.startsWith('/job-seeker') ||
//                routeName == RouteNames.jobSeekerShell;
//       case UserRole.EMPLOYER:
//         return routeName.startsWith('/employer') ||
//                routeName == RouteNames.employerShell;
//       case UserRole.ADMIN:
//         return routeName.startsWith('/admin') ||
//                routeName == RouteNames.adminShell;
//       default:
//         return false;
//     }
//   }

//   static Widget guard(BuildContext context, String routeName) {
//     final auth = Provider.of<AuthProvider>(context);
    
//     if (!auth.isAuthenticated) {
//       return LoginScreen();
//     }
    
//     if (!canAccess(routeName, auth.user!.role)) {
//       // Redirect to role-specific home if trying to access unauthorized route
//       return RoleBasedRouter();
//     }
    
//     return SizedBox.shrink(); // Allow access
//   }
// }