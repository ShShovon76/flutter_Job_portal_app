// admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/features/auth/provider/analytics_provider.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/features/auth/provider/category_provider.dart';
import 'package:job_portal_app/features/auth/provider/user_provider.dart';
import 'package:job_portal_app/features/employer/presentation/company/provider/company_provider.dart';
import 'package:job_portal_app/features/job_seeker/provider/job_provider.dart';
import 'package:job_portal_app/models/analytics_models.dart';
import 'package:job_portal_app/models/company_model.dart';
import 'package:job_portal_app/models/user_model.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  // Selected time range for metrics
  String _selectedTimeRange = 'week';
  final List<String> _timeRanges = ['day', 'week', 'month', 'year'];

  @override
  void initState() {
    super.initState();
    // Defer loading until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final analyticsProvider = Provider.of<AnalyticsProvider>(
        context,
        listen: false,
      );

      await analyticsProvider.fetchSiteMetrics();

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      final companyProvider = Provider.of<CompanyProvider>(
        context,
        listen: false,
      );
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );

      await Future.wait([
        userProvider.loadUsers(page: 0, size: 5),
        jobProvider.loadJobs(refresh: true),
        companyProvider.loadCompanies(refresh: true),
        categoryProvider.loadTopCategories(),
      ]);

      if (!mounted) return; // 🔥 IMPORTANT

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // 🔥 IMPORTANT

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load dashboard: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: const Color(0xFF3B82F6),
        child: _isLoading
            ? _buildLoadingView()
            : _errorMessage != null
            ? _buildErrorView()
            : _buildDashboardContent(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading dashboard...',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFEF4444)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    final analyticsProvider = Provider.of<AnalyticsProvider>(context);
    final metrics = analyticsProvider.siteMetrics;

    if (metrics == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header with Admin Info
          _buildWelcomeHeader(),

          const SizedBox(height: 24),

          // Time Range Selector
          _buildTimeRangeSelector(),

          const SizedBox(height: 24),

          // Key Metrics Cards
          _buildKeyMetricsGrid(metrics),

          const SizedBox(height: 24),

          // Charts Row
          _buildChartsSection(metrics),

          const SizedBox(height: 24),

          // Bottom Section with Recent Data and Quick Actions
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);

    String greeting;
    if (now.hour < 12) {
      greeting = 'Good Morning';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.fullName ?? 'Admin',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            formattedDate,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildQuickStatChip(
                icon: Icons.people,
                label: 'Total Users',
                value: _formatNumber(_getTotalUsers()),
              ),
              const SizedBox(width: 12),
              _buildQuickStatChip(
                icon: Icons.work,
                label: 'Active Jobs',
                value: _formatNumber(_getActiveJobs()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          final isSelected = _selectedTimeRange == range;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTimeRange = range;
              });
              // Here you would reload data with new time range
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                range[0].toUpperCase() + range.substring(1),
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyMetricsGrid(SiteMetricsResponse metrics) {
    return Column(
      children: [
        _buildMetricCard(
          title: 'Total Users',
          value: metrics.totalUsers,
          icon: Icons.people,
          color: const Color(0xFF3B82F6),
          change: metrics.newUsersToday,
          changeLabel: 'new today',
          onTap: () => Navigator.pushNamed(context, RouteNames.manageUsers),
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          title: 'Active Jobs',
          value: metrics.activeJobs,
          icon: Icons.work,
          color: const Color(0xFF10B981),
          change: metrics.jobsPostedToday,
          changeLabel: 'posted today',
          onTap: () =>
              Navigator.pushNamed(context, RouteNames.manageEmployerJobs),
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          title: 'Companies',
          value: metrics.totalCompanies,
          icon: Icons.business,
          color: const Color(0xFFF59E0B),
          change: metrics.verifiedCompanies,
          changeLabel: 'verified',
          onTap: () => Navigator.pushNamed(context, RouteNames.manageEmployers),
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          title: 'Applications',
          value: metrics.totalApplications,
          icon: Icons.description,
          color: const Color(0xFFEF4444),
          change: metrics.applicationsToday,
          changeLabel: 'today',
          onTap: () => Navigator.pushNamed(context, RouteNames.analytics),
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          title: 'New Users',
          value: metrics.newUsersThisMonth,
          icon: Icons.person_add,
          color: const Color(0xFF8B5CF6),
          change: metrics.newUsersToday,
          changeLabel: 'today',
          onTap: () => Navigator.pushNamed(context, RouteNames.manageUsers),
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          title: 'Jobs Posted',
          value: metrics.jobsPostedThisWeek,
          icon: Icons.post_add,
          color: const Color(0xFFEC4899),
          change: metrics.jobsPostedToday,
          changeLabel: 'today',
          onTap: () =>
              Navigator.pushNamed(context, RouteNames.manageEmployerJobs),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required int change,
    required String changeLabel,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                if (change > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_upward,
                          color: Color(0xFF10B981),
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '+$change',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            Text(
              '$change $changeLabel',
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(SiteMetricsResponse metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Platform Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),

        // Users by Role Pie Chart
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Users by Role',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: _buildUsersByRoleChart(metrics.usersByRole),
              ),
              const SizedBox(height: 12),
              _buildChartLegend(metrics.usersByRole),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Popular Categories Bar Chart
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jobs by Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: _buildCategoryChart(metrics.popularCategories),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsersByRoleChart(Map<String, int> usersByRole) {
    if (usersByRole.isEmpty) {
      return const Center(
        child: Text(
          'No user data available',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }

    final totalUsers = usersByRole.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );

    final List<PieChartSectionData> sections = [];
    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Orange
      const Color(0xFF8B5CF6), // Purple
    ];

    int index = 0;
    usersByRole.forEach((role, count) {
      final percentage = (count / totalUsers * 100);
      sections.add(
        PieChartSectionData(
          value: count.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 45,
          color: colors[index % colors.length],
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
        ),
      ),
    );
  }

  Widget _buildCategoryChart(List<JobCategoryStats> categories) {
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'No category data available',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }

    // Take top 5 categories
    final topCategories = categories.take(5).toList();
    final maxCount = topCategories
        .map((e) => e.jobCount)
        .reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxCount.toDouble() * 1.1,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < topCategories.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _truncateString(
                        topCategories[value.toInt()].categoryName,
                        6,
                      ),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('');
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                );
              },
              reservedSize: 28,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: maxCount / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: const Color(0xFFE2E8F0), strokeWidth: 1);
          },
        ),
        barGroups: List.generate(
          topCategories.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: topCategories[index].jobCount.toDouble(),
                color: const Color(0xFF3B82F6),
                width: 22,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartLegend(Map<String, int> usersByRole) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: usersByRole.length,
        itemBuilder: (context, index) {
          final role = usersByRole.keys.elementAt(index);
          final count = usersByRole.values.elementAt(index);
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$role ($count)',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Users
        _buildRecentUsersCard(),

        const SizedBox(height: 16),

        // Recent Companies
        _buildRecentCompaniesCard(),

        const SizedBox(height: 16),

        // Quick Actions
        _buildQuickActionsCard(),

        const SizedBox(height: 16),

        // Pending Items
        _buildPendingItemsCard(),
      ],
    );
  }

  Widget _buildRecentUsersCard() {
    final userProvider = Provider.of<UserProvider>(context);
    final users = userProvider.usersPage?.items ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                'Recent Users',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, RouteNames.manageUsers),
                child: const Text('View All →'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...users.take(3).map((user) => _buildUserTile(user)),
          if (users.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No users found',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserTile(User user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            backgroundImage: user.profilePictureUrl != null
                ? NetworkImage(AppConstants.getImageUrl(user.profilePictureUrl))
                : null,
            child: user.profilePictureUrl == null
                ? Text(
                    user.fullName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.role?.value ?? 'USER',
              style: TextStyle(
                fontSize: 10,
                color: _getRoleColor(user.role),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCompaniesCard() {
    final companyProvider = Provider.of<CompanyProvider>(context);
    final companies = companyProvider.companies.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                'Recent Companies',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, RouteNames.manageEmployers),
                child: const Text('View All →'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...companies.map((company) => _buildCompanyTile(company)),
          if (companies.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No companies found',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompanyTile(Company company) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: company.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      AppConstants.getImageUrl(company.logoUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.business,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.business,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  company.industry,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (company.verified == true)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                color: Color(0xFF10B981),
                size: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionButton(
            icon: Icons.check_circle,
            label: 'Approve Pending Jobs',
            color: const Color(0xFF10B981),
            onTap: () => Navigator.pushNamed(context, RouteNames.approveJobs),
          ),
          const SizedBox(height: 8),
          _buildQuickActionButton(
            icon: Icons.category,
            label: 'Manage Categories',
            color: const Color(0xFF8B5CF6),
            onTap: () => Navigator.pushNamed(context, RouteNames.categories),
          ),
          const SizedBox(height: 8),
          _buildQuickActionButton(
            icon: Icons.psychology,
            label: 'Manage Skills',
            color: const Color(0xFFF59E0B),
            onTap: () => Navigator.pushNamed(context, RouteNames.adminSkills),
          ),
          const SizedBox(height: 8),
          _buildQuickActionButton(
            icon: Icons.notifications,
            label: 'Send Notification',
            color: const Color(0xFF3B82F6),
            onTap: () =>
                Navigator.pushNamed(context, RouteNames.pushNotifications),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingItemsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pending Items',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildPendingItem(
            label: 'Job Approvals',
            count: 5, // You would get this from your API
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 12),
          _buildPendingItem(
            label: 'Company Verifications',
            count: 3,
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 12),
          _buildPendingItem(
            label: 'Reported Content',
            count: 2,
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingItem({
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _truncateString(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  int _getTotalUsers() {
    final metrics = Provider.of<AnalyticsProvider>(context).siteMetrics;
    return metrics?.totalUsers ?? 0;
  }

  int _getActiveJobs() {
    final metrics = Provider.of<AnalyticsProvider>(context).siteMetrics;
    return metrics?.activeJobs ?? 0;
  }

  Color _getRoleColor(UserRole? role) {
    switch (role) {
      case UserRole.ADMIN:
        return const Color(0xFFEF4444);
      case UserRole.EMPLOYER:
        return const Color(0xFFF59E0B);
      case UserRole.JOB_SEEKER:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }
}
