import 'package:flutter/material.dart';
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
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class JobSeekerProfileScreen extends StatefulWidget {
  const JobSeekerProfileScreen({super.key});

  @override
  State<JobSeekerProfileScreen> createState() => _JobSeekerProfileScreenState();
}

class _JobSeekerProfileScreenState extends State<JobSeekerProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isUploading = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      // ignore: use_build_context_synchronously
      final authProvider = context.read<AuthProvider>();
      // ignore: use_build_context_synchronously
      final profileProvider = context.read<JobSeekerProfileProvider>();

      final user = authProvider.user;
      if (user != null) {
        profileProvider.loadProfileAndDashboard(user.id);
      }
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

      await profileProvider.uploadProfilePicture(
        file: file,
        authProvider: authProvider,
      );

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
      final authProvider = context.read<AuthProvider>();
      final profileProvider = context.read<JobSeekerProfileProvider>();

      profileProvider.clearProfile();
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

    if (user == null) {
      return const SizedBox(); // or loading spinner
    }

    return LoadingOverlay(
      isLoading: profileProvider.isLoading || _isUploading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: profileProvider.error != null
            ? _buildErrorState(profileProvider.error!)
            : profile == null
            ? _buildEmptyState()
            : _buildProfileContent(
                user: user,
                profile: profile,
                dashboard: dashboard,
              ),
      ),
    );
  }

  Widget _animatedItem({required int index, required Widget child}) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (index * 0.08).clamp(0.0, 1.0),
        1.0,
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(animation),
        child: child,
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
          _animatedItem(index: 0, child: _buildProfileHeader(user, profile)),
          _animatedItem(
            index: 1,
            child: _buildStatsSection(
              totalApplications: totalApplications,
              savedJobs: savedJobs,
              interviews: interviews,
              viewed: profile.applications?.length ?? 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                _animatedItem(
                  index: 2,
                  child: _buildProfileSection(
                    title: 'Resume & Documents',
                    icon: Icons.description,
                    subtitle: profile.resumes?.isNotEmpty == true
                        ? '${profile.resumes!.length} resume(s) uploaded'
                        : 'Upload your resume',
                    onTap: () => _navigateToSection('resume'),
                  ),
                ),
                _animatedItem(
                  index: 3,
                  child: _buildProfileSection(
                    title: 'Education',
                    icon: Icons.school,
                    subtitle: profile.education.isNotEmpty
                        ? '${profile.education.length} education records'
                        : 'Add your education',
                    onTap: () => _navigateToSection('education'),
                  ),
                ),
                _animatedItem(
                  index: 4,
                  child: _buildProfileSection(
                    title: 'Experience',
                    icon: Icons.work,
                    subtitle: profile.experience.isNotEmpty
                        ? '${profile.experience.length} work experiences'
                        : 'Add your work experience',
                    onTap: () => _navigateToSection('experience'),
                  ),
                ),
                _animatedItem(
                  index: 5,
                  child: _buildProfileSection(
                    title: 'Certifications',
                    icon: Icons.verified,
                    subtitle: profile.certifications.isNotEmpty
                        ? '${profile.certifications.length} certifications'
                        : 'Add your certifications',
                    onTap: () => _navigateToSection('certifications'),
                  ),
                ),
                _animatedItem(
                  index: 6,
                  child: _buildProfileSection(
                    title: 'My Applications',
                    icon: Icons.send,
                    subtitle:
                        '$totalApplications applications ($last30Days in last 30 days)',
                    onTap: () => _navigateToSection('applications'),
                  ),
                ),
                _animatedItem(
                  index: 7,
                  child: _buildProfileSection(
                    title: 'Saved Jobs',
                    icon: Icons.bookmark,
                    subtitle: '$savedJobs saved jobs',
                    onTap: () => _navigateToSection('saved'),
                  ),
                ),
                if (profile.portfolioLinks.isNotEmpty)
                  _animatedItem(
                    index: 8,
                    child: _buildPortfolioSection(profile),
                  ),

                _animatedItem(index: 9, child: _buildSkillsSection(profile)),

                if (profile.preferredJobTypes.isNotEmpty)
                  _animatedItem(
                    index: 10,
                    child: _buildPreferredSection(profile),
                  ),

                if (profile.preferredLocations.isNotEmpty)
                  _animatedItem(
                    index: 11,
                    child: _buildPreferredLocations(profile),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          _animatedItem(
            index: 12,
            child: Padding(
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
                          '${AppConstants.getImageUrl(user.profilePictureUrl)}?t=${DateTime.now().millisecondsSinceEpoch}',
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

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSkillsSection(JobSeekerProfile profile) {
    if (profile.skills.isEmpty) return const SizedBox();

    return _buildSectionCard(
      icon: Icons.psychology_outlined,
      title: "Skills",
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: profile.skills.map((skill) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              skill,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPortfolioSection(JobSeekerProfile profile) {
    if (profile.portfolioLinks.isEmpty) return const SizedBox();

    return _buildSectionCard(
      icon: Icons.link_outlined,
      title: "Portfolio",
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: profile.portfolioLinks.map((link) {
          return InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => _launchUrl(link),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.public, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _getDomainFromUrl(link),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPreferredSection(JobSeekerProfile profile) {
    if (profile.preferredJobTypes.isEmpty) return const SizedBox();

    return _buildSectionCard(
      icon: Icons.work_outline,
      title: "Preferred Job Types",
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: profile.preferredJobTypes.map((type) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              type.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: AppColors.primary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPreferredLocations(JobSeekerProfile profile) {
    if (profile.preferredLocations.isEmpty) return const SizedBox();

    return _buildSectionCard(
      icon: Icons.location_on_outlined,
      title: "Preferred Locations",
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: profile.preferredLocations.map((location) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
