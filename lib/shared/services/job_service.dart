import 'dart:async';
import 'package:job_portal_app/models/job_model.dart';

class DemoJobService {
  static Future<List<Job>> fetchJobs() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      Job(
        id: 1,
        title: 'Flutter Developer',
        description: 'Build and maintain mobile apps using Flutter.',
        location: 'Dhaka, Bangladesh',
        remoteAllowed: true,
        skills: ['Flutter', 'Dart', 'REST API'],

        jobType: JobType.FULL_TIME,
        experienceLevel: ExperienceLevel.MID,
        salaryType: SalaryType.MONTHLY,
        minSalary: 60000,
        maxSalary: 90000,

        employer:  SimpleUser(
          id: 10,
          fullName: 'HR Manager',
        ),

        company:  SimpleCompany(
          id: 101,
          name: 'TechSoft Ltd',
          logoUrl: null,
        ),

        category:  SimpleCategory(
          id: 5,
          name: 'Software Development',
        ),

        postedAt: DateTime.now(),
        deadline: DateTime(2026, 3, 1),
        status: JobStatus.ACTIVE,
        viewsCount: 120,
        applicantsCount: 18,
      ),
    ];
  }
}
