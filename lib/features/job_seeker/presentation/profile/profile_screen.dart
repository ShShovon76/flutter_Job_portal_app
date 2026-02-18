import 'package:flutter/material.dart';
import 'package:job_portal_app/core/api/profile_api.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/features/job_seeker/provider/profile_provider.dart';
import 'package:job_portal_app/models/analytics_models.dart';
import 'package:job_portal_app/models/job_seeker_profile.dart';
import 'package:job_portal_app/models/user_model.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:job_portal_app/shared/widgets/buttons/secondary_button.dart';
import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class JobSeekerProfileScreen extends StatefulWidget {
  const JobSeekerProfileScreen({super.key});

  @override
  State<JobSeekerProfileScreen> createState() => _JobSeekerProfileScreenState();
}

class _JobSeekerProfileScreenState extends State<JobSeekerProfileScreen> {
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final authProvider = context.read<AuthProvider>();
      final profileProvider = context.read<JobSeekerProfileProvider>();

      final user = authProvider.user;
      if (user != null) {
        profileProvider.loadProfileAndDashboard(user.id);
      }
    });
  }

  // ===================== IMAGE UPLOAD =====================
  Future<void> _updateProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final profileProvider = context.read<JobSeekerProfileProvider>();

      final file = File(pickedFile.path);
      await ProfileApi.uploadProfilePicture(
        userId: authProvider.user!.id,
        file: file,
      );

      // Reload profile after upload
      await profileProvider.loadProfileAndDashboard(authProvider.user!.id);

      _showSnackBar('Profile picture updated successfully');
    } catch (e) {
      _showSnackBar('Failed to update profile picture', isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ===================== LOGOUT =====================
  Future<void> _logout() async {
    final confirmed = await _showConfirmDialog(
      'Logout',
      'Are you sure you want to logout?',
    );

    if (confirmed) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.login,
          (route) => false,
        );
      }
    }
  }

  // ===================== UTILITY METHODS =====================
  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Present';
    return DateFormat('MMM yyyy').format(date);
  }

  void _navigateToEditProfile() {
    final profile = context.read<JobSeekerProfileProvider>().profile;

    Navigator.pushNamed(
      context,
      RouteNames.editProfile,
      arguments: profile,
    ).then((updated) {
      if (updated == true) {
        final authProvider = context.read<AuthProvider>();
        final profileProvider = context.read<JobSeekerProfileProvider>();
        profileProvider.loadProfileAndDashboard(authProvider.user!.id);
      }
    });
  }

  void _navigateToSection(String section) {
    switch (section) {
      case 'resume':
        Navigator.pushNamed(context, RouteNames.resumeUpload);
        break;
      case 'skills':
        Navigator.pushNamed(context, RouteNames.skills);
        break;
      case 'education':
        Navigator.pushNamed(context, RouteNames.education);
        break;
      case 'experience':
        Navigator.pushNamed(context, RouteNames.experience);
        break;
      case 'certifications':
        Navigator.pushNamed(context, RouteNames.certifications);
        break;
      case 'applications':
        Navigator.pushNamed(context, RouteNames.appliedJobs);
        break;
      case 'saved':
        Navigator.pushNamed(context, RouteNames.savedJobs);
        break;
      case 'settings':
        Navigator.pushNamed(context, RouteNames.settings);
        break;
    }
  }

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<JobSeekerProfileProvider>();
    final authProvider = context.watch<AuthProvider>();

    final user = authProvider.user;
    final profile = profileProvider.profile;
    final dashboard = profileProvider.dashboard;

    return LoadingOverlay(
      isLoading: profileProvider.isLoading || _isUploading,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _navigateToSection('settings'),
            ),
          ],
        ),
        body: profileProvider.error != null
            ? _buildErrorState(profileProvider.error!)
            : profile == null
            ? _buildEmptyState()
            : _buildProfileContent(
                user: user!,
                profile: profile,
                dashboard: dashboard,
              ),
      ),
    );
  }

  Widget _buildProfileContent({
    required User user,
    required JobSeekerProfile profile,
    JobSeekerDashboardResponse? dashboard,
  }) {
    final totalApplications = dashboard?.totalApplications ?? 0;
    final last30Days = dashboard?.applicationsLast30Days ?? 0;
    final status = dashboard?.applicationStatusBreakdown ?? {};
    final interviews = status['INTERVIEW'] ?? 0;
    final savedJobs = profile.savedJobs?.length ?? 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(user, profile),
          _buildStatsSection(
            totalApplications: totalApplications,
            savedJobs: savedJobs,
            interviews: interviews,
            viewed: profile.applications?.length ?? 0,
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                _buildProfileSection(
                  title: 'Resume & Documents',
                  icon: Icons.description,
                  subtitle: profile.resumes?.isNotEmpty == true
                      ? '${profile.resumes!.length} resume(s) uploaded'
                      : 'Upload your resume',
                  onTap: () => _navigateToSection('resume'),
                ),
                _buildProfileSection(
                  title: 'Skills',
                  icon: Icons.star,
                  subtitle: profile.skills.isNotEmpty
                      ? '${profile.skills.length} skills added'
                      : 'Add your skills',
                  onTap: () => _navigateToSection('skills'),
                  trailing: _buildSkillChips(profile),
                ),
                _buildProfileSection(
                  title: 'Education',
                  icon: Icons.school,
                  subtitle: profile.education.isNotEmpty
                      ? '${profile.education.length} education records'
                      : 'Add your education',
                  onTap: () => _navigateToSection('education'),
                ),
                _buildProfileSection(
                  title: 'Experience',
                  icon: Icons.work,
                  subtitle: profile.experience.isNotEmpty
                      ? '${profile.experience.length} work experiences'
                      : 'Add your work experience',
                  onTap: () => _navigateToSection('experience'),
                ),
                _buildProfileSection(
                  title: 'Certifications',
                  icon: Icons.verified,
                  subtitle: profile.certifications.isNotEmpty
                      ? '${profile.certifications.length} certifications'
                      : 'Add your certifications',
                  onTap: () => _navigateToSection('certifications'),
                ),
                if (profile.portfolioLinks.isNotEmpty)
                  _buildPortfolioSection(profile),
                _buildProfileSection(
                  title: 'My Applications',
                  icon: Icons.send,
                  subtitle:
                      '$totalApplications applications ($last30Days in last 30 days)',
                  onTap: () => _navigateToSection('applications'),
                ),
                _buildProfileSection(
                  title: 'Saved Jobs',
                  icon: Icons.bookmark,
                  subtitle: '$savedJobs saved jobs',
                  onTap: () => _navigateToSection('saved'),
                ),
                if (profile.preferredJobTypes.isNotEmpty)
                  _buildPreferredSection(profile),
                if (profile.preferredLocations.isNotEmpty)
                  _buildPreferredLocations(profile),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.all(AppSizes.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User user, JobSeekerProfile profile) {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.profilePictureUrl != null
                      ? NetworkImage(
                          AppConstants.baseImageUrl + user.profilePictureUrl!,
                        )
                      : null,
                  child: user.profilePictureUrl == null
                      ? Text(_getInitials(user.fullName))
                      : null,
                ),
                GestureDetector(
                  onTap: _updateProfilePicture,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(user.email),
            if (profile.headline != null) Text(profile.headline!),
            SecondaryButton(
              text: 'Edit Profile',
              onPressed: _navigateToEditProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection({
    required int totalApplications,
    required int savedJobs,
    required int interviews,
    required int viewed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'Applied',
                value: totalApplications.toString(),
                icon: Icons.send,
                color: Colors.blue,
              ),
              _buildStatItem(
                label: 'Viewed',
                value: viewed.toString(),
                icon: Icons.visibility,
                color: Colors.green,
              ),
              _buildStatItem(
                label: 'Saved',
                value: savedJobs.toString(),
                icon: Icons.bookmark,
                color: Colors.orange,
              ),
              _buildStatItem(
                label: 'Interviews',
                value: interviews.toString(),
                icon: Icons.video_call,
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizes.textLg,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.textSm,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection({
    required String title,
    required IconData icon,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: AppSizes.textMd,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: AppSizes.textSm,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSkillChips(JobSeekerProfile profile) {
    if (profile.skills.isEmpty) return const Icon(Icons.chevron_right);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${profile.skills.length} skills',
            style: TextStyle(
              fontSize: AppSizes.textSm,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right),
      ],
    );
  }

  Widget _buildPortfolioSection(JobSeekerProfile profile) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Portfolio Links',
              style: TextStyle(
                fontSize: AppSizes.textMd,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.portfolioLinks.map((link) {
                return ActionChip(
                  avatar: const Icon(Icons.link, size: 14),
                  label: Text(
                    _getDomainFromUrl(link),
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () => _launchUrl(link),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferredSection(JobSeekerProfile profile) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferred Job Types',
              style: TextStyle(
                fontSize: AppSizes.textMd,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.preferredJobTypes.map((type) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: AppSizes.textSm,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferredLocations(JobSeekerProfile profile) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferred Locations',
              style: TextStyle(
                fontSize: AppSizes.textMd,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.preferredLocations.map((location) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    location,
                    style: const TextStyle(
                      fontSize: AppSizes.textSm,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Could not launch $url', isError: true);
    }
  }

  Widget _buildEmptyState() => const Center(child: CircularProgressIndicator());

  Widget _buildErrorState(String error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: AppSizes.md),
        Text(error, textAlign: TextAlign.center),
        const SizedBox(height: AppSizes.md),
        PrimaryButton(
          text: 'Retry',
          onPressed: () {
            final profileProvider = context.read<JobSeekerProfileProvider>();
            final authProvider = context.read<AuthProvider>();
            profileProvider.loadProfileAndDashboard(authProvider.user!.id);
          },
        ),
      ],
    ),
  );

  String _getDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }
}
