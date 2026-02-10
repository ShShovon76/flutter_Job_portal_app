import 'package:flutter/material.dart';


class InterviewScheduleScreen extends StatelessWidget {
  const InterviewScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Schedule'),
        actions: [
          IconButton(
            onPressed: () {
              // Add to calendar
            },
            icon: const Icon(Icons.calendar_today),
          ),
        ],
      ),
      body:  const Center(
        child: Text('Interview Schedule Screen - Coming Soon'),
      ),
    );
  }
}