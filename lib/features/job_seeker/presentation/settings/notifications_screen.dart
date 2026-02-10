import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool jobAlerts = true;
  bool applicationUpdates = true;
  bool interviewReminders = true;
  bool newJobMatches = true;
  bool companyUpdates = false;
  bool marketingEmails = false;
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool smsNotifications = false;

  final List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'title': 'New Job Match',
      'description': 'Senior Flutter Developer at TechCorp matches your profile',
      'time': '2 hours ago',
      'read': false,
      'type': 'job_match',
    },
    {
      'id': '2',
      'title': 'Application Updated',
      'description': 'Your application for UI/UX Designer is now under review',
      'time': '1 day ago',
      'read': true,
      'type': 'application',
    },
    {
      'id': '3',
      'title': 'Interview Scheduled',
      'description': 'Interview scheduled for Product Manager position tomorrow at 2 PM',
      'time': '2 days ago',
      'read': true,
      'type': 'interview',
    },
    {
      'id': '4',
      'title': 'New Feature',
      'description': 'Check out our new AI-powered resume builder',
      'time': '1 week ago',
      'read': true,
      'type': 'feature',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // All Notifications
            _buildNotificationsList(),
            // Notification Settings
            _buildSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    final unreadCount = notifications.where((n) => !n['read']).length;

    return Column(
      children: [
        if (unreadCount > 0)
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            color: AppColors.primary.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$unreadCount unread notifications',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: _markAllAsRead,
                  child: const Text('Mark all as read'),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(notification);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      color: !notification['read'] ? AppColors.primary.withOpacity(0.05) : null,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getNotificationColor(notification['type']),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            _getNotificationIcon(notification['type']),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: !notification['read'] ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['description']),
            const SizedBox(height: 4),
            Text(
              notification['time'],
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: !notification['read']
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          setState(() {
            notification['read'] = true;
          });
        },
      ),
    );
  }

  Widget _buildSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification Channels
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Channels',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _buildSettingSwitch(
                    'Push Notifications',
                    'Receive push notifications on your device',
                    pushNotifications,
                    (value) => setState(() => pushNotifications = value),
                  ),
                  _buildSettingSwitch(
                    'Email Notifications',
                    'Receive notifications via email',
                    emailNotifications,
                    (value) => setState(() => emailNotifications = value),
                  ),
                  _buildSettingSwitch(
                    'SMS Notifications',
                    'Receive notifications via SMS',
                    smsNotifications,
                    (value) => setState(() => smsNotifications = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          // Notification Types
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Types',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _buildSettingSwitch(
                    'Job Alerts',
                    'New jobs that match your profile',
                    jobAlerts,
                    (value) => setState(() => jobAlerts = value),
                  ),
                  _buildSettingSwitch(
                    'Application Updates',
                    'Updates on your job applications',
                    applicationUpdates,
                    (value) => setState(() => applicationUpdates = value),
                  ),
                  _buildSettingSwitch(
                    'Interview Reminders',
                    'Reminders for scheduled interviews',
                    interviewReminders,
                    (value) => setState(() => interviewReminders = value),
                  ),
                  _buildSettingSwitch(
                    'New Job Matches',
                    'Daily/weekly job recommendations',
                    newJobMatches,
                    (value) => setState(() => newJobMatches = value),
                  ),
                  _buildSettingSwitch(
                    'Company Updates',
                    'Updates from companies you follow',
                    companyUpdates,
                    (value) => setState(() => companyUpdates = value),
                  ),
                  _buildSettingSwitch(
                    'Marketing Emails',
                    'Promotional emails and offers',
                    marketingEmails,
                    (value) => setState(() => marketingEmails = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          // Notification Schedule
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Schedule',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  const Text(
                    'Quiet Hours',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Text(
                    'No notifications between 10 PM - 8 AM',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  SwitchListTile(
                    title: const Text('Enable Quiet Hours'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    'Daily Digest',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Text(
                    'Receive a summary of notifications once a day',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  SwitchListTile(
                    title: const Text('Enable Daily Digest'),
                    value: true,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          // Clear All Button
          Center(
            child: OutlinedButton(
              onPressed: _clearAllNotifications,
              child: const Text('Clear All Notifications'),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'job_match':
        return AppColors.primary;
      case 'application':
        return AppColors.info;
      case 'interview':
        return AppColors.warning;
      case 'feature':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'job_match':
        return Icons.work;
      case 'application':
        return Icons.description;
      case 'interview':
        return Icons.calendar_today;
      case 'feature':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['read'] = true;
      }
    });
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear notifications
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}