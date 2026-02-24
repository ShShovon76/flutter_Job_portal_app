// features/job_seeker/presentation/job/saved_jobs_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/api/saved_job.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';
import 'package:job_portal_app/models/saved_job.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  // ===================== STATE =====================
  List<SavedJob> _savedJobs = [];
  Pagination<SavedJob>? _pagination;
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _isRemoving = false;
  String? _error;
  Set<int> _removingIds = {};

  // ===================== PAGINATION =====================
  int _currentPage = 0;
  final int _pageSize = 10;
  int _totalPages = 0;
  bool _hasMore = true;

  // ===================== FILTERS =====================
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String? _selectedCompany;
  Set<String> _companies = {};

  // ===================== SCROLL CONTROLLER =====================
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSavedJobs(refresh: true);
    _setupSearchListener();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // ===================== DATA LOADING =====================
  Future<void> _loadSavedJobs({bool refresh = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      setState(() {
        _error = 'Please login to view saved jobs';
        _isLoading = false;
      });
      return;
    }

    if (refresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 0;
        _hasMore = true;
        _savedJobs.clear();
        _companies.clear();
      });
    } else {
      if (!_hasMore || _isFetchingMore) return;
      setState(() => _isFetchingMore = true);
    }

    try {
      final response = await SavedJobApi.getSavedJobs(
        page: _currentPage,
        size: _pageSize,
        sort: 'savedAt,desc',
      );

      setState(() {
        if (refresh) {
          _savedJobs = response.items;
        } else {
          _savedJobs.addAll(response.items);
        }

        // Extract unique company names for filter
        for (var savedJob in response.items) {
          if (savedJob.job?.company.name != null) {
            _companies.add(savedJob.job!.company.name);
          }
        }

        _pagination = response;
        _totalPages = response.totalPages;
        _hasMore = _currentPage + 1 < response.totalPages;
        _currentPage++;
        _error = null;
        _isLoading = false;
        _isFetchingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  // ===================== SETUP =====================
  void _setupSearchListener() {
    _searchController.addListener(() {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        setState(() {}); // Trigger rebuild for filtering
      });
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_hasMore && !_isFetchingMore) {
          _loadSavedJobs();
        }
      }
    });
  }

  // ===================== FILTERED JOBS =====================
  List<SavedJob> get _filteredSavedJobs {
    return _savedJobs.where((savedJob) {
      final job = savedJob.job;
      if (job == null) return false;

      // Search filter
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        final titleMatch = job.title.toLowerCase().contains(searchTerm);
        final companyMatch = job.company.name.toLowerCase().contains(
          searchTerm,
        );
        final locationMatch = job.location.toLowerCase().contains(searchTerm);
        if (!titleMatch && !companyMatch && !locationMatch) return false;
      }

      // Company filter
      if (_selectedCompany != null && job.company.name != _selectedCompany) {
        return false;
      }

      return true;
    }).toList();
  }

  // ===================== JOB ACTIONS =====================
  Future<void> _unsaveJob(SavedJob savedJob) async {
    if (_removingIds.contains(savedJob.id)) return;

    setState(() {
      _removingIds.add(savedJob.id);
    });

    try {
      await SavedJobApi.unsaveJobById(savedJob.id);

      setState(() {
        _savedJobs.removeWhere((j) => j.id == savedJob.id);
        _removingIds.remove(savedJob.id);
      });

      _showSnackBar('Job removed from saved');
    } catch (e) {
      setState(() {
        _removingIds.remove(savedJob.id);
      });
      _showSnackBar('Failed to remove job', isError: true);
    }
  }

  Future<void> _confirmUnsave(SavedJob savedJob) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Saved Job'),
        content: Text(
          'Are you sure you want to remove "${savedJob.job?.title}" from your saved jobs?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _unsaveJob(savedJob);
    }
  }

  void _viewJobDetails(int jobId) {
    Navigator.pushNamed(context, RouteNames.jobDetails, arguments: jobId);
  }

  // ===================== FILTER METHODS =====================
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCompany = null;
    });
  }

  void _showCompanyFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Company',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('All Companies'),
              leading: Radio<String>(
                value: '',
                groupValue: _selectedCompany ?? '',
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() => _selectedCompany = null);
                },
              ),
            ),
            ..._companies.map((company) {
              return ListTile(
                title: Text(company),
                leading: Radio<String>(
                  value: company,
                  groupValue: _selectedCompany ?? '',
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() => _selectedCompany = value);
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ===================== UTILITY METHODS =====================
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
    }
  }

  String _formatJobType(JobType type) {
    return type.name.replaceAll('_', ' ').toUpperCase();
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
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  String _formatSavedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
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
    }
  }

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    final filteredJobs = _filteredSavedJobs;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Jobs',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          if (_companies.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showCompanyFilter,
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading && _savedJobs.isEmpty,
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(),

            // Filter Chips
            if (_searchController.text.isNotEmpty || _selectedCompany != null)
              _buildActiveFilters(),

            // Results Count
            _buildResultsCount(filteredJobs.length),

            // Saved Jobs List
            Expanded(
              child: _error != null && _savedJobs.isEmpty
                  ? _buildErrorState()
                  : _savedJobs.isEmpty && !_isLoading
                  ? _buildEmptyState()
                  : filteredJobs.isEmpty
                  ? _buildNoResultsState()
                  : _buildJobsList(filteredJobs),
            ),

            // Loading More Indicator
            if (_isFetchingMore)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search saved jobs...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_searchController.text.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '"${_searchController.text}"',
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _searchController.clear(),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            if (_selectedCompany != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCompany!,
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => setState(() => _selectedCompany = null),
                      child: Icon(Icons.close, size: 14, color: Colors.green),
                    ),
                  ],
                ),
              ),
            if (_searchController.text.isNotEmpty || _selectedCompany != null)
              TextButton(
                onPressed: _clearFilters,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Clear all', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCount(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: Row(
        children: [
          Expanded(
            // <-- add this for safety
            child: Text(
              count == _savedJobs.length
                  ? '${_savedJobs.length} saved jobs'
                  : '$count of ${_savedJobs.length} saved jobs',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList(List<SavedJob> savedJobs) {
    return RefreshIndicator(
      onRefresh: () => _loadSavedJobs(refresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: savedJobs.length,
        itemBuilder: (context, index) {
          final savedJob = savedJobs[index];
          final job = savedJob.job;
          if (job == null) return const SizedBox();

          final isRemoving = _removingIds.contains(savedJob.id);

          return _buildSavedJobCard(savedJob, job, isRemoving);
        },
      ),
    );
  }

  Widget _buildSavedJobCard(SavedJob savedJob, Job job, bool isRemoving) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          if (isRemoving)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          InkWell(
            onTap: () => _viewJobDetails(job.id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Logo and Title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company Logo
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: job.company.logoUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
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

                      // Title and Company Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              job.company.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Remove Button
                      IconButton(
                        onPressed: isRemoving
                            ? null
                            : () => _confirmUnsave(savedJob),
                        icon: Icon(
                          Icons.bookmark_remove,
                          color: Colors.red.shade400,
                        ),
                        iconSize: 20,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Job Type Icon and Location
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getJobTypeIcon(job.jobType),
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          job.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Salary
                  if (job.minSalary != null || job.maxSalary != null)
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 14,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatSalary(job),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
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
                      }),
                      if (job.skills.length > 3) ...[
                        const SizedBox(width: 4),
                        Text(
                          '+${job.skills.length - 3}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Footer with Dates
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Posted Date
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Posted ${_formatPostedDate(job.postedAt)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),

                      // Saved Date
                      Row(
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Saved ${_formatSavedDate(savedJob.savedAt)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(
        Icons.business,
        size: 28,
        color: AppColors.primary.withValues(alpha: 0.5),
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
              Icons.bookmark_border,
              size: 80,
              color: AppColors.textDisabled.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Saved Jobs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save jobs you\'re interested in to view them later',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Browse Jobs',
              onPressed: () {
                Navigator.pushReplacementNamed(context, RouteNames.jobFeed);
              },
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textDisabled.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Matching Jobs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or filters',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _clearFilters,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Clear Filters'),
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
              _error ?? 'Failed to load saved jobs',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Try Again',
              onPressed: () => _loadSavedJobs(refresh: true),
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}
