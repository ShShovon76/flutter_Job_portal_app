// features/job_seeker/presentation/job/company_jobs_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/api/company_api.dart';
import 'package:job_portal_app/core/api/job_api.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/models/company_model.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:provider/provider.dart';

class CompanyJobsScreen extends StatefulWidget {
  final int companyId;

  const CompanyJobsScreen({super.key, required this.companyId});

  @override
  State<CompanyJobsScreen> createState() => _CompanyJobsScreenState();
}

class _CompanyJobsScreenState extends State<CompanyJobsScreen> {
  Company? _company;
  List<Job> _jobs = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasMore = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoadingMore) {
        _loadMoreJobs();
      }
    }
  }

  Future<void> _loadCompanyData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load company details
      final company = await CompanyApi().getCompanyById(widget.companyId);
      
      // Load jobs
      await _loadJobs(refresh: true);
      
      setState(() {
        _company = company;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

 Future<void> _loadJobs({bool refresh = false}) async {
  if (refresh) {
    _currentPage = 0;
    _hasMore = true;
  }

  if (!_hasMore || _isLoadingMore) return;

  try {
    final filter = JobSearchFilter(
      companyId: widget.companyId,
      page: _currentPage,
      size: _pageSize,
    );

    // FIX: Use named parameter 'filter:'
    final result = await JobApi.searchJobs(
      filter: filter,  // 👈 Add the named parameter
      page: _currentPage,
      size: _pageSize,
    );

    setState(() {
      if (refresh) {
        _jobs = result.items;
      } else {
        _jobs.addAll(result.items);
      }
      _hasMore = _currentPage + 1 < result.totalPages;
      _currentPage++;
      _isLoading = false;
      _isLoadingMore = false;
    });
  } catch (e) {
    setState(() {
      _error = e.toString();
      _isLoading = false;
      _isLoadingMore = false;
    });
  }
}

  Future<void> _loadMoreJobs() async {
    setState(() => _isLoadingMore = true);
    await _loadJobs();
  }

  void _navigateToJobDetails(int jobId) {
    Navigator.pushNamed(
      context,
      RouteNames.jobDetails,
      arguments: jobId,
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
      default:
        return '';
    }
  }

  String _formatJobType(JobType type) {
    return type.name.replaceAll('_', ' ').toUpperCase();
  }

  String _formatPostedDate(DateTime date) {
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
    return DateFormat('MMM d').format(date);
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

  Color _getJobTypeColor(JobType type) {
    switch (type) {
      case JobType.FULL_TIME:
        return Colors.blue;
      case JobType.PART_TIME:
        return Colors.orange;
      case JobType.CONTRACT:
        return Colors.purple;
      case JobType.REMOTE:
        return Colors.green;
      case JobType.INTERNSHIP:
        return Colors.teal;
      case JobType.FREELANCE:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: _company != null
            ? Text(
                _company!.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : const Text(
                'Company Jobs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _isLoading
          ? _buildShimmerLoader()
          : _error != null
              ? _buildErrorState()
              : _jobs.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () => _loadJobs(refresh: true),
                      color: AppColors.primary,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _jobs.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _jobs.length) {
                            return _buildLoadingMoreIndicator();
                          }
                          return _buildJobCard(_jobs[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildJobCard(Job job) {
    final jobTypeColor = _getJobTypeColor(job.jobType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToJobDetails(job.id),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: job.company.logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          job.company.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.business,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : const Icon(Icons.business, color: AppColors.primary),
              ),
              const SizedBox(width: 12),

              // Job Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.company.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            job.location,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: jobTypeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatJobType(job.jobType),
                        style: TextStyle(
                          fontSize: 9,
                          color: jobTypeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Salary and Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (job.minSalary != null || job.maxSalary != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatSalary(job),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _formatPostedDate(job.postedAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade400,
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

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
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
              Icons.business_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No jobs found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _company != null
                  ? '${_company!.name} has no active jobs at the moment'
                  : 'This company has no active jobs at the moment',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Browse All Jobs',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, RouteNames.jobSearch);
              },
              width: 180,
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
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Failed to load jobs',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Try Again',
              onPressed: _loadCompanyData,
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}