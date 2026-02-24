import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';

class EmployerNotificationsScreen extends StatefulWidget {
  const EmployerNotificationsScreen({super.key});

  @override
  State<EmployerNotificationsScreen> createState() =>
      _EmployerNotificationsScreenState();
}

class _EmployerNotificationsScreenState
    extends State<EmployerNotificationsScreen> {
  bool jobAlerts = true;
  bool applicationUpdates = true;
  bool interviewReminders = true;
  bool candidateMessages = true;
  bool paymentReminders = true;
  bool systemUpdates = false;
  bool marketingEmails = false;
  bool pushNotifications = true;
  bool emailNotifications = true;

  final List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'title': 'New Application',
      'description': 'John Smith applied for Senior Flutter Developer',
      'time': '2 hours ago',
      'read': false,
      'type': 'application',
    },
    {
      'id': '2',
      'title': 'Interview Scheduled',
      'description': 'Interview with Sarah Johnson scheduled for tomorrow',
      'time': '1 day ago',
      'read': true,
      'type': 'interview',
    },
    {
      'id': '3',
      'title': 'Payment Receipt',
      'description': 'Receipt for your Pro Plan subscription',
      'time': '2 days ago',
      'read': true,
      'type': 'payment',
    },
    {
      'id': '4',
      'title': 'Job Expiring Soon',
      'description': 'UI/UX Designer position expiring in 3 days',
      'time': '3 days ago',
      'read': true,
      'type': 'job',
    },
    {
      'id': '5',
      'title': 'New Feature',
      'description': 'Try our new AI candidate matching',
      'time': '1 week ago',
      'read': true,
      'type': 'system',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => !n['read']).length;

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
            Column(
              children: [
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    color: AppColors.primary.withValues(alpha: 0.1),
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
            ),
            // Notification Settings
            SingleChildScrollView(
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
                            (value) =>
                                setState(() => pushNotifications = value),
                          ),
                          _buildSettingSwitch(
                            'Email Notifications',
                            'Receive notifications via email',
                            emailNotifications,
                            (value) =>
                                setState(() => emailNotifications = value),
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
                            'New Applications',
                            'When candidates apply to your jobs',
                            applicationUpdates,
                            (value) =>
                                setState(() => applicationUpdates = value),
                          ),
                          _buildSettingSwitch(
                            'Interview Reminders',
                            'Reminders for scheduled interviews',
                            interviewReminders,
                            (value) =>
                                setState(() => interviewReminders = value),
                          ),
                          _buildSettingSwitch(
                            'Candidate Messages',
                            'When candidates send you messages',
                            candidateMessages,
                            (value) =>
                                setState(() => candidateMessages = value),
                          ),
                          _buildSettingSwitch(
                            'Job Alerts',
                            'When your jobs are about to expire',
                            jobAlerts,
                            (value) => setState(() => jobAlerts = value),
                          ),
                          _buildSettingSwitch(
                            'Payment Reminders',
                            'Reminders for subscription payments',
                            paymentReminders,
                            (value) => setState(() => paymentReminders = value),
                          ),
                          _buildSettingSwitch(
                            'System Updates',
                            'Important updates about the platform',
                            systemUpdates,
                            (value) => setState(() => systemUpdates = value),
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
                  // Notification Frequency
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notification Frequency',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),
                          const Text(
                            'Application Digest',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          const Text(
                            'Receive a daily summary of new applications',
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
                          const SizedBox(height: AppSizes.md),
                          const Text(
                            'Quiet Hours',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          const Text(
                            'No notifications between 9 PM - 8 AM',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      color: !notification['read']
          ? AppColors.primary.withValues(alpha: 0.05)
          : null,
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
            fontWeight: !notification['read']
                ? FontWeight.w600
                : FontWeight.normal,
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
      case 'application':
        return AppColors.primary;
      case 'interview':
        return AppColors.warning;
      case 'payment':
        return AppColors.success;
      case 'job':
        return AppColors.info;
      case 'system':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'application':
        return Icons.description;
      case 'interview':
        return Icons.calendar_today;
      case 'payment':
        return Icons.payment;
      case 'job':
        return Icons.work;
      case 'system':
        return Icons.system_update;
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
        content: const Text(
          'Are you sure you want to clear all notifications?',
        ),
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
