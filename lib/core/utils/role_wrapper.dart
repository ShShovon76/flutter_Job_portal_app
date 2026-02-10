// role_wrapper.dart
import 'package:flutter/material.dart';
import 'package:job_portal_app/features/admin/shell/admin_shell.dart';
import 'package:job_portal_app/features/auth/presentation/login_screen.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/features/employer/presentation/shell/employer_shell.dart';
import 'package:job_portal_app/features/job_seeker/presentation/shell/job_seeker_shell.dart';
import 'package:job_portal_app/models/user_model.dart';
import 'package:provider/provider.dart';


class RoleBasedRouter extends StatelessWidget {
  const RoleBasedRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    switch (auth.user!.role) {
      case UserRole.JOB_SEEKER:
        return const JobSeekerShell();
      case UserRole.EMPLOYER:
        return const EmployerShell();
      case UserRole.ADMIN:
        return const AdminShell();
      case null:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
