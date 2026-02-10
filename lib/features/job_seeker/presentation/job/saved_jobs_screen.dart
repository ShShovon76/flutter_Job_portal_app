import 'package:flutter/material.dart';


class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
        
      ),
      body: const Center(child: Text('Saved Jobs Screen - Coming Soon')),
    );
  }
}