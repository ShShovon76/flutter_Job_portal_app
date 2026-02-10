import 'package:flutter/material.dart';
import 'package:job_portal_app/routes/route_names.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.settings);
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: const Center(child: Text('Profile Screen - Coming Soon')),
    );
  }
}