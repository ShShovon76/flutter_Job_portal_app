import 'package:flutter/material.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/models/user_model.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:provider/provider.dart';

// login_screen.dart (Updated)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Listen for authentication changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth.isAuthenticated) {
        _redirectBasedOnRole(auth.user!.role!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Login'), automaticallyImplyLeading: false),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordCtrl,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: auth.isLoading
                  ? null
                  : () async {
                      await auth.login(emailCtrl.text, passwordCtrl.text);
                      if (auth.isAuthenticated) {
                        _redirectBasedOnRole(auth.user!.role!);
                      }
                    },
              child: auth.isLoading
                  ? CircularProgressIndicator()
                  : Text('Login'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.register);
              },
              child: Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }

  void _redirectBasedOnRole(UserRole role) {
    switch (role) {
      case UserRole.JOB_SEEKER:
        Navigator.pushReplacementNamed(context, RouteNames.jobSeekerShell);
        break;
      case UserRole.EMPLOYER:
        Navigator.pushReplacementNamed(context, RouteNames.employerShell);
        break;
      case UserRole.ADMIN:
        Navigator.pushReplacementNamed(context, RouteNames.adminShell);
        break;
      }
  }
}
