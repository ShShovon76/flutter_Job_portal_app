import 'package:flutter/material.dart';


class ApplicantsListScreen extends StatefulWidget {
  final String? jobId;

  const ApplicantsListScreen({super.key, this.jobId});

  @override
  State<ApplicantsListScreen> createState() => _ApplicantsListScreenState();
}

class _ApplicantsListScreenState extends State<ApplicantsListScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text('All Applicants'),
      ),
      body: const Text(
        "applicant list"
      )
    );
  }

}
