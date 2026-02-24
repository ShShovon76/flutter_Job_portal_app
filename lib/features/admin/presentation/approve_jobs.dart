

// approve_jobs_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/features/job_seeker/provider/job_provider.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:provider/provider.dart';

class ApproveJobsScreen extends StatefulWidget {
  const ApproveJobsScreen({super.key});

  @override
  State<ApproveJobsScreen> createState() => _ApproveJobsScreenState();
}

class _ApproveJobsScreenState extends State<ApproveJobsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Pending';
  final List<String> _filters = ['Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadPendingJobs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingJobs() async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    // You'll need to add a method to fetch pending jobs
    await jobProvider.loadJobs(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Stats Header
          _buildStatsHeader(),
          
          // Filter Tabs
          _buildFilterTabs(),
          
          // Search Bar
          _buildSearchBar(),
          
          // Jobs List
          Expanded(
            child: _buildJobsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Approvals',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                label: 'Pending',
                value: '5',
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                label: 'Approved',
                value: '12',
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                label: 'Rejected',
                value: '2',
                color: const Color(0xFFEF4444),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
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
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search jobs to approve...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF64748B), size: 18),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
          ),
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

        // Filter jobs based on selected filter
        final filteredJobs = jobProvider.jobs.where((job) {
          if (_selectedFilter == 'Pending') {
            return job.status == JobStatus.DRAFT;
          } else if (_selectedFilter == 'Approved') {
            return job.status == JobStatus.ACTIVE;
          } else {
            return job.status == JobStatus.CLOSED;
          }
        }).toList();

        if (filteredJobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedFilter == 'Pending' ? Icons.hourglass_empty : Icons.check_circle,
                  size: 64,
                  color: const Color(0xFF94A3B8),
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${_selectedFilter.toLowerCase()} jobs',
                  style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredJobs.length,
          itemBuilder: (context, index) {
            return _buildApprovalCard(filteredJobs[index]);
          },
        );
      },
    );
  }

  Widget _buildApprovalCard(Job job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        children: [
          // Job Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
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
                            job.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.company.name,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Employer Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                        child: Text(
                          job.employer.fullName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.employer.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Posted ${DateFormat('MMM d').format(job.postedAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Job Details
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDetailChip(
                      icon: Icons.work_outline,
                      label: job.jobType.name.replaceAll('_', ' '),
                    ),
                    _buildDetailChip(
                      icon: Icons.trending_up,
                      label: job.experienceLevel.name,
                    ),
                    _buildDetailChip(
                      icon: Icons.location_on,
                      label: job.location,
                    ),
                    if (job.minSalary != null)
                      _buildDetailChip(
                        icon: Icons.attach_money,
                        label: _formatSalary(job.minSalary, job.maxSalary),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showApproveDialog(job),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(job),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  Widget _buildDetailChip({
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

  void _showApproveDialog(Job job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Job'),
        content: Text('Are you sure you want to approve "${job.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement approve logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Job approved successfully'),
                  backgroundColor: Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Job job) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Job'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to reject "${job.title}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement reject logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Job rejected'),
                  backgroundColor: Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatSalary(double? min, double? max) {
    if (min == null && max == null) return 'Not specified';
    if (min != null && max != null) {
      return '${min.toStringAsFixed(0)}-${max.toStringAsFixed(0)}';
    }
    if (min != null) return 'From ${min.toStringAsFixed(0)}';
    return 'Up to ${max!.toStringAsFixed(0)}';
  }
}