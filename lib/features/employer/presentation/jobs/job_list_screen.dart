import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/routes/route_names.dart';


class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.postJob);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body:Text("job list")
    );
  }
}