// admin_shell.dart
import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/features/admin/presentation/admin_dashboard.dart';
import 'package:job_portal_app/features/admin/presentation/admin_screens.dart';
import 'package:job_portal_app/features/admin/presentation/analytics_screen.dart';
import 'package:job_portal_app/features/admin/presentation/categories_screen.dart';
import 'package:job_portal_app/features/admin/presentation/manage_employer_jobs_screen.dart';
import 'package:job_portal_app/features/admin/presentation/manage_employers_screen.dart';
import 'package:job_portal_app/features/admin/presentation/manage_users_screen.dart';
import 'package:job_portal_app/features/admin/presentation/push_notifications_screen.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:provider/provider.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  final List<AdminNavItem> _navItems = [
    AdminNavItem(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      route: RouteNames.adminDashboard,
    ),
    AdminNavItem(
      title: 'Manage Users',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      route: RouteNames.manageUsers,
    ),
    AdminNavItem(
      title: 'Manage Employers',
      icon: Icons.business_outlined,
      selectedIcon: Icons.business,
      route: RouteNames.manageEmployers,
    ),
    AdminNavItem(
      title: 'Manage Jobs',
      icon: Icons.work_outline,
      selectedIcon: Icons.work,
      route: RouteNames.manageEmployerJobs,
    ),
    AdminNavItem(
      title: 'Approve Jobs',
      icon: Icons.check_circle_outline,
      selectedIcon: Icons.check_circle,
      route: RouteNames.approveJobs,
      badge: '5', // Example: pending approvals
    ),
    AdminNavItem(
      title: 'Categories',
      icon: Icons.category_outlined,
      selectedIcon: Icons.category,
      route: RouteNames.categories,
    ),
    AdminNavItem(
      title: 'Skills',
      icon: Icons.psychology_outlined,
      selectedIcon: Icons.psychology,
      route: RouteNames.adminSkills,
    ),
    AdminNavItem(
      title: 'Analytics',
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      route: RouteNames.analytics,
    ),
    AdminNavItem(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications,
      route: RouteNames.pushNotifications,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushReplacementNamed(context, _navItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _navItems[_selectedIndex].title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF1E293B)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          // Notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF1E293B),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.pushNotifications);
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          // Profile
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF3B82F6),
              backgroundImage: user?.profilePictureUrl != null
                  ? NetworkImage(
                      AppConstants.getImageUrl(user!.profilePictureUrl),
                    )
                  : null,
              child: user?.profilePictureUrl == null
                  ? Text(
                      user?.fullName[0].toUpperCase() ?? 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            onPressed: () {
              // Navigate to admin profile
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: user?.profilePictureUrl != null
                          ? NetworkImage(
                              AppConstants.getImageUrl(user!.profilePictureUrl),
                            )
                          : null,
                      child: user?.profilePictureUrl == null
                          ? Text(
                              user?.fullName[0].toUpperCase() ?? 'A',
                              style: const TextStyle(
                                color: Color(0xFF3B82F6),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.fullName ?? 'Admin User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'admin@example.com',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Administrator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _navItems.length,
                  itemBuilder: (context, index) {
                    final item = _navItems[index];
                    final isSelected = _selectedIndex == index;

                    return Column(
                      children: [
                        if (index == 4) // After Approve Jobs
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Color(0xFFE2E8F0)),
                          ),
                        ListTile(
                          leading: Icon(
                            isSelected ? item.selectedIcon : item.icon,
                            color: isSelected
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF64748B),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF1E293B),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: item.badge != null
                              ? Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Text(
                                    item.badge!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : null,
                          selected: isSelected,
                          selectedTileColor: const Color(0xFFEFF6FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _onItemTapped(index);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.settings_outlined,
                        color: Color(0xFF64748B),
                      ),
                      title: const Text(
                        'Settings',
                        style: TextStyle(color: Color(0xFF1E293B)),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to admin settings
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.help_outline,
                        color: Color(0xFF64748B),
                      ),
                      title: const Text(
                        'Help & Support',
                        style: TextStyle(color: Color(0xFF1E293B)),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to help
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                'Are you sure you want to logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF4444),
                                  ),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );

                          if (shouldLogout == true) {
                            await auth.logout();
                            if (mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                RouteNames.login,
                                (route) => false,
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Navigator(
        initialRoute: RouteNames.adminDashboard,
        onGenerateRoute: (settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case RouteNames.adminDashboard:
              builder = (context) => const AdminDashboardScreen();
              break;
            case RouteNames.manageUsers:
              builder = (context) => const ManageUsersScreen();
              break;
            case RouteNames.manageEmployers:
              builder = (context) => const ManageEmployersScreen();
              break;
            case RouteNames.manageEmployerJobs:
              builder = (context) => const ManageEmployerJobsScreen();
              break;
            case RouteNames.approveJobs:
              builder = (context) => const ApproveJobsScreen();
              break;
            case RouteNames.categories:
              builder = (context) => const CategoriesScreen();
              break;
            case RouteNames.adminSkills:
              builder = (context) => const AdminSkillsScreen();
              break;
            case RouteNames.analytics:
              builder = (context) => const AnalyticsScreen();
              break;
            case RouteNames.pushNotifications:
              builder = (context) => const PushNotificationsScreen();
              break;
            default:
              builder = (context) => const AdminDashboardScreen();
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
      ),
    );
  }
}

class AdminNavItem {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  final String? badge;

  AdminNavItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.route,
    this.badge,
  });
}
