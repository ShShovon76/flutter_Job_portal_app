import 'package:flutter/material.dart';

import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_strings.dart';
import 'package:job_portal_app/features/job_seeker/presentation/home/job_feed_screen.dart';
import 'package:job_portal_app/features/job_seeker/presentation/job/saved_jobs_screen.dart';
import 'package:job_portal_app/features/job_seeker/presentation/profile/profile_screen.dart';
import 'package:job_portal_app/features/job_seeker/presentation/search/job_search_screen.dart';
import 'package:job_portal_app/features/job_seeker/presentation/tracking/applied_jobs_screen.dart';

class JobSeekerShell extends StatefulWidget {
  const JobSeekerShell({super.key});

  @override
  State<JobSeekerShell> createState() => _JobSeekerShellState();
}

class _JobSeekerShellState extends State<JobSeekerShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const JobFeedScreen(),
    const JobSearchScreen(),
    const AppliedJobsScreen(),
    const SavedJobsScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: AppStrings.home,
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.search_outlined),
      activeIcon: Icon(Icons.search),
      label: AppStrings.search,
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.description_outlined),
      activeIcon: Icon(Icons.description),
      label: AppStrings.applications,
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.bookmark_border),
      activeIcon: Icon(Icons.bookmark),
      label: AppStrings.saved,
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: AppStrings.profile,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: _bottomNavItems,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          backgroundColor: AppColors.surface,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
