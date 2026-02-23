// features/job_seeker/presentation/tracking/applied_jobs_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/features/job_seeker/provider/application_provider.dart';
import 'package:job_portal_app/models/application_model.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  // ===================== CONTROLLERS =====================
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  // ===================== FILTERS =====================
  ApplicationStatus? _selectedStatus;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _showFilters = false;

  // ===================== STATS =====================
  Map<String, int> _statusCounts = {};

@override
void initState() {
  super.initState();

  // Defer data loading until after the first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadApplications();
  });

  _setupSearchListener();
  _setupScrollListener();
}

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ===================== DATA LOADING =====================
  Future<void> _loadApplications({bool refresh = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      _showSnackBar('User not authenticated', isError: true);
      return;
    }

    final provider = Provider.of<JobApplicationProvider>(context, listen: false);
    await provider.fetchByJobSeeker(userId: userId, refresh: refresh);
    
    if (refresh) {
      _calculateStats(provider.applications);
    }
  }

  void _calculateStats(List<JobApplication> applications) {
    final counts = <String, int>{};
    for (var app in applications) {
      counts[app.status.value] = (counts[app.status.value] ?? 0) + 1;
    }
    setState(() {
      _statusCounts = counts;
    });
  }

  // ===================== SETUP =====================
  void _setupSearchListener() {
    _searchController.addListener(() {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _applyFilters();
      });
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final provider = Provider.of<JobApplicationProvider>(context, listen: false);
        if (!provider.isLoading && provider.hasMore) {
          _loadApplications();
        }
      }
    });
  }

  // ===================== FILTER METHODS =====================
  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
  }

  void _applyFilters() {
    setState(() {
      // Filters are applied in the filtered getter
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _dateFrom = null;
      _dateTo = null;
      _showFilters = false;
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() {
        _dateFrom = range.start;
        _dateTo = range.end;
      });
    }
  }

  // ===================== FILTERED APPLICATIONS =====================
  List<JobApplication> _filteredApplications(JobApplicationProvider provider) {
  return provider.applications.where((app) {
    // Search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      final jobTitleMatch = (app.jobTitle ?? '').toLowerCase().contains(searchTerm);
      final companyMatch = (app.companyName ?? '').toLowerCase().contains(searchTerm);
      if (!jobTitleMatch && !companyMatch) return false;
    }

    // Status filter
    if (_selectedStatus != null && app.status != _selectedStatus) {
      return false;
    }

    // Date range filter
    if (_dateFrom != null || _dateTo != null) {
      final appliedDate = DateTime.parse(app.appliedAt);
      if (_dateFrom != null && appliedDate.isBefore(_dateFrom!)) return false;
      if (_dateTo != null) {
        final endOfDay = DateTime(_dateTo!.year, _dateTo!.month, _dateTo!.day, 23, 59, 59);
        if (appliedDate.isAfter(endOfDay)) return false;
      }
    }

    return true;
  }).toList();
}

  // ===================== APPLICATION ACTIONS =====================
  Future<void> _viewJobDetails(int jobId) async {
    Navigator.pushNamed(
      context,
      RouteNames.jobDetails,
      arguments: jobId,
    );
  }

  Future<void> _withdrawApplication(JobApplication application) async {
    final confirmed = await _showConfirmDialog(
      'Withdraw Application',
      'Are you sure you want to withdraw your application for "${application.jobTitle}"?',
    );

    if (!confirmed) return;

    try {
      final provider = Provider.of<JobApplicationProvider>(context, listen: false);
      await provider.withdraw(application.id);
      
      if (mounted) {
        _showSnackBar('Application withdrawn successfully');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to withdraw application', isError: true);
      }
    }
  }

  Future<void> _viewCoverLetter(JobApplication application) async {
    if (application.coverLetter == null || application.coverLetter!.isEmpty) {
      _showSnackBar('No cover letter provided', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cover Letter'),
        content: SingleChildScrollView(
          child: Text(
            application.coverLetter!,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ===================== UTILITY METHODS =====================
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
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    return result ?? false;
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

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.APPLIED:
        return Colors.blue;
      case ApplicationStatus.UNDER_REVIEW:
        return Colors.amber;
      case ApplicationStatus.SHORTLISTED:
        return Colors.purple;
      case ApplicationStatus.INTERVIEW:
        return Colors.green;
      case ApplicationStatus.OFFERED:
        return Colors.teal;
      case ApplicationStatus.REJECTED:
        return Colors.red;
      case ApplicationStatus.CANCELLED:
        return Colors.grey;
    }
  }

  String _getStatusLabel(ApplicationStatus status) {
    return status.value.replaceAll('_', ' ').toUpperCase();
  }

  String _getRelativeTime(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return difference.inMinutes <= 1 ? 'Just now' : '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    }
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo ago';
    return '${(difference.inDays / 365).floor()}y ago';
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('MMM d, yyyy').format(date);
  }

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    return Consumer<JobApplicationProvider>(
  builder: (context, provider, child) {
    final filteredApps = _filteredApplications(provider);

        return LoadingOverlay(
          isLoading: provider.isLoading && provider.applications.isEmpty,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'My Applications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _toggleFilters,
                ),
              ],
            ),
            body: Column(
              children: [
                // Search Bar
                _buildSearchBar(),

                // Filter Panel
                if (_showFilters) _buildFilterPanel(),

                // Status Stats
                if (provider.applications.isNotEmpty) _buildStatusStats(),

                // Results Count
                _buildResultsCount(filteredApps.length, provider.applications.length),

                // Applications List
                Expanded(
                  child: provider.error != null && provider.applications.isEmpty
                      ? _buildErrorState(provider.error!)
                      : provider.applications.isEmpty && !provider.isLoading
                          ? _buildEmptyState()
                          : filteredApps.isEmpty
                              ? _buildNoResultsState()
                              : _buildApplicationsList(filteredApps, provider),
                ),

                // Loading More Indicator
                if (provider.isFetchingMore)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
          hintText: 'Search by job title or company...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
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
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedStatus == null,
                  onSelected: (_) {
                    setState(() => _selectedStatus = null);
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
                ...ApplicationStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_getStatusLabel(status)),
                      selected: _selectedStatus == status,
                      onSelected: (selected) {
                        setState(() => _selectedStatus = selected ? status : null);
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: _getStatusColor(status).withOpacity(0.2),
                      checkmarkColor: _getStatusColor(status),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Date Range
          const Text(
            'Date Range',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _dateFrom != null && _dateTo != null
                        ? '${DateFormat('MMM d').format(_dateFrom!)} - ${DateFormat('MMM d').format(_dateTo!)}'
                        : 'Select Date Range',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Filter Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear Filters'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStats() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ApplicationStatus.values.length,
        itemBuilder: (context, index) {
          final status = ApplicationStatus.values[index];
          final count = _statusCounts[status.value] ?? 0;
          if (count == 0) return const SizedBox();
          
          final color = _getStatusColor(status);
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _getStatusLabel(status),
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsCount(int filteredCount, int totalCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      child: Row(
        children: [
          Text(
            filteredCount == totalCount
                ? '$totalCount applications'
                : '$filteredCount of $totalCount applications',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (_searchController.text.isNotEmpty ||
              _selectedStatus != null ||
              _dateFrom != null)
            TextButton(
              onPressed: _clearFilters,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Clear Filters',
                style: TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(List<JobApplication> applications, JobApplicationProvider provider) {
    return RefreshIndicator(
      onRefresh: () => _loadApplications(refresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          return _buildApplicationCard(application);
        },
      ),
    );
  }

  Widget _buildApplicationCard(JobApplication application) {
    final statusColor = _getStatusColor(application.status);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewJobDetails(application.jobId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Company Logo Placeholder
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Job Title and Company
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.jobTitle ?? 'Unknown Position',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.companyName ?? 'Unknown Company',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
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
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(application.status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Applied Date
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Applied ${_getRelativeTime(application.appliedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  // View Details Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewJobDetails(application.jobId),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Job'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Cover Letter Button (if available)
                  if (application.coverLetter != null && application.coverLetter!.isNotEmpty)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewCoverLetter(application),
                        icon: const Icon(Icons.description, size: 16),
                        label: const Text('Cover Letter'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),

                  // Withdraw Button
                  if (application.status == ApplicationStatus.APPLIED ||
                      application.status == ApplicationStatus.UNDER_REVIEW)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        onPressed: () => _withdrawApplication(application),
                        icon: const Icon(Icons.close, color: Colors.red),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                        ),
                      ),
                    ),
                ],
              ),

              // Timeline Indicator (optional)
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Applied on ${_formatDate(application.appliedAt)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
              Icons.send_outlined,
              size: 80,
              color: AppColors.textDisabled.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Applications Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start applying for jobs to see your applications here',
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
              color: AppColors.textDisabled.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Matching Applications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your filters',
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Try Again',
              onPressed: () => _loadApplications(refresh: true),
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}