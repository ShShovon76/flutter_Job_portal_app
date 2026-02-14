import 'package:flutter/material.dart';

import 'package:job_portal_app/routes/route_names.dart';

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> selectedFilters = [];
  List<String> recentSearches = ['Flutter Developer', 'Remote', 'UI Designer'];

  final List<Map<String, dynamic>> filterOptions = [
    {'label': 'Remote', 'value': 'remote'},
    {'label': 'Full Time', 'value': 'full_time'},
    {'label': 'Part Time', 'value': 'part_time'},
    {'label': 'Contract', 'value': 'contract'},
    {'label': 'Entry Level', 'value': 'entry'},
    {'label': 'Senior Level', 'value': 'senior'},
    {'label': 'Tech', 'value': 'tech'},
    {'label': 'Design', 'value': 'design'},
    {'label': 'Marketing', 'value': 'marketing'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Jobs'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.filters);
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Text("job search"),
    );
  }
}
