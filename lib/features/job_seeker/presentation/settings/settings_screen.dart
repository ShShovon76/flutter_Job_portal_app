import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;
  bool autoApply = true;
  bool privacyProfile = false;

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
                    'Account Settings',
                    'Manage your account information',
                    () {
                      Navigator.pushNamed(context, RouteNames.editProfile);
                    },
                  ),
                  _buildSettingItem(
                    Icons.notifications_outlined,
                    'Notifications',
                    'Configure notification preferences',
                    () {
                      Navigator.pushNamed(context, RouteNames.notifications);
                    },
                  ),
                  _buildSettingItem(
                    Icons.lock_outline,
                    'Privacy & Security',
                    'Manage your privacy settings',
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
          // Preferences
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(AppSizes.md),
                    child: Text(
                      'Preferences',
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
                  SwitchListTile(
                    title: const Text('Auto-Apply'),
                    subtitle: const Text('Automatically apply to saved jobs'),
                    value: autoApply,
                    onChanged: (value) {
                      setState(() => autoApply = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Private Profile'),
                    subtitle: const Text('Hide your profile from employers'),
                    value: privacyProfile,
                    onChanged: (value) {
                      setState(() => privacyProfile = value);
                    },
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
                    'Get help with the app',
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
                    'App version 1.0.0',
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
                  // Share app
                },
                icon: const Icon(Icons.share),
                label: const Text('Share App'),
              ),
              const SizedBox(height: AppSizes.md),
              OutlinedButton.icon(
                onPressed: () {
                  // Rate app
                },
                icon: const Icon(Icons.star_border),
                label: const Text('Rate App'),
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
                  'Job Portal v1.0.0',
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
}