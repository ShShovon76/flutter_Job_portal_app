import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/api/analytics_api.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/features/job_seeker/provider/job_provider.dart';
import 'package:job_portal_app/models/analytics_models.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:provider/provider.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final _scrollController = ScrollController();

  // Filter state
  String selectedFilter = 'all';
  final Map<String, String> filters = {
    'all': 'All Jobs',
    'active': 'Active',
    'draft': 'Draft',
    'closed': 'Closed',
  };

  // Stats state
  EmployerDashboardResponse? _dashboardStats;

  

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final employerId = authProvider.user?.id;

    if (employerId == null) return;

    // Load both dashboard stats (local) and jobs (provider)
    await Future.wait([
      _loadJobs(refresh: true),
      _loadDashboardStats(employerId),
    ]);
  }

  Future<void> _loadDashboardStats(int employerId) async {
    try {
      final stats = await AnalyticsApi.getEmployerDashboard(employerId);
      if (mounted) setState(() => _dashboardStats = stats);
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
    }
  }

  Future<void> _loadJobs({bool refresh = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    final employerId = authProvider.user?.id;
    if (employerId == null) return;

    JobStatus? status;
    if (selectedFilter == 'active') status = JobStatus.ACTIVE;
    if (selectedFilter == 'draft') status = JobStatus.DRAFT;
    if (selectedFilter == 'closed') status = JobStatus.CLOSED;

    await jobProvider.loadJobsByEmployer(
      employerId: employerId,
      status: status,
      refresh: refresh,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadJobs();
    }
  }

  void _onFilterChanged(String filter) {
    setState(() => selectedFilter = filter);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobs(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final jobs = jobProvider.jobs;
    final isLoading = jobProvider.loading;
    final error = jobProvider.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Jobs',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, RouteNames.postJob),
            icon: const Icon(Icons.add),
            tooltip: 'Post a job',
          ),
        ],
      ),
      body: isLoading && jobs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : error != null && jobs.isEmpty
          ? _buildErrorState(error)
          : Column(
              children: [
                // Stats Summary remains exactly as you designed it
                Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
                  color: AppColors.background,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                        'Active',
                        _dashboardStats?.activeJobs.toString() ?? '0',
                      ),
                      _buildStat(
                        'Applications',
                        _dashboardStats?.totalApplications.toString() ?? '0',
                      ),
                      _buildStat(
                        'Profile Views',
                        _dashboardStats?.profileViews.toString() ?? '0',
                      ),
                      _buildStat(
                        'Jobs',
                        _dashboardStats?.totalJobs.toString() ?? '0',
                      ),
                    ],
                  ),
                ),

                // Filter Tabs
                Container(
                  height: 60,
                  color: Colors.white,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    children: filters.entries.map((entry) {
                      final isSelected = selectedFilter == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSizes.sm),
                        child: ChoiceChip(
                          label: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.grey.shade100,
                          onSelected: (selected) {
                            if (selected) _onFilterChanged(entry.key);
                          },
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md,
                            vertical: AppSizes.sm,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const Divider(height: 1, color: AppColors.border),

                // Job List
                Expanded(
                  child: jobs.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () => _loadJobs(refresh: true),
                          color: AppColors.primary,
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(AppSizes.md),
                            // Use provider's hasMore
                            itemCount:
                                jobs.length + (jobProvider.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= jobs.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              // Your exact _JobCard remains the same
                              return _JobCard(
                                job: jobs[index],
                                onEdit: () => Navigator.pushNamed(
                                  context,
                                  RouteNames.editJob,
                                  arguments: jobs[index].id,
                                ),
                                onViewApplicants: () => Navigator.pushNamed(
                                  context,
                                  RouteNames.applicantsList,
                                  arguments: jobs[index].id,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildErrorState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSizes.lg),
            Text(
              error ?? 'Something went wrong',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 80,
              color: AppColors.textDisabled.withOpacity(0.5),
            ),
            const SizedBox(height: AppSizes.xl),
            Text(
              selectedFilter == 'all'
                  ? 'No Jobs Posted Yet'
                  : 'No ${filters[selectedFilter]!.toLowerCase()} jobs',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'Start posting jobs to find the right candidates',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.xl),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, RouteNames.postJob),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xl,
                  vertical: AppSizes.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: const Text(
                'Post Your First Job',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onEdit;
  final VoidCallback onViewApplicants;

  const _JobCard({
    required this.job,
    required this.onEdit,
    required this.onViewApplicants,
  });

  String _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.ACTIVE:
        return AppColors.success.value.toString();
      case JobStatus.DRAFT:
        return Colors.orange.value.toString();
      case JobStatus.CLOSED:
        return Colors.grey.value.toString();
      default:
        return AppColors.textSecondary.value.toString();
    }
  }

  String _getStatusLabel(JobStatus status) {
    switch (status) {
      case JobStatus.ACTIVE:
        return 'Active';
      case JobStatus.DRAFT:
        return 'Draft';
      case JobStatus.CLOSED:
        return 'Closed';
      default:
        return status.name;
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Company Logo and Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Logo
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    border: Border.all(color: AppColors.border),
                  ),
                  child:
                      job.company.logoUrl != null &&
                          job.company.logoUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSm,
                          ),
                          child: Image.network(
                            job.company.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildDefaultLogo(),
                          ),
                        )
                      : _buildDefaultLogo(),
                ),
                const SizedBox(width: AppSizes.md),

                // Title and Company Info
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteNames.jobDetails,
                        arguments: job.id,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.company.name,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(_getStatusColor(job.status)),
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusXs),
                  ),
                  child: Text(
                    _getStatusLabel(job.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(int.parse(_getStatusColor(job.status))),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.md),

            // Location and Job Type
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.work_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatJobType(job.jobType.name),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (job.remoteAllowed) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusXs),
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

            const SizedBox(height: AppSizes.md),

            // Stats Row
            Row(
              children: [
                _buildStatIcon(
                  Icons.people_outline,
                  '${job.applicantsCount ?? 0} applicants',
                ),
                const SizedBox(width: AppSizes.sm),
                _buildStatIcon(
                  Icons.visibility_outlined,
                  '${job.viewsCount ?? 0} views',
                ),
                const SizedBox(width: AppSizes.sm),
                _buildStatIcon(
                  Icons.access_time_outlined,
                  'Posted ${_formatPostedDate(job.postedAt)}',
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewApplicants,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                    ),
                    child: const Text(
                      'View Applicants',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Icon(
        Icons.business,
        size: 24,
        color: AppColors.primary.withOpacity(0.5),
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
