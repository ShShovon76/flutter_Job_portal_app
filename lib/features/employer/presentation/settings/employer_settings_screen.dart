import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';

import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';

class EmployerSettingsScreen extends StatefulWidget {
  const EmployerSettingsScreen({super.key});

  @override
  State<EmployerSettingsScreen> createState() => _EmployerSettingsScreenState();
}

class _EmployerSettingsScreenState extends State<EmployerSettingsScreen> {
  bool darkMode = false;
  bool autoShortlist = true;
  bool emailNotifications = true;
  bool analyticsSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Account Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: Column(
                children: [
                  _buildSettingItem(
                    Icons.person_outline,
                    'Company Profile',
                    'Manage your company information',
                    () {
                      Navigator.pushNamed(context, RouteNames.companyProfile);
                    },
                  ),
                  _buildSettingItem(
                    Icons.notifications_outlined,
                    'Notifications',
                    'Configure notification preferences',
                    () {
                      Navigator.pushNamed(context, RouteNames.employerNotifications);
                    },
                  ),
                  _buildSettingItem(
                    Icons.subscriptions_outlined,
                    'Subscription',
                    'Manage your subscription plan',
                    () {
                      Navigator.pushNamed(context, RouteNames.subscription);
                    },
                  ),
                  _buildSettingItem(
                    Icons.payment_outlined,
                    'Billing & Payments',
                    'View invoices and payment methods',
                    () {},
                  ),
                  _buildSettingItem(
                    Icons.language_outlined,
                    'Language',
                    'English (US)',
                    () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          // Hiring Preferences
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(AppSizes.md),
                    child: Text(
                      'Hiring Preferences',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Auto-Shortlist Candidates'),
                    subtitle: const Text('Automatically shortlist candidates based on criteria'),
                    value: autoShortlist,
                    onChanged: (value) {
                      setState(() => autoShortlist = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive email updates for new applications'),
                    value: emailNotifications,
                    onChanged: (value) {
                      setState(() => emailNotifications = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Share Analytics'),
                    subtitle: const Text('Share anonymous data to improve platform'),
                    value: analyticsSharing,
                    onChanged: (value) {
                      setState(() => analyticsSharing = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          // Team Management
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(AppSizes.md),
                    child: Text(
                      'Team Management',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildSettingItem(
                    Icons.people_outline,
                    'Team Members',
                    '3 members',
                    () {},
                  ),
                  _buildSettingItem(
                    Icons.admin_panel_settings_outlined,
                    'Roles & Permissions',
                    'Manage team permissions',
                    () {},
                  ),
                  _buildSettingItem(
                    Icons.group_add_outlined,
                    'Invite Team Members',
                    'Add new members to your team',
                    () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          // Appearance
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(AppSizes.md),
                    child: Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Switch to dark theme'),
                    value: darkMode,
                    onChanged: (value) {
                      setState(() => darkMode = value);
                    },
                  ),
                  _buildSettingItem(
                    Icons.palette_outlined,
                    'Theme',
                    'Default theme',
                    () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          // Support
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: Column(
                children: [
                  _buildSettingItem(
                    Icons.help_outline,
                    'Help & Support',
                    'Get help with the platform',
                    () {},
                  ),
                  _buildSettingItem(
                    Icons.description_outlined,
                    'Terms & Conditions',
                    'View our terms of service',
                    () {},
                  ),
                  _buildSettingItem(
                    Icons.security_outlined,
                    'Privacy Policy',
                    'Learn about our privacy practices',
                    () {},
                  ),
                  _buildSettingItem(
                    Icons.info_outline,
                    'About',
                    'Platform version 1.0.0',
                    () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          // Actions
          Column(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // Export data
                },
                icon: const Icon(Icons.download),
                label: const Text('Export Data'),
              ),
              const SizedBox(height: AppSizes.md),
              OutlinedButton.icon(
                onPressed: () {
                  // Clear cache
                  _showClearCacheDialog();
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear Cache'),
              ),
              const SizedBox(height: AppSizes.md),
              OutlinedButton.icon(
                onPressed: () {
                  // Deactivate account
                  _showDeactivateDialog();
                },
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('Deactivate Account'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          // Logout Button
          PrimaryButton(
            text: 'Logout',
            onPressed: () {
              _showLogoutDialog();
            },
            backgroundColor: AppColors.error,
          ),
          const SizedBox(height: AppSizes.xl),
          // App Info
          Center(
            child: Column(
              children: [
                Text(
                  'Job Portal for Employers v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  '© 2024 Job Portal Inc.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, RouteNames.login);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear cache
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text(
          'This will deactivate your employer account. All your job postings and candidate data will be archived. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Deactivate account
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deactivation request sent'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text(
              'Deactivate',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}