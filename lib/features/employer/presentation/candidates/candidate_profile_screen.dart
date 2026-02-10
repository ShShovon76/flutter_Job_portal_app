import 'package:flutter/material.dart';

class CandidateProfileScreen extends StatelessWidget {
  const CandidateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidate Profile'),
        actions: [
          IconButton(
            onPressed: () {
              // Share candidate profile
            },
            icon: const Icon(Icons.share),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'download',
                child: Text('Download Resume'),
              ),
              const PopupMenuItem(value: 'notes', child: Text('Add Notes')),
              const PopupMenuItem(
                value: 'contact',
                child: Text('Contact Candidate'),
              ),
            ],
            onSelected: (value) {
              // Handle menu selection
            },
          ),
        ],
      ),
      body: Text("candidate profile")
    );
  }

}
