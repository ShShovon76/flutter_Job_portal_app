// import 'package:job_app/models/job_model.dart';
// import 'package:job_app/models/application_model.dart';
// import 'package:job_app/models/user_model.dart';

// class DemoDataService {
//   static List<Job> get demoJobs => [
//         Job(
//           id: 1,
//           title: 'Senior Flutter Developer',
//           description:
//               'We are looking for an experienced Flutter Developer to join our mobile team. You will be responsible for building and maintaining our flagship mobile applications.',
//           employer: SimpleUser(id: 101, fullName: 'John Doe'),
//           company: SimpleCompany(
//             id: 201,
//             name: 'TechCorp Inc.',
//             logoUrl: 'assets/logos/google.png',
//           ),
//           category: SimpleCategory(id: 301, name: 'Tech'),
//           jobType: JobType.FULL_TIME,
//           experienceLevel: ExperienceLevel.SENIOR,
//           minSalary: 100000,
//           maxSalary: 130000,
//           salaryType: SalaryType.YEARLY,
//           location: 'San Francisco, CA',
//           remoteAllowed: true,
//           skills: ['Flutter', 'Dart', 'Mobile', 'Firebase', 'Provider'],
//           postedAt: DateTime.now().subtract(const Duration(days: 2)),
//           deadline: DateTime.now().add(const Duration(days: 30)),
//           status: JobStatus.ACTIVE,
//           viewsCount: 120,
//           applicantsCount: 10,
//         ),
//         Job(
//           id: 2,
//           title: 'UI/UX Designer',
//           description:
//               'Join our design team to create amazing user experiences for our clients. You will work on web and mobile applications.',
//           employer: SimpleUser(id: 102, fullName: 'Jane Smith'),
//           company: SimpleCompany(
//             id: 202,
//             name: 'Creative Agency',
//             logoUrl: 'assets/logos/apple.png',
//           ),
//           category: SimpleCategory(id: 302, name: 'Design'),
//           jobType: JobType.FULL_TIME,
//           experienceLevel: ExperienceLevel.MID,
//           minSalary: 80000,
//           maxSalary: 100000,
//           salaryType: SalaryType.YEARLY,
//           location: 'New York, NY',
//           remoteAllowed: false,
//           skills: ['Figma', 'Adobe XD', 'Prototyping', 'User Research', 'Wireframing'],
//           postedAt: DateTime.now().subtract(const Duration(days: 5)),
//           deadline: DateTime.now().add(const Duration(days: 25)),
//           status: JobStatus.ACTIVE,
//           viewsCount: 95,
//           applicantsCount: 7,
//         ),
//         Job(
//           id: 3,
//           title: 'Digital Marketing Manager',
//           description:
//               'Lead our digital marketing efforts and drive user acquisition through various channels.',
//           employer: SimpleUser(id: 103, fullName: 'Michael Johnson'),
//           company: SimpleCompany(
//             id: 203,
//             name: 'Growth Hackers',
//             logoUrl: 'assets/logos/microsoft.png',
//           ),
//           category: SimpleCategory(id: 303, name: 'Marketing'),
//           jobType: JobType.FULL_TIME,
//           experienceLevel: ExperienceLevel.MID,
//           minSalary: 75000,
//           maxSalary: 90000,
//           salaryType: SalaryType.YEARLY,
//           location: 'Remote',
//           remoteAllowed: true,
//           skills: ['SEO', 'SEM', 'Social Media', 'Analytics', 'Content Marketing'],
//           postedAt: DateTime.now().subtract(const Duration(days: 1)),
//           deadline: DateTime.now().add(const Duration(days: 28)),
//           status: JobStatus.ACTIVE,
//           viewsCount: 80,
//           applicantsCount: 12,
//         ),
//         Job(
//           id: 4,
//           title: 'Backend Developer',
//           description:
//               'Build scalable backend systems and APIs for our cloud platform.',
//           employer: SimpleUser(id: 104, fullName: 'Emily Davis'),
//           company: SimpleCompany(
//             id: 204,
//             name: 'Cloud Systems',
//             logoUrl: 'assets/logos/amazon.png',
//           ),
//           category: SimpleCategory(id: 301, name: 'Tech'),
//           jobType: JobType.FULL_TIME,
//           experienceLevel: ExperienceLevel.SENIOR,
//           minSalary: 100000,
//           maxSalary: 120000,
//           salaryType: SalaryType.YEARLY,
//           location: 'Austin, TX',
//           remoteAllowed: true,
//           skills: ['Node.js', 'Python', 'AWS', 'MongoDB', 'Docker'],
//           postedAt: DateTime.now().subtract(const Duration(days: 3)),
//           deadline: DateTime.now().add(const Duration(days: 30)),
//           status: JobStatus.ACTIVE,
//           viewsCount: 105,
//           applicantsCount: 8,
//         ),
//         Job(
//           id: 5,
//           title: 'Product Manager',
//           description:
//               'Lead product development from conception to launch, working with cross-functional teams.',
//           employer: SimpleUser(id: 105, fullName: 'Robert Wilson'),
//           company: SimpleCompany(
//             id: 205,
//             name: 'Innovation Labs',
//             logoUrl: 'assets/logos/facebook.png',
//           ),
//           category: SimpleCategory(id: 304, name: 'Management'),
//           jobType: JobType.FULL_TIME,
//           experienceLevel: ExperienceLevel.SENIOR,
//           minSalary: 120000,
//           maxSalary: 140000,
//           salaryType: SalaryType.YEARLY,
//           location: 'Boston, MA',
//           remoteAllowed: false,
//           skills: ['Product Strategy', 'Roadmapping', 'Agile', 'User Research', 'Analytics'],
//           postedAt: DateTime.now().subtract(const Duration(days: 7)),
//           deadline: DateTime.now().add(const Duration(days: 35)),
//           status: JobStatus.ACTIVE,
//           viewsCount: 150,
//           applicantsCount: 15,
//         ),
//       ];


//   // Demo Applications
//   static List<JobApplication> get demoApplications => [
//     Application(
//       id: '1',
//       jobId: '1',
//       jobTitle: 'Senior Flutter Developer',
//       company: 'TechCorp Inc.',
//       appliedDate: DateTime.now().subtract(const Duration(days: 5)),
//       status: 'interview',
//       interviewDate: DateTime.now().add(const Duration(days: 2)),
//       notes: 'Technical interview scheduled',
//     ),
//     ApplicationModel(
//       id: '2',
//       jobId: '2',
//       jobTitle: 'UI/UX Designer',
//       company: 'Creative Agency',
//       appliedDate: DateTime.now().subtract(const Duration(days: 10)),
//       status: 'shortlisted',
//       notes: 'Portfolio review completed',
//     ),
//     ApplicationModel(
//       id: '3',
//       jobId: '3',
//       jobTitle: 'Digital Marketing Manager',
//       company: 'Growth Hackers',
//       appliedDate: DateTime.now().subtract(const Duration(days: 3)),
//       status: 'review',
//       notes: 'Application under review',
//     ),
//     ApplicationModel(
//       id: '4',
//       jobId: '4',
//       jobTitle: 'Backend Developer',
//       company: 'Cloud Systems',
//       appliedDate: DateTime.now().subtract(const Duration(days: 15)),
//       status: 'rejected',
//       notes: 'Position filled internally',
//     ),
//     ApplicationModel(
//       id: '5',
//       jobId: '5',
//       jobTitle: 'Product Manager',
//       company: 'Innovation Labs',
//       appliedDate: DateTime.now().subtract(const Duration(days: 20)),
//       status: 'hired',
//       notes: 'Offer accepted, starting next month',
//     ),
//   ];

//   // Demo User Profile
//   static User get demoUser => User(
//     id: '1',
//     email: 'john.doe@example.com',
//     fullName: 'John Doe',
//     role: 'job_seeker',
//     profileImage: null,
//     isEmailVerified: true,
//     createdAt: DateTime(2024, 1, 1),
//   );

//   // Demo Skills
//   static List<String> get demoSkills => [
//     'Flutter',
//     'Dart',
//     'Firebase',
//     'REST APIs',
//     'Git',
//     'Mobile Development',
//     'UI/UX Design',
//     'Agile Methodologies',
//     'Problem Solving',
//     'Team Collaboration',
//   ];

//   // Demo Education
//   static List<Education> get demoEducation => [
//     Education(
//       id: '1',
//       institution: 'Stanford University',
//       degree: 'Master of Computer Science',
//       field: 'Computer Science',
//       startDate: DateTime(2018, 9),
//       endDate: DateTime(2020, 6),
//       gpa: '3.8',
//       description: 'Specialized in Mobile Development and AI',
//     ),
//     Education(
//       id: '2',
//       institution: 'MIT',
//       degree: 'Bachelor of Science',
//       field: 'Software Engineering',
//       startDate: DateTime(2014, 9),
//       endDate: DateTime(2018, 6),
//       gpa: '3.9',
//       description: 'Graduated with Honors',
//     ),
//   ];

//   // Demo Experience
//   static List<Experience> get demoExperience => [
//     Experience(
//       id: '1',
//       company: 'TechCorp Inc.',
//       position: 'Senior Mobile Developer',
//       startDate: DateTime(2021, 3),
//       endDate: null,
//       currentlyWorking: true,
//       description: 'Led mobile team, developed Flutter applications with 100k+ users',
//     ),
//     Experience(
//       id: '2',
//       company: 'StartupX',
//       position: 'Flutter Developer',
//       startDate: DateTime(2020, 7),
//       endDate: DateTime(2021, 2),
//       currentlyWorking: false,
//       description: 'Built mobile apps from scratch, worked on 3 successful projects',
//     ),
//   ];
// }

// // Education Model
// class Education {
//   final String id;
//   final String institution;
//   final String degree;
//   final String field;
//   final DateTime startDate;
//   final DateTime? endDate;
//   final String? gpa;
//   final String? description;

//   Education({
//     required this.id,
//     required this.institution,
//     required this.degree,
//     required this.field,
//     required this.startDate,
//     this.endDate,
//     this.gpa,
//     this.description,
//   });
// }

// // Experience Model
// class Experience {
//   final String id;
//   final String company;
//   final String position;
//   final DateTime startDate;
//   final DateTime? endDate;
//   final bool currentlyWorking;
//   final String description;

//   Experience({
//     required this.id,
//     required this.company,
//     required this.position,
//     required this.startDate,
//     this.endDate,
//     required this.currentlyWorking,
//     required this.description,
//   });
// }