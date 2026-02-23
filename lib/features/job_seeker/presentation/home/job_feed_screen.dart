import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/features/job_seeker/provider/job_provider.dart';
import 'package:job_portal_app/models/category.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/job_search_filter.dart';
import 'package:job_portal_app/routes/route_names.dart';

// features/job_seeker/presentation/home/job_feed_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:provider/provider.dart';

class JobFeedScreen extends StatefulWidget {
  const JobFeedScreen({super.key});

  @override
  State<JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> {
  // ===================== CONTROLLERS =====================
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  // ===================== FILTERS =====================
  String? _selectedCategory;
  JobType? _selectedJobType;
  String? _selectedLocation;
  bool _remoteOnly = false;
  RangeValues? _salaryRange;

  // Available filter options
  List<Category> _categories = [];
  List<String> _locations = [];

  // ===================== UI STATE =====================
  bool _showFilters = false;
  bool _isLoadingCategories = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupScrollListener();
    _setupSearchListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ===================== INITIALIZATION =====================
  Future<void> _initializeData() async {
    await _loadCategories();
    _loadJobs(refresh: true);
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      // You'll need to implement this API call
      // final categories = await CategoryApi.getAllCategories();
      // setState(() => _categories = categories);

      // For now, using mock data
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _categories = [
          Category(id: 1, name: 'Technology', jobCount: 45),
          Category(id: 2, name: 'Healthcare', jobCount: 23),
          Category(id: 3, name: 'Finance', jobCount: 31),
          Category(id: 4, name: 'Education', jobCount: 17),
          Category(id: 5, name: 'Retail', jobCount: 28),
          Category(id: 6, name: 'Hospitality', jobCount: 14),
        ];
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingCategories = false;
      });
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final jobProvider = Provider.of<JobProvider>(context, listen: false);
        if (!jobProvider.loading && jobProvider.hasMore) {
          _loadJobs();
        }
      }
    });
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _loadJobs(refresh: true);
      });
    });
  }

  // ===================== LOAD JOBS =====================
  Future<void> _loadJobs({bool refresh = false}) async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    final filter = JobSearchFilter(
      keyword: _searchController.text.isNotEmpty
          ? _searchController.text
          : null,
      categoryId: _selectedCategory != null
          ? int.tryParse(_selectedCategory!)
          : null,
      jobType: _selectedJobType,
      location: _selectedLocation,
      remote: _remoteOnly ? true : null,
      salaryRange: _salaryRange != null
          ? SalaryRange(min: _salaryRange!.start, max: _salaryRange!.end)
          : null,
    );

    await jobProvider.searchJobs(filter, refresh: refresh);
  }

  // ===================== FILTER METHODS =====================
  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedJobType = null;
      _selectedLocation = null;
      _remoteOnly = false;
      _salaryRange = null;
      _showFilters = false;
    });
    _loadJobs(refresh: true);
  }

  void _applyFilters() {
    setState(() => _showFilters = false);
    _loadJobs(refresh: true);
  }

  // ===================== NAVIGATION =====================
  void _navigateToJobDetails(int jobId) {
    Navigator.pushNamed(context, RouteNames.jobDetails, arguments: jobId);
  }

  // ===================== UTILITY METHODS =====================
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

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text(
          'Job Feed',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.chatList);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.notifications);
            },
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, child) {
          if (jobProvider.error != null && jobProvider.jobs.isEmpty) {
            return _buildErrorState(jobProvider.error!);
          }

          return Column(
            children: [
              // Search Bar
              _buildSearchBar(),

              // Filter Chips
              _buildFilterChips(),

              // Filter Panel (expandable)
              if (_showFilters) _buildFilterPanel(),

              // Job Count and Clear Filters
              _buildJobCountAndClear(jobProvider),

              // Job List
              Expanded(
                child: jobProvider.loading && jobProvider.jobs.isEmpty
                    ? _buildShimmerLoader()
                    : jobProvider.jobs.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => _loadJobs(refresh: true),
                        color: AppColors.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppSizes.md),
                          itemCount:
                              jobProvider.jobs.length +
                              (jobProvider.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= jobProvider.jobs.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return _buildJobCard(jobProvider.jobs[index]);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search jobs by title, company, or skills...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
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
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _showFilters ? AppColors.primary : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _toggleFilters,
              icon: Icon(
                Icons.tune,
                color: _showFilters ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Category Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButton<String>(
              value: _selectedCategory,
              hint: const Text('Category'),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Categories'),
                ),
                ..._categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id.toString(),
                    child: Text('${category.name} (${category.jobCount})'),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedCategory = value);
                _loadJobs(refresh: true);
              },
            ),
          ),
          const SizedBox(width: 8),

          // Job Type Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButton<JobType?>(
              value: _selectedJobType,
              hint: const Text('Job Type'),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Types')),
                ...JobType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_formatJobType(type)),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedJobType = value);
                _loadJobs(refresh: true);
              },
            ),
          ),
          const SizedBox(width: 8),

          // Location Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButton<String>(
              value: _selectedLocation,
              hint: const Text('Location'),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Locations'),
                ),
                // Add locations from your data
              ],
              onChanged: (value) {
                setState(() => _selectedLocation = value);
                _loadJobs(refresh: true);
              },
            ),
          ),
          const SizedBox(width: 8),

          // Remote Only Chip
          FilterChip(
            label: const Text('Remote Only'),
            selected: _remoteOnly,
            onSelected: (selected) {
              setState(() => _remoteOnly = selected);
              _loadJobs(refresh: true);
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: AppColors.primary.withOpacity(0.2),
            checkmarkColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Salary Range',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _salaryRange ?? const RangeValues(0, 200000),
            min: 0,
            max: 200000,
            divisions: 20,
            labels: RangeLabels(
              '\$${_formatNumber(_salaryRange?.start ?? 0)}',
              '\$${_formatNumber(_salaryRange?.end ?? 200000)}',
            ),
            onChanged: (values) {
              setState(() => _salaryRange = values);
            },
            activeColor: AppColors.primary,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobCountAndClear(JobProvider provider) {
    if (provider.jobs.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: Row(
        children: [
          Text(
            '${provider.jobs.length} jobs found',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (_searchController.text.isNotEmpty ||
              _selectedCategory != null ||
              _selectedJobType != null ||
              _selectedLocation != null ||
              _remoteOnly)
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

  Widget _buildJobCard(Job job) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToJobDetails(job.id),
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
                              errorBuilder: (_, __, ___) => _buildDefaultLogo(),
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

                  // Job Type Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getJobTypeIcon(job.jobType),
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Location and Salary
              Row(
                children: [
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
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatSalary(job),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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
                      child: Text(skill, style: const TextStyle(fontSize: 11)),
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

              const SizedBox(height: 16),

              // Footer with Posted Date and Apply Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatPostedDate(job.postedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _navigateToJobDetails(job.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Apply Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildDefaultLogo() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(
        Icons.business,
        size: 28,
        color: AppColors.primary.withOpacity(0.5),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 150,
                            height: 12,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 12,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 8),
                Container(width: 200, height: 12, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 12,
                      color: Colors.grey.shade300,
                    ),
                    Container(
                      width: 80,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
              Icons.work_off_outlined,
              size: 80,
              color: AppColors.textDisabled.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Jobs Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search filters',
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Try Again',
              onPressed: () => _loadJobs(refresh: true),
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}
