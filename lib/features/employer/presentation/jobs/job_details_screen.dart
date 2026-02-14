// import 'package:flutter/material.dart';
// import 'package:job_portal_app/core/api/analytics_api.dart';
// import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
// import 'package:job_portal_app/features/job_seeker/provider/job_provider.dart';
// import 'package:job_portal_app/models/analytics_models.dart';
// import 'package:job_portal_app/models/job_model.dart';
// import 'package:provider/provider.dart';

// class JobDetailsScreen extends StatefulWidget {
//   final int jobId;

//   const JobDetailsScreen({super.key, required this.jobId});

//   @override
//   State<JobDetailsScreen> createState() => _JobDetailsScreenState();
// }

// class _JobDetailsScreenState extends State<JobDetailsScreen> {
//   JobViewsResponse? views;
//   bool loadingAnalytics = false;

//   @override
//   void initState() {
//     super.initState();

//     // ✅ build শেষ হওয়ার পরে call হবে
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _load();
//     });
//   }

//   Future<void> _load() async {
//     final jobProvider = context.read<JobProvider>();
//     final auth = context.read<AuthProvider>();

//     // load job
//     await jobProvider.loadJobById(widget.jobId);

//     // record view
//     await jobProvider.recordView(
//       widget.jobId,
//       JobViewRequest(viewerId: auth.user?.id, userAgent: 'flutter'),
//     );

//     // load analytics
//     loadingAnalytics = true;
//     setState(() {});

//     views = await AnalyticsApi.getJobViews(jobId: widget.jobId);

//     loadingAnalytics = false;
//     if (mounted) setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Job Details')),
//       body: Consumer<JobProvider>(
//         builder: (_, provider, __) {
//           final job = provider.selectedJob;

//           if (job == null) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   job.title,
//                   style: Theme.of(context).textTheme.headlineSmall,
//                 ),
//                 const SizedBox(height: 6),
//                 Text(job.company.name),
//                 const Divider(height: 32),

//                 _info('Location', job.location),
//                 _info('Job Type', job.jobType.name),
//                 _info('Experience', job.experienceLevel.name),
//                 _info(
//                   'Salary',
//                   '${job.minSalary ?? '-'} - ${job.maxSalary ?? '-'}',
//                 ),

//                 const Divider(height: 32),
//                 Text(job.description),

//                 const SizedBox(height: 24),

//                 if (loadingAnalytics)
//                   const Center(child: CircularProgressIndicator())
//                 else if (views != null)
//                   _AnalyticsCard(views!),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _info(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Text('$label: $value'),
//     );
//   }
// }

// class _AnalyticsCard extends StatelessWidget {
//   final JobViewsResponse views;

//   const _AnalyticsCard(this.views);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Analytics', style: Theme.of(context).textTheme.titleMedium),
//             const SizedBox(height: 12),
//             _row('Total Views', views.totalViews.toString()),
//             _row('Unique Views', views.uniqueViews.toString()),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _row(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }

// features/job_seeker/presentation/job/job_details_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/api/aplication_api.dart';
import 'package:job_portal_app/core/api/company_api.dart';
import 'package:job_portal_app/core/api/job_api.dart';
import 'package:job_portal_app/core/api/resume_api.dart';
import 'package:job_portal_app/core/api/saved_job.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/models/application_model.dart';
import 'package:job_portal_app/models/company_model.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';
import 'package:job_portal_app/models/user_model.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

class JobDetailsScreen extends StatefulWidget {
  final int jobId;

  const JobDetailsScreen({super.key, required this.jobId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  // ===================== STATE =====================
  Job? _job;
  Company? _company;
  List<Job> _similarJobs = [];
  List<Resume> _resumes = [];
  bool _isLoading = true;
  bool _hasApplied = false;
  bool _checkingApplied = false;
  bool _isSaved = false;
  bool _checkingSaved = false;
  bool _showApplicationModal = false;

  // Application form state
  String _applyMode = 'existing'; // 'existing' or 'upload'
  int? _selectedResumeId;
  final TextEditingController _coverLetterController = TextEditingController();
  File? _newResumeFile;
  final TextEditingController _newResumeTitleController =
      TextEditingController();

  late AuthProvider _authProvider;

  // User state
  User? _currentUser;
  bool _authListenerAdded = false;

  @override
  void initState() {
    super.initState();
    _loadJobDetails(widget.jobId);
    _recordJobView(widget.jobId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_authListenerAdded) {
      _authProvider = Provider.of<AuthProvider>(context, listen: false);
      _currentUser = _authProvider.user;
      _authProvider.addListener(_onAuthChange);
      _authListenerAdded = true;
    }
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _newResumeTitleController.dispose();
    _authProvider.removeListener(_onAuthChange);
    super.dispose();
  }

  void _onAuthChange() {
    if (!mounted) return;

    setState(() {
      _currentUser = _authProvider.user;
    });

    if (_currentUser?.id != null && _job?.id != null) {
      _checkIfApplied(_job!.id);
      _checkIfSaved(_job!.id);
    }

    if (_currentUser?.id != null) {
      _loadResumes();
    }
  }

  // ===================== API CALLS =====================

  Future<void> _loadJobDetails(int jobId) async {
    setState(() => _isLoading = true);

    try {
      final job = await JobApi.getJobById(jobId);

      setState(() {
        _job = job;
        _isLoading = false;
      });

      if (_currentUser?.id != null) {
        _checkIfApplied(job.id);
        _checkIfSaved(job.id);
      }

      if (job.company.id != null) {
        _loadCompanyDetails(job.company.id);
      }

      _loadSimilarJobs(job);
    } catch (e) {
      debugPrint('Error loading job details: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load job details: $e')),
        );
      }
    }
  }

  Future<void> _loadCompanyDetails(int companyId) async {
    try {
      final company = await CompanyApi().getCompanyById(companyId);
      setState(() => _company = company);
    } catch (e) {
      debugPrint('Error loading company details: $e');
    }
  }

  Future<void> _loadSimilarJobs(Job job) async {
    try {
      final filter = JobSearchFilter(
        categoryId: job.category.id,
        jobType: job.jobType,
        page: 0,
        size: 4,
      );

      final response = await JobApi.searchJobs(filter: filter);

      setState(() {
        _similarJobs = response.items
            .where((j) => j.id != job.id)
            .take(3)
            .toList();
      });
    } catch (e) {
      debugPrint('Error loading similar jobs: $e');
    }
  }

  Future<void> _recordJobView(int jobId) async {
    try {
      final request = JobViewRequest(
        viewerId: _currentUser?.id,
        userAgent: 'Flutter App',
      );
      await JobApi.recordJobView(jobId: jobId, request: request);
    } catch (e) {
      // Silently fail - view tracking shouldn't break the UI
      debugPrint('Error recording job view: $e');
    }
  }

  Future<void> _checkIfApplied(int jobId) async {
    if (_currentUser == null) return;

    setState(() => _checkingApplied = true);

    try {
      final applied = await JobApplicationApi.hasApplied(jobId);
      setState(() {
        _hasApplied = applied;
        _checkingApplied = false;
      });
    } catch (e) {
      debugPrint('Error checking application status: $e');
      setState(() {
        _hasApplied = false;
        _checkingApplied = false;
      });
    }
  }

  Future<void> _checkIfSaved(int jobId) async {
    if (_currentUser?.id == null) return;

    setState(() => _checkingSaved = true);

    try {
      final isSaved = await SavedJobApi.isJobSaved(jobId);
      setState(() {
        _isSaved = isSaved;
        _checkingSaved = false;
      });
    } catch (e) {
      debugPrint('Error checking saved status: $e');
      setState(() {
        _isSaved = false;
        _checkingSaved = false;
      });
    }
  }

  Future<void> _loadResumes() async {
    if (_currentUser == null) return;

    try {
      final resumes = await ResumeApi.getMyResumes();
      setState(() {
        _resumes = resumes;

        // Auto-select primary resume - FIXED: no .empty() method
        if (resumes.isNotEmpty) {
          final primary = resumes.firstWhere(
            (r) => r.primaryResume,
            orElse: () => resumes.first,
          );
          _selectedResumeId = primary.id;
        }
      });
    } catch (e) {
      debugPrint('Error loading resumes: $e');
    }
  }

  // ===================== SAVE/UNSAVE JOB =====================

  Future<void> _toggleSaveJob() async {
    if (_currentUser == null) {
      _showLoginPrompt();
      return;
    }

    if (_job == null) return;

    try {
      if (_isSaved) {
        // Unsave job
        await SavedJobApi.unsaveJobByJobId(_job!.id);
        setState(() => _isSaved = false);
        _showSnackBar('Job removed from saved jobs');
      } else {
        // Save job
        await SavedJobApi.saveJob(_job!.id);
        setState(() => _isSaved = true);
        _showSnackBar('Job saved successfully!');
      }
    } catch (e) {
      debugPrint('Error toggling saved job: $e');

      if (e.toString().contains('409')) {
        setState(() => _isSaved = true);
        _showSnackBar('Job already saved');
      } else {
        _showSnackBar('Failed to save job', isError: true);
      }
    }
  }

  // ===================== JOB APPLICATION =====================

  void _applyForJob() {
    if (_currentUser == null) {
      _showLoginPrompt();
      return;
    }

    // Check if user is job seeker
    if (_currentUser?.role != UserRole.JOB_SEEKER) {
      _showJobSeekerLoginDialog();
      return;
    }

    setState(() {
      _showApplicationModal = true;
      _applyMode = 'existing';
      _newResumeFile = null;
      _newResumeTitleController.clear();
    });
    _openApplicationModal();
  }

  Future<void> _submitApplication() async {
    if (_job == null) return;

    if (_currentUser == null) {
      _showLoginPrompt();
      return;
    }

    // CASE 1: Upload new resume
    if (_applyMode == 'upload') {
      if (_newResumeFile == null) {
        _showSnackBar('Please upload a resume', isError: true);
        return;
      }

      try {
        final resume = await ResumeApi.uploadResume(
          file: _newResumeFile!,
          title: _newResumeTitleController.text.isEmpty
              ? _newResumeFile!.path.split('/').last
              : _newResumeTitleController.text,
        );

        // Apply with newly created resume
        await _applyWithResume(resume.id);
      } catch (e) {
        debugPrint('Resume upload failed: $e');
        _showSnackBar('Resume upload failed', isError: true);
      }
      return;
    }

    // CASE 2: Existing resume
    if (_selectedResumeId == null) {
      _showSnackBar('Please select a resume', isError: true);
      return;
    }

    await _applyWithResume(_selectedResumeId!);
  }

  Future<void> _applyWithResume(int resumeId) async {
    try {
      await JobApplicationApi.apply(
        jobId: _job!.id,
        resumeId: resumeId,
        coverLetter: _coverLetterController.text.isNotEmpty
            ? _coverLetterController.text
            : null,
      );

      _showSnackBar('Application submitted successfully!');

      setState(() {
        _showApplicationModal = false;
        _hasApplied = true;
        _selectedResumeId = null;
        _coverLetterController.clear();
        _newResumeFile = null;
        _newResumeTitleController.clear();
      });
    } catch (e) {
      debugPrint('Error submitting application: $e');

      if (e.toString().contains('409')) {
        _showSnackBar('You have already applied for this job', isError: true);
        setState(() {
          _showApplicationModal = false;
          _hasApplied = true;
        });
      } else {
        _showSnackBar('Failed to submit application', isError: true);
      }
    }
  }

  Future<void> _pickResumeFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _newResumeFile = File(result.files.single.path!);

          if (_newResumeTitleController.text.isEmpty) {
            _newResumeTitleController.text = result.files.single.name;
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      _showSnackBar('Failed to pick file', isError: true);
    }
  }

  // ===================== SHARE JOB =====================

  Future<void> _shareJob() async {
    if (_job == null) return;

    final String shareText =
        '''
${_job!.title}
Company: ${_job!.company.name}
Location: ${_job!.location}
Type: ${_formatJobType(_job!.jobType.name)}

Check out this job opportunity!
    ''';

    try {
      await Share.share(shareText);
    } catch (e) {
      // Fallback to clipboard
      await Clipboard.setData(ClipboardData(text: shareText));
      _showSnackBar('Link copied to clipboard!');
    }
  }

  // ===================== UI HELPERS =====================

  String _formatSalary() {
    if (_job == null) return 'Not specified';

    if (_job!.minSalary == null && _job!.maxSalary == null) {
      return 'Not specified';
    } else if (_job!.minSalary != null && _job!.maxSalary != null) {
      return '\$${_formatNumber(_job!.minSalary!)} - \$${_formatNumber(_job!.maxSalary!)} ${_formatSalaryType(_job!.salaryType)}';
    } else if (_job!.minSalary != null) {
      return 'From \$${_formatNumber(_job!.minSalary!)} ${_formatSalaryType(_job!.salaryType)}';
    } else {
      return 'Up to \$${_formatNumber(_job!.maxSalary!)} ${_formatSalaryType(_job!.salaryType)}';
    }
  }

  String _formatNumber(double number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toStringAsFixed(0);
  }

  String _formatSalaryType(SalaryType type) {
    switch (type) {
      case SalaryType.HOURLY:
        return '/hr';
      case SalaryType.DAILY:
        return '/day';
      case SalaryType.WEEKLY:
        return '/week';
      case SalaryType.MONTHLY:
        return '/month';
      case SalaryType.YEARLY:
        return '/year';
      default:
        return '';
    }
  }

  String _formatJobType(String type) {
    return type.replaceAll('_', ' ').toUpperCase();
  }

  String _formatPostedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  IconData _getJobTypeIcon(JobType type) {
    switch (type) {
      case JobType.FULL_TIME:
        return Icons.work;
      case JobType.PART_TIME:
        return Icons.access_time;
      case JobType.CONTRACT:
        return Icons.description;
      case JobType.REMOTE:
        return Icons.laptop;
      case JobType.INTERNSHIP:
        return Icons.school;
      case JobType.FREELANCE:
        return Icons.person;
      default:
        return Icons.work_outline;
    }
  }

  String _getExperienceText(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.ENTRY:
        return 'Entry Level (0-2 years)';
      case ExperienceLevel.MID:
        return 'Mid Level (3-5 years)';
      case ExperienceLevel.SENIOR:
        return 'Senior Level (6+ years)';
      case ExperienceLevel.DIRECTOR:
        return 'Director';
      case ExperienceLevel.EXECUTIVE:
        return 'Executive';
      default:
        return level.name;
    }
  }

  bool _isJobSeeker() {
    return _currentUser?.role == UserRole.JOB_SEEKER;
  }

  bool _isEmployer() {
    return _currentUser?.role == UserRole.EMPLOYER;
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to perform this action.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, RouteNames.login);
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showJobSeekerLoginDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Job Seeker Account Required'),
        content: const Text(
          'You need a job seeker account to apply for jobs. '
          'Would you like to logout and login with a job seeker account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushNamed(
                context,
                RouteNames.login,
                arguments: {'role': 'JOB_SEEKER'},
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout & Login'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewSavedJobs() {
    Navigator.pushNamed(context, RouteNames.savedJobs);
  }

  // ===================== BUILD UI =====================

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        body: _job == null
            ? _buildErrorState()
            : CustomScrollView(
                slivers: [
                  // App Bar with Hero animation
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    stretch: true,
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const [
                        StretchMode.blurBackground,
                        StretchMode.zoomBackground,
                      ],
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Company Logo
                            Positioned(
                              bottom: 40,
                              left: 20,
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: _job!.company.logoUrl != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              _job!.company.logoUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _buildDefaultLogo(),
                                            ),
                                          )
                                        : _buildDefaultLogo(),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _job!.company.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          _formatJobType(_job!.jobType.name),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      // Save button
                      IconButton(
                        onPressed: _checkingSaved ? null : _toggleSaveJob,
                        icon: _checkingSaved
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: Colors.white,
                              ),
                      ),
                      // Share button
                      IconButton(
                        onPressed: _shareJob,
                        icon: const Icon(Icons.share, color: Colors.white),
                      ),
                    ],
                  ),

                  // Job Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Job Title
                          Text(
                            _job!.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Location
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _job!.location,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (_job!.remoteAllowed) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'REMOTE',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Stats Row
                          Row(
                            children: [
                              _buildInfoChip(
                                icon: Icons.work_outline,
                                label: _formatJobType(_job!.jobType.name),
                              ),
                              const SizedBox(width: 12),
                              _buildInfoChip(
                                icon: Icons.trending_up,
                                label: _getExperienceText(
                                  _job!.experienceLevel,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Salary
                          if (_job!.minSalary != null ||
                              _job!.maxSalary != null) ...[
                            const Text(
                              'Salary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatSalary(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Posted Date & Deadline
                          Row(
                            children: [
                              _buildDateInfo(
                                icon: Icons.access_time,
                                label: 'Posted',
                                date: _job!.postedAt,
                              ),
                              const SizedBox(width: 24),
                              _buildDateInfo(
                                icon: Icons.event,
                                label: 'Deadline',
                                date: _job!.deadline,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Description
                          const Text(
                            'Job Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _job!.description,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Skills
                          const Text(
                            'Required Skills',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _job!.skills.map((skill) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  skill,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),

                          // Company Info (if available)
                          if (_company != null) ...[
                            const Divider(),
                            const SizedBox(height: 16),
                            _buildCompanySection(),
                            const SizedBox(height: 16),
                            const Divider(),
                          ],

                          // Similar Jobs
                          if (_similarJobs.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildSimilarJobsSection(),
                          ],

                          const SizedBox(height: 100), // Space for FAB
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        floatingActionButton: _job != null && _job!.status == JobStatus.ACTIVE
            ? _buildApplyButton()
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo({
    required IconData icon,
    required String label,
    required DateTime date,
  }) {
    final isDeadline = label == 'Deadline';
    final isExpired = isDeadline && date.isBefore(DateTime.now());

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isExpired ? Colors.red : AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ${_formatPostedDate(date)}',
          style: TextStyle(
            fontSize: 13,
            color: isExpired ? Colors.red : AppColors.textSecondary,
            fontWeight: isExpired ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.business,
        size: 30,
        color: AppColors.primary.withOpacity(0.5),
      ),
    );
  }

  Widget _buildCompanySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About the Company',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: _company!.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _company!.logoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.business,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : const Icon(Icons.business, size: 40, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _company!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _company!.industry,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_company!.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          _company!.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${_company!.reviewCount ?? 0} reviews)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        if (_company!.about != null) ...[
          const SizedBox(height: 12),
          Text(
            _company!.about!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            // Navigate to company profile
          },
          icon: const Icon(Icons.visibility),
          label: const Text('View Company Profile'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarJobsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Similar Jobs',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._similarJobs.map((job) => _buildSimilarJobCard(job)).toList(),
      ],
    );
  }

  Widget _buildSimilarJobCard(Job job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: job.company.logoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    job.company.logoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.business),
                  ),
                )
              : const Icon(Icons.business),
        ),
        title: Text(
          job.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              job.company.name,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _getJobTypeIcon(job.jobType),
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatJobType(job.jobType.name),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.location_on,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => JobDetailsScreen(jobId: job.id)),
          );
        },
      ),
    );
  }

  Widget _buildApplyButton() {
    if (_hasApplied) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Already Applied',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    }

    if (_job!.deadline.isBefore(DateTime.now())) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'Deadline Passed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _checkingApplied ? null : _applyForJob,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _checkingApplied
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Apply Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Job Not Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'The job you\'re looking for doesn\'t exist or has been removed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== APPLICATION MODAL =====================

  void _openApplicationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Apply for Job',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mode selector
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _applyMode = 'existing'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _applyMode == 'existing'
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: _applyMode == 'existing'
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'Existing Resume',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _applyMode == 'existing'
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _applyMode = 'upload'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _applyMode == 'upload'
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: _applyMode == 'upload'
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'Upload New',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _applyMode == 'upload'
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Resume Selection
                    if (_applyMode == 'existing') ...[
                      const Text(
                        'Select Resume',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_resumes.isEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.description_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No resumes found',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Please upload a resume first',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // Navigate to resume management
                                },
                                icon: const Icon(Icons.upload),
                                label: const Text('Manage Resumes'),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        ..._resumes.map((resume) {
                          final isSelected = _selectedResumeId == resume.id;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedResumeId = resume.id),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.05)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.description,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          resume.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Uploaded: ${_formatPostedDate(DateTime.parse(resume.uploadedAt))}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Radio<int>(
                                    value: resume.id,
                                    groupValue: _selectedResumeId,
                                    onChanged: (value) {
                                      setState(() => _selectedResumeId = value);
                                    },
                                    activeColor: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            // Navigate to resume management
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add New Resume'),
                        ),
                      ],
                    ] else ...[
                      // Upload new resume
                      const Text(
                        'Upload Resume',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickResumeFile,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _newResumeFile != null
                                  ? AppColors.success
                                  : AppColors.border,
                              width: _newResumeFile != null ? 2 : 1,
                            ),
                          ),
                          child: _newResumeFile != null
                              ? Column(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _newResumeFile!.path.split('/').last,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${(_newResumeFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    const Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Tap to upload resume',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Supported: PDF, DOC, DOCX (Max 5MB)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newResumeTitleController,
                        decoration: const InputDecoration(
                          labelText: 'Resume Title (Optional)',
                          hintText: 'e.g. My Updated Resume',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Cover Letter
                    const Text(
                      'Cover Letter (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _coverLetterController,
                      maxLines: 5,
                      maxLength: 2000,
                      decoration: const InputDecoration(
                        hintText:
                            'Write a brief cover letter to introduce yourself...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Application',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
