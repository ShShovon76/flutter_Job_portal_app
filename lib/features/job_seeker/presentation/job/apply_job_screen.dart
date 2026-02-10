import 'package:flutter/material.dart';

class ApplyJobScreen extends StatefulWidget {
  final int jobId;
  final int currentUserId;

  const ApplyJobScreen({
    super.key,
    required this.jobId,
    required this.currentUserId,
  });

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {
  
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Job')),
      body: const Center(child: Text('Apply Job Screen - Coming Soon')),
    );
  }
}
