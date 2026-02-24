
import 'package:flutter/material.dart';


// manage_employer_jobs_screen.dart

import 'package:intl/intl.dart';
import 'package:job_portal_app/features/job_seeker/provider/job_provider.dart';
import 'package:job_portal_app/models/job_model.dart';

import 'package:provider/provider.dart';

class ManageEmployerJobsScreen extends StatefulWidget {
  const ManageEmployerJobsScreen({super.key});

  @override
  State<ManageEmployerJobsScreen> createState() => _ManageEmployerJobsScreenState();
}

class _ManageEmployerJobsScreenState extends State<ManageEmployerJobsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Closed', 'Draft'];
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreJobs();
    }
  }

  Future<void> _loadJobs() async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    await jobProvider.loadJobs(refresh: true);
  }

  Future<void> _loadMoreJobs() async {
    if (_isLoadingMore) return;
    
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    if (jobProvider.hasMore) {
      setState(() => _isLoadingMore = true);
      await jobProvider.loadJobs();
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refreshJobs() async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    await jobProvider.loadJobs(refresh: true);
  }

  void _filterJobs(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    // Apply filter logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          
          // Filter Chips
          _buildFilterChips(),
          
          // Jobs List
          Expanded(
            child: _buildJobsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create job screen
        },
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search jobs...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF64748B), size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _refreshJobs();
                          },
                        )
                      : null,
                ),
                onSubmitted: (value) {
                  // Implement search
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: () {
                // Show filter options
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) => _filterJobs(filter),
                backgroundColor: Colors.grey[100],
                selectedColor: const Color(0xFF3B82F6),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildJobsList() {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        if (jobProvider.loading && jobProvider.jobs.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
          );
        }

        if (jobProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
                const SizedBox(height: 16),
                Text(
                  jobProvider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFEF4444)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshJobs,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (jobProvider.jobs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_off, size: 64, color: Color(0xFF94A3B8)),
                SizedBox(height: 16),
                Text(
                  'No jobs found',
                  style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: jobProvider.jobs.length + (jobProvider.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == jobProvider.jobs.length) {
              return _buildLoadingIndicator();
            }
            return _buildJobCard(jobProvider.jobs[index]);
          },
        );
      },
    );
  }

  Widget _buildJobCard(Job job) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final statusColor = _getStatusColor(job.status);
    
    return Container(
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
      child: InkWell(
        onTap: () {
          // Navigate to job details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
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
                                color: Color(0xFF3B82F6),
                                size: 24,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.business,
                            color: Color(0xFF3B82F6),
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Job Info
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
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                job.location,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job.status.name,
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Job Details Row
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.work_outline,
                    label: job.jobType.name.replaceAll('_', ' ').toLowerCase(),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.trending_up,
                    label: job.experienceLevel.name.toLowerCase(),
                  ),
                  const SizedBox(width: 8),
                  if (job.minSalary != null)
                    _buildInfoChip(
                      icon: Icons.attach_money,
                      label: _formatSalary(job.minSalary, job.maxSalary, job.salaryType),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Posted Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Posted ${dateFormat.format(job.postedAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  // Stats
                  Row(
                    children: [
                      if (job.viewsCount != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.visibility,
                                size: 14,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${job.viewsCount}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (job.applicantsCount != null)
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${job.applicantsCount}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
        ),
      ),
    );
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.ACTIVE:
        return const Color(0xFF10B981);
      case JobStatus.CLOSED:
        return const Color(0xFFEF4444);
      case JobStatus.DRAFT:
        return const Color(0xFFF59E0B);
    }
  }

  String _formatSalary(double? min, double? max, SalaryType type) {
    if (min == null && max == null) return 'Not specified';
    if (min != null && max != null) {
      return '${min.toStringAsFixed(0)}-${max.toStringAsFixed(0)}';
    }
    if (min != null) return 'From ${min.toStringAsFixed(0)}';
    return 'Up to ${max!.toStringAsFixed(0)}';
  }
}