// import 'package:flutter/material.dart';
// import 'package:job_portal_app/core/constants/app_colors.dart';
// import 'package:job_portal_app/core/constants/app_sizes.dart';
// import 'package:job_portal_app/routes/route_names.dart';

// class EmployerDashboardScreen extends StatelessWidget {
//   const EmployerDashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Employer Dashboard'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.pushNamed(context, RouteNames.employerNotifications);
//             },
//             icon: const Icon(Icons.notifications_outlined),
//           ),
//           IconButton(
//             onPressed: () {
//               Navigator.pushNamed(context, RouteNames.postJob);
//             },
//             icon: const Icon(Icons.add),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(AppSizes.md),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Welcome Section
//               Container(
//                 padding: const EdgeInsets.all(AppSizes.lg),
//                 decoration: BoxDecoration(
//                   gradient: AppColors.primaryGradient,
//                   borderRadius: BorderRadius.circular(AppSizes.cardRadius),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Welcome, TechCorp!',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.textInverse,
//                             ),
//                           ),
//                           const SizedBox(height: AppSizes.sm),
//                           Text(
//                             'Manage your hiring process efficiently',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: AppColors.textInverse.withValues(
//                                 alpha: 0.9,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: AppSizes.lg),
//                     Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withValues(alpha: 0.2),
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       child: const Icon(
//                         Icons.business,
//                         size: 32,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: AppSizes.xl),

//               // Stats Section
//               GridView.count(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 crossAxisCount: 2,
//                 crossAxisSpacing: AppSizes.md,
//                 mainAxisSpacing: AppSizes.md,
//                 childAspectRatio: 1.5,
//                 children: [
//                   _buildStatCard(
//                     'Active Jobs',
//                     '12',
//                     Icons.work_outline,
//                     AppColors.primary,
//                   ),
//                   _buildStatCard(
//                     'Applications',
//                     '45',
//                     Icons.description_outlined,
//                     AppColors.secondary,
//                   ),
//                   _buildStatCard(
//                     'Interviews',
//                     '8',
//                     Icons.calendar_today_outlined,
//                     AppColors.success,
//                   ),
//                   _buildStatCard(
//                     'Hired',
//                     '3',
//                     Icons.verified_outlined,
//                     AppColors.warning,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppSizes.xl),
//               // Quick Actions
//               Text(
//                 'Quick Actions',
//                 style: Theme.of(context).textTheme.headlineMedium,
//               ),
//               const SizedBox(height: AppSizes.md),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildActionButton(
//                       'Post New Job',
//                       Icons.add_circle_outline,
//                       () {
//                         Navigator.pushNamed(context, RouteNames.postJob);
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: AppSizes.md),
//                   Expanded(
//                     child: _buildActionButton(
//                       'View Applicants',
//                       Icons.people_outline,
//                       () {
//                         Navigator.pushNamed(context, RouteNames.applicantsList);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppSizes.md),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildActionButton(
//                       'Analytics',
//                       Icons.analytics_outlined,
//                       () {
//                         // Navigate to analytics
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: AppSizes.md),
//                   Expanded(
//                     child: _buildActionButton(
//                       'Company Profile',
//                       Icons.business_outlined,
//                       () {
//                         Navigator.pushNamed(context, RouteNames.companyProfile);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppSizes.xl),
//               // Recent Applications
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Recent Applications',
//                     style: Theme.of(context).textTheme.headlineMedium,
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, RouteNames.applicantsList);
//                     },
//                     child: const Text('View All'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppSizes.md),
//               // Recent Applications List
//               ..._buildRecentApplications(),
//               const SizedBox(height: AppSizes.xl),
//               // Active Jobs
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Active Jobs',
//                     style: Theme.of(context).textTheme.headlineMedium,
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, RouteNames.jobList);
//                     },
//                     child: const Text('View All'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(AppSizes.radiusSm),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(AppSizes.md),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment:
//               MainAxisAlignment.spaceBetween, // pushes title to bottom
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: color.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(AppSizes.radiusSm),
//                   ),
//                   child: Icon(icon, color: color),
//                 ),
//                 const SizedBox(width: AppSizes.md),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//               ],
//             ),
//             Text(
//               title,
//               style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
//     return Card(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(AppSizes.cardRadius),
//         child: Padding(
//           padding: const EdgeInsets.all(AppSizes.lg),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 32, color: AppColors.primary),
//               const SizedBox(height: AppSizes.sm),
//               Text(
//                 label,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildRecentApplications() {
//     final applications = [
//       {
//         'name': 'John Smith',
//         'position': 'Flutter Developer',
//         'status': 'New',
//         'time': '2h ago',
//       },
//       {
//         'name': 'Sarah Johnson',
//         'position': 'UI/UX Designer',
//         'status': 'Reviewed',
//         'time': '1d ago',
//       },
//       {
//         'name': 'Mike Wilson',
//         'position': 'Backend Developer',
//         'status': 'Interview',
//         'time': '2d ago',
//       },
//     ];

//     return applications.map((app) {
//       return Card(
//         margin: const EdgeInsets.only(bottom: AppSizes.md),
//         child: ListTile(
//           leading: CircleAvatar(
//             backgroundColor: AppColors.primary.withValues(alpha: 0.1),
//             child: Text(
//               app['name']!.substring(0, 1),
//               style: const TextStyle(color: AppColors.primary),
//             ),
//           ),
//           title: Text(
//             app['name']!,
//             style: const TextStyle(fontWeight: FontWeight.w500),
//           ),
//           subtitle: Text(app['position']!),
//           trailing: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: AppSizes.sm,
//                   vertical: 2,
//                 ),
//                 decoration: BoxDecoration(
//                   color: _getStatusColor(app['status']!).withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(AppSizes.radiusXs),
//                 ),
//                 child: Text(
//                   app['status']!,
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: _getStatusColor(app['status']!),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 app['time']!,
//                 style: const TextStyle(
//                   fontSize: 10,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }).toList();
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'new':
//         return AppColors.primary;
//       case 'reviewed':
//         return AppColors.info;
//       case 'interview':
//         return AppColors.warning;
//       case 'hired':
//         return AppColors.success;
//       case 'rejected':
//         return AppColors.error;
//       default:
//         return AppColors.textSecondary;
//     }
//   }
// }

// features/employer/presentation/dashboard/employer_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/api/analytics_api.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/features/employer/presentation/company/provider/company_provider.dart';
import 'package:job_portal_app/features/job_seeker/provider/job_provider.dart';
import 'package:job_portal_app/models/analytics_models.dart';
import 'package:job_portal_app/models/company_model.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';

class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});

  @override
  State<EmployerDashboardScreen> createState() =>
      _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  // ===================== STATE =====================
  EmployerDashboardResponse? _dashboard;
  Company? _company;
  List<Job> _recentJobs = [];
  bool _isLoading = true;
  String? _error;
  int _selectedTimeRange = 7; // days

  // ===================== TIME RANGE OPTIONS =====================
  final List<Map<String, dynamic>> _timeRanges = [
    {'label': '7d', 'value': 7},
    {'label': '30d', 'value': 30},
    {'label': '90d', 'value': 90},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  // ===================== DATA LOADING =====================
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final employerId = authProvider.user?.id;

      if (employerId == null) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      // Load dashboard data
      final dashboard = await AnalyticsApi.getEmployerDashboard(employerId);

      // Load company data
      final companyProvider = Provider.of<CompanyProvider>(
        // ignore: use_build_context_synchronously
        context,
        listen: false,
      );
      await companyProvider.loadMyCompany(employerId);

      // Load recent jobs
      // ignore: use_build_context_synchronously
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      await jobProvider.loadJobsByEmployer(
        employerId: employerId,
        refresh: true,
      );

      setState(() {
        _dashboard = dashboard;
        _company = companyProvider.myCompany;
        _recentJobs = jobProvider.jobs.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ===================== NAVIGATION =====================
  void _navigateToManageJobs() {
    Navigator.pushNamed(context, RouteNames.jobList);
  }

  void _navigateToPostJob() {
    Navigator.pushNamed(context, RouteNames.postJob);
  }

  void _navigateToCompanyProfile() {
    Navigator.pushNamed(context, RouteNames.companyProfile);
  }

  void _navigateToApplicants(int? jobId) {
    if (jobId != null) {
      Navigator.pushNamed(context, RouteNames.applicantsList, arguments: jobId);
    }
  }

  // ===================== UTILITY METHODS =====================
  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _getStatusLabel(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'APPLIED':
        return Colors.blue;
      case 'UNDER_REVIEW':
        return Colors.amber;
      case 'SHORTLISTED':
        return Colors.purple;
      case 'INTERVIEW':
        return Colors.green;
      case 'OFFERED':
        return Colors.teal;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatJobType(JobType type) {
    return type.name.replaceAll('_', ' ').toUpperCase();
  }

  String _formatDate(DateTime date) {
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

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Employer Dashboard'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.employerNotifications);
              },
              icon: const Icon(Icons.notifications_outlined),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.postJob);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        backgroundColor: Colors.grey[50],
        body: _error != null
            ? _buildErrorState()
            : _dashboard == null
            ? _buildEmptyState()
            : _buildDashboardContent(),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 120,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _company?.name ?? _dashboard!.companyName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                // Navigate to notifications
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadDashboardData,
            ),
          ],
        ),

        // Company Verification Status
        if (_company != null && !_company!.verified)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Company Not Verified',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Complete your company profile to get verified',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToCompanyProfile,
                    style: TextButton.styleFrom(foregroundColor: Colors.orange),
                    child: const Text('Complete'),
                  ),
                ],
              ),
            ),
          ),

        // Key Metrics
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildMetricCard(
                      title: 'Total Jobs',
                      value: _dashboard!.totalJobs,
                      icon: Icons.work_outline,
                      color: Colors.blue,
                    ),
                    _buildMetricCard(
                      title: 'Active Jobs',
                      value: _dashboard!.activeJobs,
                      icon: Icons.play_circle_outline,
                      color: Colors.green,
                    ),
                    _buildMetricCard(
                      title: 'Total Applications',
                      value: _dashboard!.totalApplications,
                      icon: Icons.description_outlined,
                      color: Colors.purple,
                    ),
                    _buildMetricCard(
                      title: 'Profile Views',
                      value: _dashboard!.profileViews,
                      icon: Icons.visibility_outlined,
                      color: Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Time Range Selector
                _buildTimeRangeSelector(),

                const SizedBox(height: 24),

                // Recent Applications Breakdown
                if (_dashboard!.recentApplicationsCount > 0)
                  _buildRecentApplicationsCard(),

                const SizedBox(height: 24),

                // Application Status Breakdown
                if (_dashboard!.applicationStatusBreakdown.isNotEmpty)
                  _buildStatusBreakdownCard(),

                const SizedBox(height: 24),

                // Top Viewed Jobs
                if (_dashboard!.topViewedJobs.isNotEmpty)
                  _buildTopViewedJobsCard(),

                const SizedBox(height: 24),

                // Recent Jobs
                if (_recentJobs.isNotEmpty) _buildRecentJobsCard(),

                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActionsCard(),

                const SizedBox(height: 24),

                // Subscription Status
                _buildSubscriptionCard(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatNumber(value),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _timeRanges.map((range) {
          final isSelected = _selectedTimeRange == range['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTimeRange = range['value']);
                // Reload data with new time range
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  range['label'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentApplicationsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Applications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${_dashboard!.recentApplicationsCount}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'You have received new applications recently',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _navigateToManageJobs,
              icon: const Icon(Icons.visibility),
              label: const Text('View All Applications'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdownCard() {
    final breakdown = _dashboard!.applicationStatusBreakdown;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Applications by Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          ...breakdown.entries.map((entry) {
            final color = _getStatusColor(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getStatusLabel(entry.key),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopViewedJobsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performing Jobs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          ..._dashboard!.topViewedJobs.take(3).map((job) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.jobTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${job.views} views',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.people_outline,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${job.applicants} applicants',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigateToApplicants(job.jobId),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('View', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentJobsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Jobs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: _navigateToManageJobs,
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._recentJobs.map((job) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.work_outline,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: job.status == JobStatus.ACTIVE
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                job.status.name,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: job.status == JobStatus.ACTIVE
                                      ? Colors.green
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.access_time,
                              size: 10,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _formatDate(job.postedAt),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _navigateToApplicants(job.id),
                    icon: const Icon(
                      Icons.people_outline,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Post Job',
                  color: Colors.blue,
                  onTap: _navigateToPostJob,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.list_alt_outlined,
                  label: 'Manage Jobs',
                  color: Colors.green,
                  onTap: _navigateToManageJobs,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.business_outlined,
                  label: 'Company Profile',
                  color: Colors.purple,
                  onTap: _navigateToCompanyProfile,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.analytics_outlined,
                  label: 'Analytics',
                  color: Colors.orange,
                  onTap: () {
                    // Navigate to detailed analytics
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _dashboard!.hasActiveSubscription
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.orange.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _dashboard!.hasActiveSubscription
                ? Icons.verified
                : Icons.warning_amber,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dashboard!.hasActiveSubscription
                      ? 'Active Subscription'
                      : 'No Active Subscription',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dashboard!.hasActiveSubscription
                      ? 'Your account is in good standing'
                      : 'Upgrade to post more jobs',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          if (!_dashboard!.hasActiveSubscription)
            TextButton(
              onPressed: () {
                // Navigate to subscription page
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              child: const Text('Upgrade'),
            ),
        ],
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
              _error ?? 'Failed to load dashboard',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Try Again',
              onPressed: _loadDashboardData,
              width: 150,
            ),
          ],
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
              Icons.dashboard_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Dashboard Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unable to load dashboard metrics',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Refresh',
              onPressed: _loadDashboardData,
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}
