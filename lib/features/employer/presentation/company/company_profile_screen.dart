import 'package:flutter/material.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:provider/provider.dart';

class CompanyProfileScreen extends StatelessWidget {
  const CompanyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Profile'),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.editCompanyProfile);
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.settings);
                },
                icon: const Icon(Icons.settings_outlined),
              ),
              IconButton(
                tooltip: 'Logout',
                onPressed: () async {
                  // Confirm logout
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await auth.logout();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      RouteNames.login,
                      (route) => false, // Clear navigation stack
                    );
                  }
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
        ],
      ),
      body: Text("company profile"),
    );
  }
}
