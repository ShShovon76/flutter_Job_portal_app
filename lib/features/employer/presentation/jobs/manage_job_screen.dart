// features/employer/presentation/jobs/manage_jobs_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/api/job_api.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';

enum _JobMenuAction { edit, viewApplicants, close, reopen, duplicate, delete }

class ManageJobsScreen extends StatefulWidget {
  const ManageJobsScreen({super.key});

  @override
  State<ManageJobsScreen> createState() => _ManageJobsScreenState();
}

class _ManageJobsScreenState extends State<ManageJobsScreen> {
  // ===================== CONTROLLERS =====================
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  // ===================== FILTERS =====================
  String _selectedStatusFilter = '';
  String _selectedJobTypeFilter = '';

  // Available filter options
  final List<String> _statusOptions = ['', 'ACTIVE', 'CLOSED', 'DRAFT'];
  final List<String> _jobTypeOptions = [
    '',
    'FULL_TIME',
    'PART_TIME',
    'CONTRACT',
    'REMOTE',
    'INTERNSHIP',
    'FREELANCE',
  ];

  // ===================== DATA STATE =====================
  List<Job> _jobs = [];
  Pagination<Job>? _pagination;
  bool _isLoading = true;
  bool _isFetchingMore = false;
  String? _error;

  // ===================== PAGINATION =====================
  int _currentPage = 0;
  final int _pageSize = 10;
  int _totalPages = 0;
  bool _hasMore = true;

  // ===================== STATS =====================
  Map<String, int> _stats = {'active': 0, 'closed': 0, 'draft': 0, 'total': 0};

  // ===================== UI STATE =====================
  int? _deletingJobId;
  int? _jobToDeleteId;
  final _deleteConfirmKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadJobs();
    _setupSearchListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ===================== AUTH CHECK =====================
  void _checkAuthAndLoadJobs() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        Navigator.pushReplacementNamed(context, RouteNames.login);
        return;
      }
      _loadJobs(refresh: true);
    });
  }

  // ===================== FILTER SETUP =====================
  void _setupSearchListener() {
    _searchController.addListener(() {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _currentPage = 0;
        _loadJobs(refresh: true);
      });
    });
  }

  // ===================== LOAD JOBS =====================
  Future<void> _loadJobs({bool refresh = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final employerId = authProvider.user?.id;

    if (employerId == null) return;

    if (refresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 0;
        _hasMore = true;
        _jobs.clear();
      });
    } else {
      if (!_hasMore || _isFetchingMore) return;
      setState(() => _isFetchingMore = true);
    }

    try {
      JobStatus? status;
      if (_selectedStatusFilter.isNotEmpty) {
        status = JobStatus.values.firstWhere(
          (e) => e.name == _selectedStatusFilter,
          orElse: () => JobStatus.ACTIVE,
        );
      }

      JobType? jobType;
      if (_selectedJobTypeFilter.isNotEmpty) {
        jobType = JobType.values.firstWhere(
          (e) => e.name == _selectedJobTypeFilter,
          orElse: () => JobType.FULL_TIME,
        );
      }

      final response = await JobApi.getJobsByEmployer(
        employerId: employerId,
        status: status,
        jobType: jobType,
        keyword: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
        page: _currentPage,
        size: _pageSize,
      );

      setState(() {
        if (refresh) {
          _jobs = response.items;
        } else {
          _jobs.addAll(response.items);
        }
        _pagination = response;
        _totalPages = response.totalPages;
        _hasMore = _currentPage + 1 < response.totalPages;
        _currentPage++;
        _calculateStats();
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  // ===================== CALCULATE STATS =====================
  void _calculateStats() {
    _stats = {
      'active': _jobs.where((j) => j.status == JobStatus.ACTIVE).length,
      'closed': _jobs.where((j) => j.status == JobStatus.CLOSED).length,
      'draft': _jobs.where((j) => j.status == JobStatus.DRAFT).length,
      'total': _jobs.length,
    };
  }

  // ===================== FILTER HANDLERS =====================
  void _onStatusFilterChanged(String? value) {
    setState(() {
      _selectedStatusFilter = value ?? '';
      _currentPage = 0;
    });
    _loadJobs(refresh: true);
  }

  void _onJobTypeFilterChanged(String? value) {
    setState(() {
      _selectedJobTypeFilter = value ?? '';
      _currentPage = 0;
    });
    _loadJobs(refresh: true);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatusFilter = '';
      _selectedJobTypeFilter = '';
      _currentPage = 0;
    });
    _loadJobs(refresh: true);
  }

  // ===================== JOB ACTIONS =====================
  void _editJob(int? jobId) {
    if (jobId != null) {
      Navigator.pushNamed(context, RouteNames.editJob, arguments: jobId)
          .then((_) => _loadJobs(refresh: true));
    }
  }

  void _viewApplicants(int? jobId) {
    if (jobId != null) {
      Navigator.pushNamed(context, RouteNames.applicantsList, arguments: jobId);
    }
  }

  Future<void> _closeJob(int? jobId) async {
    if (jobId == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final employerId = authProvider.user?.id;
    if (employerId == null) return;

    try {
      final request = JobUpdateRequest(status: JobStatus.CLOSED);
      final updatedJob = await JobApi.updateJob(
        jobId: jobId,
        request: request,
        employerId: employerId,
      );

      setState(() {
        final index = _jobs.indexWhere((j) => j.id == jobId);
        if (index != -1) {
          _jobs[index] = updatedJob;
        }
        _calculateStats();
      });

      _showSnackBar('Job closed successfully');
    } catch (e) {
      _showSnackBar('Failed to close job', isError: true);
    }
  }

  Future<void> _reopenJob(Job job) async {
    if (job.id == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final employerId = authProvider.user?.id;
    if (employerId == null) return;

    final confirmed = await _showConfirmDialog(
      'Reopen Job',
      'Are you sure you want to reopen this job?',
    );
    if (!confirmed) return;

    try {
      // Extend deadline by 30 days
      final newDeadline = DateTime.now().add(const Duration(days: 30));

      final request = JobUpdateRequest(
        status: JobStatus.ACTIVE,
        deadline: newDeadline,
      );

      final updatedJob = await JobApi.updateJob(
        jobId: job.id,
        request: request,
        employerId: employerId,
      );

      setState(() {
        final index = _jobs.indexWhere((j) => j.id == job.id);
        if (index != -1) {
          _jobs[index] = updatedJob;
        }
        _calculateStats();
      });

      _showSnackBar('Job reopened successfully');
    } catch (e) {
      _showSnackBar('Failed to reopen job', isError: true);
    }
  }

  Future<void> _duplicateJob(Job job) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final employerId = authProvider.user?.id;
    if (employerId == null) return;

    try {
      final createRequest = JobCreateRequest(
        companyId: job.company.id,
        categoryId: job.category.id,
        title: '${job.title} (Copy)',
        description: job.description,
        jobType: job.jobType,
        experienceLevel: job.experienceLevel,
        minSalary: job.minSalary,
        maxSalary: job.maxSalary,
        salaryType: job.salaryType,
        location: job.location,
        remoteAllowed: job.remoteAllowed,
        skills: List.from(job.skills),
        deadline: job.deadline,
      );

      final createdJob = await JobApi.createJob(
        request: createRequest,
        employerId: employerId,
      );

      setState(() {
        _jobs.insert(0, createdJob);
        _calculateStats();
      });

      _showSnackBar('Job duplicated successfully');
    } catch (e) {
      _showSnackBar('Failed to duplicate job', isError: true);
    }
  }

  void _confirmDelete(int? jobId) {
    if (jobId == null) return;
    setState(() => _jobToDeleteId = jobId);
    _showDeleteConfirmationDialog();
  }

  Future<void> _deleteJob() async {
    if (_jobToDeleteId == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final employerId = authProvider.user?.id;
    if (employerId == null) return;

    setState(() {
      _deletingJobId = _jobToDeleteId;
    });

    try {
      await JobApi.deleteJob(jobId: _jobToDeleteId!, employerId: employerId);

      setState(() {
        _jobs.removeWhere((j) => j.id == _jobToDeleteId);
        _jobToDeleteId = null;
        _deletingJobId = null;
        _calculateStats();
      });

      if (mounted) {
        Navigator.pop(context); // Close dialog
        _showSnackBar('Job deleted successfully');
      }
    } catch (e) {
      setState(() {
        _jobToDeleteId = null;
        _deletingJobId = null;
      });
      if (mounted) {
        Navigator.pop(context); // Close dialog
        _showSnackBar('Failed to delete job', isError: true);
      }
    }
  }

  void _cancelDelete() {
    setState(() => _jobToDeleteId = null);
    if (mounted) {
      Navigator.pop(context); // Close dialog
    }
  }

  PopupMenuItem<_JobMenuAction> _popupItem({
    required _JobMenuAction value,
    required IconData icon,
    required String label,
    bool isDestructive = false,
  }) {
    return PopupMenuItem<_JobMenuAction>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDestructive ? Colors.red : AppColors.textPrimary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDestructive ? Colors.red : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== UTILITY METHODS =====================
  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.ACTIVE:
        return Colors.green;
      case JobStatus.CLOSED:
        return Colors.red;
      case JobStatus.DRAFT:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatJobType(JobType type) {
    return type.name.replaceAll('_', ' ').toUpperCase();
  }

  String _formatSalary(Job job) {
    if (job.minSalary == null && job.maxSalary == null) {
      return 'Not specified';
    } else if (job.minSalary != null && job.maxSalary != null) {
      return '\$${_formatNumber(job.minSalary!)} - \$${_formatNumber(job.maxSalary!)} ${_getSalarySuffix(job.salaryType)}';
    } else if (job.minSalary != null) {
      return 'From \$${_formatNumber(job.minSalary!)} ${_getSalarySuffix(job.salaryType)}';
    } else {
      return 'Up to \$${_formatNumber(job.maxSalary!)} ${_getSalarySuffix(job.salaryType)}';
    }
  }

  String _formatNumber(double number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toStringAsFixed(0);
  }

  String _getSalarySuffix(SalaryType type) {
    switch (type) {
      case SalaryType.HOURLY:
        return '/hr';
      case SalaryType.DAILY:
        return '/day';
      case SalaryType.WEEKLY:
        return '/week';
      case SalaryType.MONTHLY:
        return '/mo';
      case SalaryType.YEARLY:
        return '/yr';
      default:
        return '';
    }
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

  bool _isDeadlineApproaching(DateTime deadline) {
    final now = DateTime.now();
    final daysRemaining = deadline.difference(now).inDays;
    return daysRemaining <= 7 && daysRemaining > 0;
  }

  String _getDaysRemaining(DateTime deadline) {
    final now = DateTime.now();
    final days = deadline.difference(now).inDays;

    if (days < 0) return 'Expired';
    if (days == 0) return 'Today';
    if (days == 1) return '1 day';
    return '$days days';
  }

  String _getApplicantStatus(int? count) {
    if (count == null || count == 0) return 'No applicants yet';
    if (count == 1) return '1 applicant';
    return '$count applicants';
  }

  // ===================== DIALOGS =====================
  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        key: _deleteConfirmKey,
        title: const Text('Delete Job'),
        content: const Text(
          'Are you sure you want to delete this job? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: _cancelDelete, child: const Text('Cancel')),
          TextButton(
            onPressed: _deleteJob,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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

  // ===================== PAGINATION =====================
  List<int> _getPageNumbers() {
    const int maxVisible = 5;
    int start = (_currentPage - 1).clamp(0, _totalPages - maxVisible);
    int end = (start + maxVisible - 1).clamp(0, _totalPages - 1);

    if (end - start < maxVisible - 1) {
      start = (end - maxVisible + 1).clamp(0, _totalPages - 1);
    }

    return List.generate(end - start + 1, (i) => start + i);
  }

  List<int> _getLastPages() {
    if (_totalPages <= 7) return [];
    if (_currentPage >= _totalPages - 4) return [];
    return [_totalPages - 2, _totalPages - 1];
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadJobs(refresh: true);
  }

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading && _jobs.isEmpty,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Manage Jobs',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, RouteNames.postJob),
              icon: const Icon(Icons.add),
              tooltip: 'Post a job',
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null && _jobs.isEmpty) {
      return _buildErrorState();
    }

    return Column(
      children: [
        // Stats Summary
        _buildStatsSection(),

        // Filters
        _buildFiltersSection(),

        // Job List
        Expanded(
          child: _jobs.isEmpty && !_isLoading
              ? _buildEmptyState()
              : _buildJobList(),
        ),

        // Pagination
        if (_totalPages > 1) _buildPagination(),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Active', _stats['active'].toString(), Colors.green),
          _buildStatItem('Closed', _stats['closed'].toString(), Colors.red),
          _buildStatItem('Draft', _stats['draft'].toString(), Colors.orange),
          _buildStatItem(
            'Total',
            _stats['total'].toString(),
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
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

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Search
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search jobs...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _currentPage = 0;
                        _loadJobs(refresh: true);
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedStatusFilter.isEmpty
                        ? null
                        : _selectedStatusFilter,
                    hint: const Text('All Status'),
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('All Status'),
                      ),
                      ..._statusOptions.where((s) => s.isNotEmpty).map((
                        status,
                      ) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }),
                    ],
                    onChanged: _onStatusFilterChanged,
                  ),
                ),
                const SizedBox(width: 8),

                // Job Type Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedJobTypeFilter.isEmpty
                        ? null
                        : _selectedJobTypeFilter,
                    hint: const Text('All Types'),
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('All Types'),
                      ),
                      ..._jobTypeOptions.where((t) => t.isNotEmpty).map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            _formatJobType(
                              JobType.values.firstWhere(
                                (e) => e.name == type,
                                orElse: () => JobType.FULL_TIME,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                    onChanged: _onJobTypeFilterChanged,
                  ),
                ),

                // Clear Filters Button
                if (_selectedStatusFilter.isNotEmpty ||
                    _selectedJobTypeFilter.isNotEmpty ||
                    _searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList() {
    return RefreshIndicator(
      onRefresh: () => _loadJobs(refresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: _jobs.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _jobs.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildJobCard(_jobs[index]);
        },
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    final isDeleting = _deletingJobId == job.id;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          if (isDeleting)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Logo
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: job.company.logoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                job.company.logoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildDefaultLogo(),
                              ),
                            )
                          : _buildDefaultLogo(),
                    ),
                    const SizedBox(width: 12),

                    // Title and Company
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.company.name,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(job.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        job.status.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(job.status),
                        ),
                      ),
                    ),

                    // Dropdown Menu
                    PopupMenuButton<_JobMenuAction>(
                      icon: const Icon(Icons.more_vert),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      color: Colors.white,
                      itemBuilder: (context) => [
                        _popupItem(
                          value: _JobMenuAction.edit,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                        _popupItem(
                          value: _JobMenuAction.viewApplicants,
                          icon: Icons.people,
                          label: 'View Applicants',
                        ),
                        if (job.status != JobStatus.CLOSED)
                          _popupItem(
                            value: _JobMenuAction.close,
                            icon: Icons.block,
                            label: 'Close Job',
                          ),
                        if (job.status == JobStatus.CLOSED)
                          _popupItem(
                            value: _JobMenuAction.reopen,
                            icon: Icons.refresh,
                            label: 'Reopen Job',
                          ),
                        _popupItem(
                          value: _JobMenuAction.duplicate,
                          icon: Icons.copy,
                          label: 'Duplicate',
                        ),
                        const PopupMenuDivider(),
                        _popupItem(
                          value: _JobMenuAction.delete,
                          icon: Icons.delete,
                          label: 'Delete',
                          isDestructive: true,
                        ),
                      ],
                      onSelected: (action) {
                        switch (action) {
                          case _JobMenuAction.edit:
                            _editJob(job.id);
                            break;
                          case _JobMenuAction.viewApplicants:
                            _viewApplicants(job.id);
                            break;
                          case _JobMenuAction.close:
                            _closeJob(job.id);
                            break;
                          case _JobMenuAction.reopen:
                            _reopenJob(job);
                            break;
                          case _JobMenuAction.duplicate:
                            _duplicateJob(job);
                            break;
                          case _JobMenuAction.delete:
                            _confirmDelete(job.id);
                            break;
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Job Details Row
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      icon: Icons.work_outline,
                      label: _formatJobType(job.jobType),
                    ),
                    _buildInfoChip(
                      icon: Icons.location_on_outlined,
                      label: job.location,
                    ),
                    if (job.minSalary != null || job.maxSalary != null)
                      _buildInfoChip(
                        icon: Icons.attach_money,
                        label: _formatSalary(job),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Skills
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...job.skills.take(3).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    }).toList(),
                    if (job.skills.length > 3) ...[
                      const SizedBox(width: 4),
                      Text(
                        '+${job.skills.length - 3} more',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // Stats Row
                Row(
                  children: [
                    _buildStatIcon(
                      Icons.people_outline,
                      _getApplicantStatus(job.applicantsCount),
                    ),
                    const SizedBox(width: 8),
                    _buildStatIcon(
                      Icons.visibility_outlined,
                      '${job.viewsCount ?? 0} views',
                    ),
                    const SizedBox(width: 8),
                    _buildStatIcon(
                      Icons.access_time_outlined,
                      'Posted ${_formatPostedDate(job.postedAt)}',
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Deadline Warning
                if (_isDeadlineApproaching(job.deadline))
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Deadline approaching: ${_getDaysRemaining(job.deadline)} remaining',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDestructive ? Colors.red : AppColors.textPrimary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDestructive ? Colors.red : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.business,
        size: 24,
        color: AppColors.primary.withOpacity(0.5),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, -1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            onPressed: _currentPage > 0
                ? () => _onPageChanged(_currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),

          // Page numbers
          ..._getPageNumbers().map((page) {
            final isCurrentPage = page == _currentPage;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: isCurrentPage ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => _onPageChanged(page),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    child: Text(
                      '${page + 1}',
                      style: TextStyle(
                        color: isCurrentPage
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: isCurrentPage
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

          // Next button
          IconButton(
            onPressed: _currentPage < _totalPages - 1
                ? () => _onPageChanged(_currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 80,
              color: AppColors.textDisabled.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedStatusFilter.isNotEmpty ||
                      _selectedJobTypeFilter.isNotEmpty ||
                      _searchController.text.isNotEmpty
                  ? 'No matching jobs found'
                  : 'No jobs posted yet',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedStatusFilter.isNotEmpty ||
                      _selectedJobTypeFilter.isNotEmpty ||
                      _searchController.text.isNotEmpty
                  ? 'Try adjusting your filters'
                  : 'Start posting jobs to find the right candidates',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedStatusFilter.isNotEmpty ||
                _selectedJobTypeFilter.isNotEmpty ||
                _searchController.text.isNotEmpty)
              OutlinedButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              )
            else
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, RouteNames.postJob),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Post Your First Job'),
              ),
          ],
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
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Failed to load jobs',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadJobs(refresh: true),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
