import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/routes/route_names.dart';

class EmployerDashboardScreen extends StatelessWidget {
  const EmployerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Dashboard'),
        automaticallyImplyLeading: false,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, TechCorp!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textInverse,
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            'Manage your hiring process efficiently',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textInverse.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.lg),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.business,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Stats Section
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppSizes.md,
                mainAxisSpacing: AppSizes.md,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    'Active Jobs',
                    '12',
                    Icons.work_outline,
                    AppColors.primary,
                  ),
                  _buildStatCard(
                    'Applications',
                    '45',
                    Icons.description_outlined,
                    AppColors.secondary,
                  ),
                  _buildStatCard(
                    'Interviews',
                    '8',
                    Icons.calendar_today_outlined,
                    AppColors.success,
                  ),
                  _buildStatCard(
                    'Hired',
                    '3',
                    Icons.verified_outlined,
                    AppColors.warning,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Post New Job',
                      Icons.add_circle_outline,
                      () {
                        Navigator.pushNamed(context, RouteNames.postJob);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: _buildActionButton(
                      'View Applicants',
                      Icons.people_outline,
                      () {
                        Navigator.pushNamed(context, RouteNames.applicantsList);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Analytics',
                      Icons.analytics_outlined,
                      () {
                        // Navigate to analytics
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: _buildActionButton(
                      'Company Profile',
                      Icons.business_outlined,
                      () {
                        Navigator.pushNamed(context, RouteNames.companyProfile);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),
              // Recent Applications
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Applications',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RouteNames.applicantsList);
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              // Recent Applications List
              ..._buildRecentApplications(),
              const SizedBox(height: AppSizes.xl),
              // Active Jobs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Jobs',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RouteNames.jobList);
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // pushes title to bottom
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: AppSizes.md),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppColors.primary),
              const SizedBox(height: AppSizes.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRecentApplications() {
    final applications = [
      {
        'name': 'John Smith',
        'position': 'Flutter Developer',
        'status': 'New',
        'time': '2h ago',
      },
      {
        'name': 'Sarah Johnson',
        'position': 'UI/UX Designer',
        'status': 'Reviewed',
        'time': '1d ago',
      },
      {
        'name': 'Mike Wilson',
        'position': 'Backend Developer',
        'status': 'Interview',
        'time': '2d ago',
      },
    ];

    return applications.map((app) {
      return Card(
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              app['name']!.substring(0, 1),
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
          title: Text(
            app['name']!,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(app['position']!),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(app['status']!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXs),
                ),
                child: Text(
                  app['status']!,
                  style: TextStyle(
                    fontSize: 10,
                    color: _getStatusColor(app['status']!),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                app['time']!,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return AppColors.primary;
      case 'reviewed':
        return AppColors.info;
      case 'interview':
        return AppColors.warning;
      case 'hired':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
