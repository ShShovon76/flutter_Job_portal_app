import 'package:flutter/material.dart';
import 'package:job_portal_app/features/admin/presentation/admin_dashboard.dart';
import 'package:job_portal_app/features/admin/presentation/admin_screens.dart';
import 'package:job_portal_app/features/admin/presentation/analytics_screen.dart';
import 'package:job_portal_app/features/admin/presentation/categories_screen.dart';
import 'package:job_portal_app/features/admin/presentation/manage_employer_jobs_screen.dart';
import 'package:job_portal_app/features/admin/presentation/manage_employers_screen.dart';
import 'package:job_portal_app/features/admin/presentation/manage_users_screen.dart';
import 'package:job_portal_app/features/admin/presentation/push_notifications_screen.dart';
import 'package:job_portal_app/features/admin/shell/admin_shell.dart';
import 'package:job_portal_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:job_portal_app/features/auth/presentation/login_screen.dart';
import 'package:job_portal_app/features/auth/presentation/otp_verification_screen.dart';
import 'package:job_portal_app/features/auth/presentation/register_screen.dart';
import 'package:job_portal_app/features/auth/presentation/splash_screen.dart';
import 'package:job_portal_app/features/employer/presentation/candidates/applicants_list_screen.dart';
import 'package:job_portal_app/features/employer/presentation/company/company_profile_screen.dart';
import 'package:job_portal_app/features/employer/presentation/dashboard/employer_dashboard_screen.dart';
import 'package:job_portal_app/features/employer/presentation/jobs/job_details_screen.dart';
import 'package:job_portal_app/features/employer/presentation/jobs/job_list_screen.dart';
import 'package:job_portal_app/features/employer/presentation/jobs/manage_job_screen.dart';
import 'package:job_portal_app/features/employer/presentation/jobs/post_job_screen.dart';
import 'package:job_portal_app/features/employer/presentation/shell/employer_shell.dart';
import 'package:job_portal_app/features/job_seeker/presentation/home/job_feed_screen.dart';
import 'package:job_portal_app/features/job_seeker/presentation/job/saved_jobs_screen.dart';
import 'package:job_portal_app/features/job_seeker/presentation/profile/certification_screen.dart';
import 'package:job_portal_app/features/job_seeker/presentation/profile/edit_profile_screen.dart';
import 'package:job_portal_app/features/job_seeker/presentation/profile/education_screen.dart';
import 'package:job_portal_app/features/job_seeker/presentation/profile/experience_screen.dart';
import 'package:job_portal_app/features/job_seeker/presentation/profile/resume_upload_screen.dart';
import 'package:job_portal_app/features/job_seeker/presentation/shell/job_seeker_shell.dart';
import 'package:job_portal_app/features/job_seeker/presentation/tracking/applied_jobs_screen.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/inputs/error_screen.dart';
import 'package:job_portal_app/shared/widgets/inputs/no_internet_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteNames.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterJobSeekerScreen(),
        );
      // case RouteNames.roleSelection:
      //   return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case RouteNames.otpVerification:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            email: args['email'] ?? '',
            type: args['type'] ?? VerificationType.email,
          ),
        );

      case RouteNames.noInternet:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => NoInternetScreen(
            onRetry: args['onRetry'],
            allowManualRetry: args['allowManualRetry'] ?? true,
          ),
        );

      case RouteNames.error:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => ErrorScreen(
            title: args['title'],
            message: args['message'],
            buttonText: args['buttonText'],
            onRetry: args['onRetry'],
            onGoBack: args['onGoBack'],
            showBackButton: args['showBackButton'] ?? true,
            showRetryButton: args['showRetryButton'] ?? true,
            icon: args['icon'],
            iconColor: args['iconColor'],
          ),
        );

      // Job Seeker Routes
      case RouteNames.jobSeekerShell:
        return MaterialPageRoute(builder: (_) => const JobSeekerShell());
      case RouteNames.jobFeed:
        return MaterialPageRoute(builder: (_) => const JobFeedScreen());
      case RouteNames.savedJobs:
        return MaterialPageRoute(builder: (_) => const SavedJobsScreen());
      case RouteNames.editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditJobSeekerProfileScreen(),
        );
      case RouteNames.certifications:
        return MaterialPageRoute(builder: (_) => const CertificationsScreen());
      case RouteNames.education:
        return MaterialPageRoute(builder: (_) => const EducationScreen());
      case RouteNames.experience:
        return MaterialPageRoute(builder: (_) => const ExperienceScreen());
      case RouteNames.resumeUpload:
        return MaterialPageRoute(builder: (_) => const ResumeUploadScreen());
      case RouteNames.appliedJobs:
        return MaterialPageRoute(builder: (_) => const AppliedJobsScreen());
      case RouteNames.jobDetails:
        final jobId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => JobDetailsScreen(jobId: jobId),
        );

      // Add other job seeker routes here...

      // Employer Routes
      case RouteNames.employerShell:
        return MaterialPageRoute(builder: (_) => const EmployerShell());
      case RouteNames.employerDashboard:
        return MaterialPageRoute(
          builder: (_) => const EmployerDashboardScreen(),
        );
      case RouteNames.jobList:
        return MaterialPageRoute(builder: (_) => const JobListScreen());
      case RouteNames.manageJobs:
        return MaterialPageRoute(builder: (_) => const ManageJobsScreen());
      case RouteNames.applicantsList:
        final jobId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => ApplicantsListScreen(jobId: jobId),
        );
      case RouteNames.companyProfile:
        return MaterialPageRoute(builder: (_) => const CompanyProfileScreen());
      case RouteNames.postJob:
        return MaterialPageRoute(
          builder: (_) => const JobPostScreen(), // Create mode only
          settings: settings,
        );

      case RouteNames.editJob:
        final jobId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => JobPostScreen(jobId: jobId), // Edit mode
          settings: settings,
        );
      // Add other employer routes here...

      // Admin Routes
      case RouteNames.adminShell:
        return MaterialPageRoute(builder: (_) => const AdminShell());

      case RouteNames.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      case RouteNames.manageUsers:
        return MaterialPageRoute(builder: (_) => const ManageUsersScreen());

      case RouteNames.manageEmployers:
        return MaterialPageRoute(builder: (_) => const ManageEmployersScreen());

      case RouteNames.manageEmployerJobs:
        return MaterialPageRoute(
          builder: (_) => const ManageEmployerJobsScreen(),
        );

      case RouteNames.approveJobs:
        return MaterialPageRoute(builder: (_) => const ApproveJobsScreen());

      case RouteNames.categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());

      case RouteNames.adminSkills:
        return MaterialPageRoute(builder: (_) => const AdminSkillsScreen());

      case RouteNames.analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());

      case RouteNames.pushNotifications:
        return MaterialPageRoute(
          builder: (_) => const PushNotificationsScreen(),
        );
      // Add other admin routes here...

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
