

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
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/models/application_model.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/common/confirmation_dialog.dart';
import 'package:job_portal_app/shared/widgets/common/empty_state_widget.dart';
import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
import 'package:job_portal_app/shared/widgets/common/notification_widget.dart';
import 'package:job_portal_app/shared/widgets/inputs/error_screen.dart';
import 'package:provider/provider.dart';


class ApplicantsListScreen extends StatefulWidget {
  final int jobId;

  const ApplicantsListScreen({
    super.key,
    required this.jobId,
  });

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
  final List<int> _pageSizeOptions = [5, 10, 20, 50];
  int _totalPages = 0;
  int _totalApplications = 0;
  bool _hasMore = true;

  // ===================== STATS =====================
  Map<String, int> _stats = {};

  // ===================== SELECTION STATE =====================
  final Set<int> _selectedApplications = {};
  bool _selectAll = false;

  // ===================== VIEW MODE =====================
  bool _isGridView = false;

  // ===================== UI STATE =====================
  final Map<int, bool> _updatingStatus = {};
  final Map<int, bool> _downloadingResume = {};

  // ===================== NOTIFICATION STATE =====================
  bool _showNotification = false;
  String _notificationMessage = '';
  String _notificationType = 'info';
  Timer? _notificationTimer;

  // ===================== MODAL STATE =====================
  JobApplication? _selectedCoverLetter;
  String? _pdfPreviewUrl;
  bool _showPdfModal = false;

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
    setState(() => _loadingJob = true);

    try {
      final job = await JobApi.getJobById(widget.jobId);
      setState(() {
        _job = job;
        _loadingJob = false;
      });
    } catch (e) {
      debugPrint('Failed to load job: $e');
      setState(() => _loadingJob = false);
      _showNotificationMessage('Failed to load job details', 'error');
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
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isFetchingMore = false;
      });
      _showNotificationMessage('Failed to load applications', 'error');
    }
  }

  // ===================== FILTER SETUP =====================
  void _setupSearchListener() {
    _searchController.addListener(() {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _currentPage = 0;
        _loadApplications(refresh: true);
      });
    });
  }

  // ===================== STATS CALCULATION =====================
  void _calculateStats() {
    final stats = <String, int>{};
    for (var app in _applications) {
      stats[app.status.value] = (stats[app.status.value] ?? 0) + 1;
    }
    setState(() => _stats = stats);
  }

  // ===================== FILTER HANDLERS =====================
  void _onStatusFilterChanged(ApplicationStatus? status) {
    setState(() => _selectedStatus = status);
    _currentPage = 0;
    _loadApplications(refresh: true);
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
      if (range.start.isAfter(range.end)) {
        _showNotificationMessage(
          '"Date From" cannot be after "Date To"',
          'warning',
        );
        return;
      }
      setState(() {
        _dateFrom = range.start;
        _dateTo = range.end;
      });
      _currentPage = 0;
      _loadApplications(refresh: true);
    }
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
        final nameMatch = (app.jobSeekerName ?? '').toLowerCase().contains(searchTerm);
        final emailMatch = (app.jobSeekerEmail ?? '').toLowerCase().contains(searchTerm);
        final coverLetterMatch = (app.coverLetter ?? '').toLowerCase().contains(searchTerm);
        if (!(nameMatch || emailMatch || coverLetterMatch)) return false;
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
  Future<void> _updateApplicationStatus(int applicationId, ApplicationStatus status) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Update Status',
      message: 'Are you sure you want to update this application status?',
      confirmText: 'Update',
    );

    if (!confirmed) return;

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

      setState(() {
        final index = _applications.indexWhere((a) => a.id == applicationId);
        if (index != -1) {
          _applications[index] = updated;
        }
        _updatingStatus[applicationId] = false;
        _calculateStats();
      });

      _showNotificationMessage('Status updated successfully', 'success');
    } catch (e) {
      setState(() => _updatingStatus[applicationId] = false);
      _showNotificationMessage('Failed to update status', 'error');
    }
  }

  Future<void> _bulkUpdateStatus(ApplicationStatus status) async {
    if (_selectedApplications.isEmpty) {
      _showNotificationMessage('Please select at least one application', 'warning');
      return;
    }

    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Bulk Update',
      message: 'Update ${_selectedApplications.length} application(s) to ${status.value}?',
      confirmText: 'Update',
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

    setState(() {
      _selectedApplications.clear();
      _selectAll = false;
      _calculateStats();
    });

    if (failCount == 0) {
      _showNotificationMessage('Updated $successCount application(s)', 'success');
    } else {
      _showNotificationMessage('Updated $successCount, failed $failCount', 'warning');
    }
  }

  void _viewApplicantProfile(int userId) {
    Navigator.pushNamed(
      context,
      RouteNames.candidateProfile,
      arguments: {'userId': userId, 'jobId': widget.jobId},
    );
  }

  // ===================== RESUME ACTIONS =====================
  Future<void> _downloadResume(JobApplication application) async {
    if (application.resumeId == null) {
      _showNotificationMessage('No resume available', 'warning');
      return;
    }

    setState(() => _downloadingResume[application.id] = true);

    try {
      final bytes = await ResumeApi.downloadResume(application.resumeId!);
      
      // Save file using share_plus or file_picker
      // For Flutter web/mobile, you'd use different approaches
      // This is a simplified version - you may need to add share_plus package
      
      _showNotificationMessage('Resume downloaded successfully', 'success');
    } catch (e) {
      _showNotificationMessage('Failed to download resume', 'error');
    } finally {
      setState(() => _downloadingResume[application.id] = false);
    }
  }

  Future<void> _previewResume(JobApplication application) async {
    if (application.resumeId == null) {
      _showNotificationMessage('No resume available', 'warning');
      return;
    }

    try {
      final bytes = await ResumeApi.downloadResume(application.resumeId!);
      
      // For PDF preview, you'd create a temporary file or use a PDF viewer
      // This is a simplified version - you may need to add pdf_viewer plugin
      
      setState(() {
        _pdfPreviewUrl = 'data:application/pdf;base64,${base64Encode(bytes)}';
        _showPdfModal = true;
      });
    } catch (e) {
      _showNotificationMessage('Unable to preview resume', 'error');
    }
  }

  void _closePdfPreview() {
    setState(() {
      _pdfPreviewUrl = null;
      _showPdfModal = false;
    });
  }

  // ===================== COVER LETTER ACTIONS =====================
  void _viewCoverLetter(JobApplication application) {
    setState(() => _selectedCoverLetter = application);
  }

  void _closeCoverLetter() {
    setState(() => _selectedCoverLetter = null);
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
  void _showNotificationMessage(String message, String type, {int duration = 5000}) {
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
    setState(() => _showNotification = false);
  }

  // ===================== PAGINATION =====================
  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _loadApplications(refresh: true);
  }

  void _onPageSizeChanged(int? newSize) {
    if (newSize != null) {
      setState(() {
        _pageSize = newSize;
        _currentPage = 0;
      });
      _loadApplications(refresh: true);
    }
  }

  List<int> _getPageNumbers() {
    const int maxVisible = 5;
    int start = (_currentPage - 1).clamp(0, _totalPages - maxVisible);
    int end = (start + maxVisible - 1).clamp(0, _totalPages - 1);

    if (end - start < maxVisible - 1) {
      start = (end - maxVisible + 1).clamp(0, _totalPages - 1);
    }

    return List.generate(end - start + 1, (i) => start + i);
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
        return difference.inMinutes <= 1 ? 'Just now' : '${difference.inMinutes} minutes ago';
      }
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    }
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    }
    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    }
    final years = (difference.inDays / 365).floor();
    return years == 1 ? '1 year ago' : '$years years ago';
  }

  String _getFormattedDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('MMM d, yyyy').format(date);
  }

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading && _applications.isEmpty,
      child: Scaffold(
        appBar: AppBar(
          title: _loadingJob
              ? const Text('Loading...')
              : Text('Applicants - ${_job?.title ?? ''}'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateBack,
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Notification
                if (_showNotification)
                  NotificationWidget(
                    message: _notificationMessage,
                    type: _notificationType,
                    onDismiss: _hideNotification,
                  ),

                // Job Summary Card
                if (_job != null) _buildJobSummaryCard(),

                // Stats Cards
                _buildStatsSection(),

                // Filters Bar
                _buildFiltersBar(),

                // Bulk Actions Bar
                if (_selectedApplications.isNotEmpty)
                  _buildBulkActionsBar(),

                // View Mode Toggle and Page Size
                _buildViewControls(),

                // Applications List/Grid
                Expanded(
                  child: _error != null && _applications.isEmpty
                      ? ErrorScreen(
                          message: _error!,
                          onRetry: () => _loadApplications(refresh: true),
                        )
                      : _applications.isEmpty && !_isLoading
                          ? EmptyStateWidget(
                              icon: Icons.people_outline,
                              message: 'No applications yet',
                              subtitle: 'Applications will appear here when candidates apply',
                              buttonText: 'Back to Jobs',
                              onButtonPressed: _navigateBack,
                            )
                          : _isGridView
                              ? _buildGridView()
                              : _buildListView(),
                ),

                // Pagination
                if (_totalPages > 1) _buildPagination(),
              ],
            ),

            // Loading More Indicator
            if (_isFetchingMore)
              const Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _job?.company.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _job!.company.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.business),
                    ),
                  )
                : const Icon(Icons.business, color: AppColors.primary),
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
                const SizedBox(height: 4),
                Text(
                  _job!.company.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_totalApplications Applicants',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ApplicationStatus.values.length,
        itemBuilder: (context, index) {
          final status = ApplicationStatus.values[index];
          final count = _stats[status.value] ?? 0;
          final color = _getStatusColor(status);
          
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getStatusLabel(status),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltersBar() {
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
            decoration: InputDecoration(
              hintText: 'Search by name, email, cover letter...',
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
                  child: DropdownButton<ApplicationStatus?>(
                    value: _selectedStatus,
                    hint: const Text('All Status'),
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Status'),
                      ),
                      ...ApplicationStatus.values.map((status) {
                        return DropdownMenuItem(
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
                      }),
                    ],
                    onChanged: _onStatusFilterChanged,
                  ),
                ),
                const SizedBox(width: 8),

                // Date Range Filter
                OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _dateFrom != null && _dateTo != null
                        ? '${DateFormat('MMM d').format(_dateFrom!)} - ${DateFormat('MMM d').format(_dateTo!)}'
                        : 'Date Range',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),

                // Clear Filters Button
                if (_searchController.text.isNotEmpty ||
                    _selectedStatus != null ||
                    _dateFrom != null)
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

  Widget _buildBulkActionsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Update Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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

  Widget _buildViewControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      child: Row(
        children: [
          // Page Size Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<int>(
              value: _pageSize,
              underline: const SizedBox(),
              items: _pageSizeOptions.map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text('$size per page'),
                );
              }).toList(),
              onChanged: _onPageSizeChanged,
            ),
          ),
          const Spacer(),
          
          // View Mode Toggle
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => setState(() => _isGridView = false),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: !_isGridView ? AppColors.primary : Colors.transparent,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                    ),
                    child: Icon(
                      Icons.list,
                      size: 20,
                      color: !_isGridView ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _isGridView = true),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isGridView ? AppColors.primary : Colors.transparent,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                    ),
                    child: Icon(
                      Icons.grid_view,
                      size: 20,
                      color: _isGridView ? Colors.white : AppColors.textPrimary,
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

  Widget _buildListView() {
    final filtered = _filteredApplications;
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final application = filtered[index];
        return _buildApplicationCard(application);
      },
    );
  }

  Widget _buildGridView() {
    final filtered = _filteredApplications;
    
    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final application = filtered[index];
        return _buildApplicationGridCard(application);
      },
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
                    onChanged: (_) => _toggleApplicationSelection(application.id),
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        // Profile Picture
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: application.jobSeekerProfilePicture != null
                              ? NetworkImage(application.jobSeekerProfilePicture!)
                              : null,
                          child: application.jobSeekerProfilePicture == null
                              ? Text(
                                  application.jobSeekerName?[0].toUpperCase() ?? '?',
                                  style: const TextStyle(fontSize: 18),
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
                              const SizedBox(height: 4),
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
              
              // Status Badge and Date
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
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
              
              // Action Buttons
              Row(
                children: [
                  // Status Update Dropdown
                  Expanded(
                    child: Container(
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
                                child: CircularProgressIndicator(strokeWidth: 2),
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
                            : (status) => _updateApplicationStatus(application.id, status!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Download Resume
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isDownloading
                          ? null
                          : () => _downloadResume(application),
                      icon: isDownloading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download, size: 16),
                      label: const Text('Resume', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Additional Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Preview Resume
                  TextButton.icon(
                    onPressed: application.resumeId == null
                        ? null
                        : () => _previewResume(application),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Preview', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  
                  // View Cover Letter
                  if (application.coverLetter != null)
                    TextButton.icon(
                      onPressed: () => _viewCoverLetter(application),
                      icon: const Icon(Icons.description, size: 16),
                      label: const Text('Cover Letter', style: TextStyle(fontSize: 11)),
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

  Widget _buildApplicationGridCard(JobApplication application) {
    final isSelected = _selectedApplications.contains(application.id);
    final isUpdating = _updatingStatus[application.id] ?? false;
    final statusColor = _getStatusColor(application.status);

    return Card(
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
          padding: const EdgeInsets.all(AppSizes.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Selection Checkbox
              Align(
                alignment: Alignment.topRight,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleApplicationSelection(application.id),
                  activeColor: AppColors.primary,
                ),
              ),
              
              // Profile Picture
              CircleAvatar(
                radius: 30,
                backgroundImage: application.jobSeekerProfilePicture != null
                    ? NetworkImage(application.jobSeekerProfilePicture!)
                    : null,
                child: application.jobSeekerProfilePicture == null
                    ? Text(
                        application.jobSeekerName?[0].toUpperCase() ?? '?',
                        style: const TextStyle(fontSize: 20),
                      )
                    : null,
              ),
              
              const SizedBox(height: 8),
              
              // Name
              Text(
                application.jobSeekerName ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 4),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusLabel(application.status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Date
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    _getRelativeTime(application.appliedAt),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Status Update
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
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
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.arrow_drop_down, size: 16),
                        items: ApplicationStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              _getStatusLabel(status),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }).toList(),
                        onChanged: isUpdating
                            ? null
                            : (status) => _updateApplicationStatus(application.id, status!),
                      ),
                    ),
                  ),
                  
                  // Resume Preview
                  if (application.resumeId != null)
                    IconButton(
                      onPressed: () => _previewResume(application),
                      icon: const Icon(Icons.visibility, size: 18),
                      color: AppColors.primary,
                      tooltip: 'Preview Resume',
                    ),
                ],
              ),
            ],
          ),
        ),
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
            onPressed: _currentPage > 0 ? () => _onPageChanged(_currentPage - 1) : null,
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
                        color: isCurrentPage ? Colors.white : AppColors.textPrimary,
                        fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
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
}