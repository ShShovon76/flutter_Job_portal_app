// features/employer/presentation/candidates/applicants_list_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/api/aplication_api.dart';
import 'package:job_portal_app/core/api/job_api.dart';
import 'package:job_portal_app/core/api/resume_api.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/models/application_model.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';

class ApplicantsListScreen extends StatefulWidget {
  final int jobId;

  const ApplicantsListScreen({super.key, required this.jobId});

  @override
  State<ApplicantsListScreen> createState() => _ApplicantsListScreenState();
}

class _ApplicantsListScreenState extends State<ApplicantsListScreen> {
  // ===================== JOB STATE =====================
  Job? _job;
  bool _loadingJob = true;

  // ===================== APPLICATIONS STATE =====================
  List<JobApplication> _applications = [];
  Pagination<JobApplication>? _pagination;
  bool _isLoading = true;
  bool _isFetchingMore = false;
  String? _error;

  // ===================== FILTERS =====================
  final TextEditingController _searchController = TextEditingController();
  ApplicationStatus? _selectedStatus;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  Timer? _debounceTimer;

  // ===================== PAGINATION =====================
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalPages = 0;
  int _totalApplications = 0;
  bool _hasMore = true;

  // ===================== STATS =====================
  Map<String, int> _stats = {};

  // ===================== SELECTION STATE =====================
  final Set<int> _selectedApplications = {};
  bool _selectAll = false;

  // ===================== UI STATE =====================
  final Map<int, bool> _updatingStatus = {};
  final Map<int, bool> _downloadingResume = {};
  bool _showFilterBottomSheet = false;

  // ===================== NOTIFICATION STATE =====================
  bool _showNotification = false;
  String _notificationMessage = '';
  String _notificationType = 'info';
  Timer? _notificationTimer;

  // ===================== COVER LETTER MODAL =====================
  JobApplication? _selectedCoverLetter;

  @override
  void initState() {
    super.initState();
    _validateAndLoadData();
    _setupSearchListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _notificationTimer?.cancel();
    super.dispose();
  }

  // ===================== INITIALIZATION =====================
  void _validateAndLoadData() {
    if (widget.jobId <= 0) {
      _navigateBack();
      return;
    }
    _loadJob();
    _loadApplications(refresh: true);
  }

  void _navigateBack() {
    Navigator.pushReplacementNamed(context, RouteNames.manageJobs);
  }

  // ===================== DATA LOADING =====================
  Future<void> _loadJob() async {
    try {
      final job = await JobApi.getJobById(widget.jobId);
      if (mounted) {
        setState(() {
          _job = job;
          _loadingJob = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load job: $e');
      if (mounted) {
        setState(() => _loadingJob = false);
        _showNotificationMessage('Failed to load job details', 'error');
      }
    }
  }

  Future<void> _loadApplications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 0;
        _hasMore = true;
        _applications.clear();
        _selectedApplications.clear();
        _selectAll = false;
      });
    } else {
      if (!_hasMore || _isFetchingMore) return;
      setState(() => _isFetchingMore = true);
    }

    try {
      final response = await JobApplicationApi.getByJob(
        jobId: widget.jobId,
        page: _currentPage,
        size: _pageSize,
      );

      if (mounted) {
        setState(() {
          if (refresh) {
            _applications = response.items;
          } else {
            _applications.addAll(response.items);
          }
          _pagination = response;
          _totalPages = response.totalPages;
          _totalApplications = response.totalItems;
          _hasMore = _currentPage + 1 < response.totalPages;
          _currentPage++;
          _calculateStats();
          _error = null;
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isFetchingMore = false;
        });
        _showNotificationMessage('Failed to load applications', 'error');
      }
    }
  }

  // ===================== FILTER SETUP =====================
  void _setupSearchListener() {
    _searchController.addListener(() {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          _currentPage = 0;
          _loadApplications(refresh: true);
        }
      });
    });
  }

  // ===================== STATS CALCULATION =====================
  void _calculateStats() {
    final stats = <String, int>{};
    for (var app in _applications) {
      stats[app.status.value] = (stats[app.status.value] ?? 0) + 1;
    }
    _stats = stats;
  }

  // ===================== FILTER HANDLERS =====================
  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Applicants',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Status Filter
          const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedStatus == null,
                onSelected: (_) {
                  Navigator.pop(context);
                  setState(() => _selectedStatus = null);
                  _currentPage = 0;
                  _loadApplications(refresh: true);
                },
              ),
              ...ApplicationStatus.values.map((status) {
                return FilterChip(
                  label: Text(_getStatusLabel(status)),
                  selected: _selectedStatus == status,
                  onSelected: (_) {
                    Navigator.pop(context);
                    setState(() => _selectedStatus = status);
                    _currentPage = 0;
                    _loadApplications(refresh: true);
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: _getStatusColor(status).withOpacity(0.2),
                  checkmarkColor: _getStatusColor(status),
                );
              }),
            ],
          ),

          const SizedBox(height: 16),

          // Date Range
          const Text(
            'Date Range',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate:
                          _dateFrom ??
                          DateTime.now().subtract(const Duration(days: 30)),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _dateFrom = date);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    _dateFrom == null
                        ? 'From Date'
                        : DateFormat('MMM d, yyyy').format(_dateFrom!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dateTo ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _dateTo = date);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    _dateTo == null
                        ? 'To Date'
                        : DateFormat('MMM d, yyyy').format(_dateTo!),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Apply and Clear Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _dateFrom = null;
                      _dateTo = null;
                      _selectedStatus = null;
                      _currentPage = 0;
                    });
                    _loadApplications(refresh: true);
                  },
                  child: const Text('Clear Filters'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _currentPage = 0;
                    _loadApplications(refresh: true);
                  },
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

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _dateFrom = null;
      _dateTo = null;
      _currentPage = 0;
    });
    _loadApplications(refresh: true);
  }

  // ===================== FILTERED APPLICATIONS =====================
  List<JobApplication> get _filteredApplications {
    return _applications.where((app) {
      // Search filter
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        final nameMatch = (app.jobSeekerName ?? '').toLowerCase().contains(
          searchTerm,
        );
        final emailMatch = (app.jobSeekerEmail ?? '').toLowerCase().contains(
          searchTerm,
        );
        if (!(nameMatch || emailMatch)) return false;
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
          final endOfDay = DateTime(
            _dateTo!.year,
            _dateTo!.month,
            _dateTo!.day,
            23,
            59,
            59,
          );
          if (appliedDate.isAfter(endOfDay)) return false;
        }
      }

      return true;
    }).toList();
  }

  // ===================== APPLICATION ACTIONS =====================
  Future<void> _updateApplicationStatus(
    int applicationId,
    ApplicationStatus status,
  ) async {
    setState(() => _updatingStatus[applicationId] = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id ?? 0;

      final request = UpdateApplicationStatusRequest(status: status);
      final updated = await JobApplicationApi.updateStatus(
        applicationId: applicationId,
        request: request,
        changedByUserId: userId,
      );

      if (mounted) {
        setState(() {
          final index = _applications.indexWhere((a) => a.id == applicationId);
          if (index != -1) {
            _applications[index] = updated;
          }
          _updatingStatus[applicationId] = false;
          _calculateStats();
        });
        _showNotificationMessage('Status updated successfully', 'success');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _updatingStatus[applicationId] = false);
        _showNotificationMessage('Failed to update status', 'error');
      }
    }
  }

  Future<void> _bulkUpdateStatus(ApplicationStatus status) async {
    if (_selectedApplications.isEmpty) {
      _showNotificationMessage(
        'Please select at least one application',
        'warning',
      );
      return;
    }

    final confirmed = await _showConfirmDialog(
      'Bulk Update',
      'Update ${_selectedApplications.length} application(s) to ${_getStatusLabel(status)}?',
    );

    if (!confirmed) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id ?? 0;

    int successCount = 0;
    int failCount = 0;

    for (var applicationId in _selectedApplications) {
      try {
        final request = UpdateApplicationStatusRequest(status: status);
        final updated = await JobApplicationApi.updateStatus(
          applicationId: applicationId,
          request: request,
          changedByUserId: userId,
        );

        final index = _applications.indexWhere((a) => a.id == applicationId);
        if (index != -1) {
          _applications[index] = updated;
        }
        successCount++;
      } catch (e) {
        failCount++;
        debugPrint('Failed to update application $applicationId: $e');
      }
    }

    if (mounted) {
      setState(() {
        _selectedApplications.clear();
        _selectAll = false;
        _calculateStats();
      });

      if (failCount == 0) {
        _showNotificationMessage(
          'Updated $successCount application(s)',
          'success',
        );
      } else {
        _showNotificationMessage(
          'Updated $successCount, failed $failCount',
          'warning',
        );
      }
    }
  }

  void _viewApplicantProfile(int profileId) {
    Navigator.pushNamed(
      context,
      RouteNames.candidateProfile,
      arguments: {'profileId': profileId, 'jobId': widget.jobId},
    );
  }

  Future<void> _downloadResume(JobApplication application) async {
    if (application.resumeId == null) {
      _showNotificationMessage('No resume available', 'warning');
      return;
    }

    setState(() => _downloadingResume[application.id] = true);

    try {
      final bytes = await ResumeApi.downloadResume(application.resumeId!);
      _showNotificationMessage('Resume downloaded successfully', 'success');
    } catch (e) {
      _showNotificationMessage('Failed to download resume', 'error');
    } finally {
      if (mounted) {
        setState(() => _downloadingResume[application.id] = false);
      }
    }
  }

  void _viewCoverLetter(JobApplication application) {
    setState(() => _selectedCoverLetter = application);
    _showCoverLetterModal(application);
  }

  void _showCoverLetterModal(JobApplication application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cover Letter'),
        content: SingleChildScrollView(
          child: Text(
            application.coverLetter ?? 'No cover letter provided',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedCoverLetter = null);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ===================== SELECTION ACTIONS =====================
  void _toggleSelectAll() {
    setState(() {
      if (!_selectAll) {
        _selectedApplications.addAll(_filteredApplications.map((a) => a.id));
        _selectAll = true;
      } else {
        _selectedApplications.clear();
        _selectAll = false;
      }
    });
  }

  void _toggleApplicationSelection(int applicationId) {
    setState(() {
      if (_selectedApplications.contains(applicationId)) {
        _selectedApplications.remove(applicationId);
      } else {
        _selectedApplications.add(applicationId);
      }
      _selectAll = _selectedApplications.length == _filteredApplications.length;
    });
  }

  // ===================== NOTIFICATION =====================
  void _showNotificationMessage(
    String message,
    String type, {
    int duration = 3000,
  }) {
    _notificationTimer?.cancel();

    setState(() {
      _notificationMessage = message;
      _notificationType = type;
      _showNotification = true;
    });

    _notificationTimer = Timer(Duration(milliseconds: duration), () {
      if (mounted) {
        setState(() => _showNotification = false);
      }
    });
  }

  void _hideNotification() {
    _notificationTimer?.cancel();
    if (mounted) {
      setState(() => _showNotification = false);
    }
  }

  // ===================== PAGINATION =====================
  void _loadMore() {
    if (_hasMore && !_isFetchingMore) {
      _loadApplications();
    }
  }

  // ===================== UTILITY METHODS =====================
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
        return difference.inMinutes <= 1
            ? 'Just now'
            : '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    }
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365)
      return '${(difference.inDays / 30).floor()}mo ago';
    return '${(difference.inDays / 365).floor()}y ago';
  }

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

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading && _applications.isEmpty,
      child: Scaffold(
        appBar: AppBar(
          title: _loadingJob
              ? const Text('Applicants')
              : Text('${_job?.title ?? ''} - Applicants'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateBack,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _openFilterBottomSheet,
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Notification
                if (_showNotification) _buildNotification(),

                // Job Summary
                if (_job != null) _buildJobSummary(),

                // Stats Chips
                _buildStatsChips(),

                // Search Bar
                _buildSearchBar(),

                // Bulk Actions Bar
                if (_selectedApplications.isNotEmpty) _buildBulkActionsBar(),

                // Applications List
                Expanded(
                  child: _error != null && _applications.isEmpty
                      ? _buildErrorState()
                      : _applications.isEmpty && !_isLoading
                      ? _buildEmptyState()
                      : _buildApplicationsList(),
                ),

                // Loading More Indicator
                if (_isFetchingMore)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotification() {
    Color bgColor;
    IconData icon;

    switch (_notificationType) {
      case 'success':
        bgColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'error':
        bgColor = Colors.red;
        icon = Icons.error;
        break;
      case 'warning':
        bgColor = Colors.orange;
        icon = Icons.warning;
        break;
      default:
        bgColor = Colors.blue;
        icon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bgColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: bgColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _notificationMessage,
              style: TextStyle(color: bgColor, fontSize: 13),
            ),
          ),
          IconButton(
            onPressed: _hideNotification,
            icon: const Icon(Icons.close, size: 16),
            color: bgColor,
          ),
        ],
      ),
    );
  }

  Widget _buildJobSummary() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                _job!.company.logoUrl != null &&
                    _job!.company.logoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      AppConstants.getImageUrl(_job!.company.logoUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.business,
                          color: Color(0xFF3B82F6),
                        );
                      },
                    ),
                  )
                : const Icon(Icons.business, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _job!.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _job!.company.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$_totalApplications',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ApplicationStatus.values.length,
        itemBuilder: (context, index) {
          final status = ApplicationStatus.values[index];
          final count = _stats[status.value] ?? 0;
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
                  style: TextStyle(fontSize: 12, color: color),
                ),
                const SizedBox(width: 4),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name or email...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _currentPage = 0;
                    _loadApplications(refresh: true);
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

  Widget _buildBulkActionsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      color: AppColors.primary.withOpacity(0.1),
      child: Row(
        children: [
          Checkbox(
            value: _selectAll,
            onChanged: (_) => _toggleSelectAll(),
            activeColor: AppColors.primary,
          ),
          Text('${_selectedApplications.length} selected'),
          const Spacer(),
          PopupMenuButton<ApplicationStatus>(
            onSelected: _bulkUpdateStatus,
            itemBuilder: (context) => ApplicationStatus.values.map((status) {
              return PopupMenuItem(
                value: status,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_getStatusLabel(status)),
                  ],
                ),
              );
            }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Update',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList() {
    return RefreshIndicator(
      onRefresh: () => _loadApplications(refresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: _filteredApplications.length,
        itemBuilder: (context, index) {
          final application = _filteredApplications[index];
          return _buildApplicationCard(application);
        },
      ),
    );
  }

  Widget _buildApplicationCard(JobApplication application) {
    final isSelected = _selectedApplications.contains(application.id);
    final isUpdating = _updatingStatus[application.id] ?? false;
    final isDownloading = _downloadingResume[application.id] ?? false;
    final statusColor = _getStatusColor(application.status);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _viewApplicantProfile(application.jobSeekerId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Selection
              Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) =>
                        _toggleApplicationSelection(application.id),
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        // Profile Picture
                        CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              application.jobSeekerProfilePicture != null
                              ? NetworkImage(
                                  AppConstants.getImageUrl(
                                    application.jobSeekerProfilePicture!,
                                  ),
                                )
                              : null,
                          child: application.jobSeekerProfilePicture == null
                              ? Text(
                                  application.jobSeekerName?[0].toUpperCase() ??
                                      '?',
                                  style: const TextStyle(fontSize: 16),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),

                        // Name and Email
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                application.jobSeekerName ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                application.jobSeekerEmail ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Status and Date Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                          _getStatusLabel(application.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getRelativeTime(application.appliedAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action Buttons Row
              Row(
                children: [
                  // Status Update Dropdown
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<ApplicationStatus>(
                        value: application.status,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: isUpdating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.arrow_drop_down, size: 20),
                        items: ApplicationStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              _getStatusLabel(status),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: isUpdating
                            ? null
                            : (status) => _updateApplicationStatus(
                                application.id,
                                status!,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Download Resume
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isDownloading || application.resumeId == null
                          ? null
                          : () => _downloadResume(application),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: isDownloading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Resume',
                              style: TextStyle(fontSize: 12),
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Additional Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cover Letter
                  if (application.coverLetter != null)
                    TextButton.icon(
                      onPressed: () => _viewCoverLetter(application),
                      icon: const Icon(Icons.description, size: 16),
                      label: const Text(
                        'Cover Letter',
                        style: TextStyle(fontSize: 11),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),

                  // View Profile
                  TextButton.icon(
                    onPressed: () =>
                        _viewApplicantProfile(application.jobSeekerId),
                    icon: const Icon(Icons.person, size: 16),
                    label: const Text(
                      'Profile',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
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
              Icons.people_outline,
              size: 80,
              color: AppColors.textDisabled.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No applicants yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Applications will appear here when candidates apply',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Back to Jobs',
              onPressed: _navigateBack,
              width: 200,
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
              _error ?? 'Failed to load applications',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
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
