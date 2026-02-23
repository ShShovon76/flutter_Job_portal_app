import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/features/employer/presentation/company/edit_company_profile_screen.dart';
import 'package:job_portal_app/features/employer/presentation/company/provider/company_provider.dart';
import 'package:job_portal_app/models/company_model.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  // ===================== STATE =====================
  Company? _company;
  bool _isLoading = true;
  bool _isUploading = false;
  String? _error;

  // ===================== INIT =====================
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanyData();
    });
  }

  // ===================== DATA LOADING =====================
  Future<void> _loadCompanyData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final companyProvider = Provider.of<CompanyProvider>(
        context,
        listen: false,
      );

      final userId = authProvider.user?.id;
      if (userId == null) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      await companyProvider.loadMyCompany(userId);

      setState(() {
        _company = companyProvider.myCompany;
        _isLoading = false;
      });

      if (_company == null) {
        _showNoCompanyDialog();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showNoCompanyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('No Company Found'),
        content: const Text(
          'You haven\'t created a company profile yet. '
          'Would you like to create one now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, RouteNames.editCompanyProfile);
            },
            child: const Text('Create Company'),
          ),
        ],
      ),
    );
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

  // ===================== IMAGE UPLOAD =====================
  Future<void> _pickAndUploadImage(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(pickedFile.path);
      final companyProvider = Provider.of<CompanyProvider>(
        context,
        listen: false,
      );

      if (type == 'logo') {
        await companyProvider.uploadLogo(file);
      } else {
        await companyProvider.uploadCover(file);
      }

      setState(() {
        _company = companyProvider.myCompany;
        _isUploading = false;
      });

      _showSnackBar(
        '${type == 'logo' ? 'Logo' : 'Cover image'} updated successfully',
      );
    } catch (e) {
      setState(() => _isUploading = false);
      _showSnackBar('Failed to upload image', isError: true);
    }
  }

  Future<void> _deleteImage(String type) async {
    final confirmed = await _showConfirmDialog(
      'Delete ${type == 'logo' ? 'Logo' : 'Cover Image'}',
      'Are you sure you want to delete this image?',
    );

    if (!confirmed) return;

    setState(() => _isUploading = true);

    try {
      final companyProvider = Provider.of<CompanyProvider>(
        context,
        listen: false,
      );

      if (type == 'logo') {
        await companyProvider.deleteLogo();
      } else {
        await companyProvider.deleteCover();
      }

      setState(() {
        _company = companyProvider.myCompany;
        _isUploading = false;
      });

      _showSnackBar(
        '${type == 'logo' ? 'Logo' : 'Cover image'} deleted successfully',
      );
    } catch (e) {
      setState(() => _isUploading = false);
      _showSnackBar('Failed to delete image', isError: true);
    }
  }

  void _showImageOptions(String type) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(type);
              },
            ),
            if ((type == 'logo' && _company?.logoUrl != null) ||
                (type == 'cover' && _company?.coverImageUrl != null))
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteImage(type);
                },
              ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== SOCIAL LINKS =====================
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Could not launch URL', isError: true);
    }
  }

  IconData _getSocialIcon(SocialLinkType type) {
    switch (type) {
      case SocialLinkType.WEBSITE:
        return Icons.language;
      case SocialLinkType.LINKEDIN:
        return Icons.link;
      case SocialLinkType.FACEBOOK:
        return Icons.facebook;
      case SocialLinkType.INSTAGRAM:
        return Icons.photo_camera;
    }
  }

  // ===================== UTILITY =====================
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

  String _formatFoundedYear(int? year) {
    if (year == null) return 'Not specified';
    return year.toString();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM d, yyyy').format(date);
  }

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading || _isUploading,
      child: Scaffold(
        body: _error != null
            ? _buildErrorState()
            : _company == null
            ? _buildEmptyState()
            : _buildProfileContent(),
      ),
    );
  }

  Widget _buildProfileContent() {
    return CustomScrollView(
      slivers: [
        // App Bar with Cover Image
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          stretch: true,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Cover Image
                _company!.coverImageUrl != null
                    ? Image.network(
                        AppConstants.baseImageUrl! + _company!.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildDefaultCover(),
                      )
                    : _buildDefaultCover(),

                // Cover Image Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),

                // Edit Cover Button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      onPressed: () => _showImageOptions('cover'),
                      icon: const Icon(Icons.edit, size: 20),
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Edit Profile Button
            IconButton(
              onPressed: () => _navigateToEdit(),
              icon: const Icon(Icons.edit),
            ),
            // Logout Button
            IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
          ],
        ),

        // Profile Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Logo and Basic Info
                _buildLogoAndBasicInfo(),

                const SizedBox(height: 24),

                // Verification Badge
                if (_company!.verified == true) _buildVerificationBadge(),

                const SizedBox(height: 16),

                // Company Stats
                _buildStats(),

                const SizedBox(height: 24),

                // About Section
                _buildAboutSection(),

                const SizedBox(height: 24),

                // Contact Information
                _buildContactSection(),

                const SizedBox(height: 24),

                // Social Links
                if (_company!.socialLinks.isNotEmpty)
                  _buildSocialLinksSection(),

                const SizedBox(height: 24),

                // Company Details
                _buildDetailsSection(),

                const SizedBox(height: 32),

                // Danger Zone (Delete Company)
                _buildDangerZone(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      color: AppColors.primary.withOpacity(0.3),
      child: Center(
        child: Icon(
          Icons.image,
          size: 64,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildLogoAndBasicInfo() {
    return Row(
      children: [
        // Company Logo
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _company!.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        AppConstants.baseImageUrl + _company!.logoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildDefaultLogo(),
                      ),
                    )
                  : _buildDefaultLogo(),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: IconButton(
                  onPressed: () => _showImageOptions('logo'),
                  icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 16),

        // Company Name and Industry
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _company!.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _company!.industry,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_company!.companySize != null)
                    Text(
                      _company!.companySize!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              if (_company!.foundedYear != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Founded ${_company!.foundedYear}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.business,
        size: 40,
        color: AppColors.primary.withOpacity(0.5),
      ),
    );
  }

  Widget _buildVerificationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.verified, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Text(
            'Verified Company',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.work_outline,
            value: _company!.activeJobCount?.toString() ?? '0',
            label: 'Active Jobs',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star_outline,
            value: _company!.rating?.toStringAsFixed(1) ?? '0.0',
            label: 'Rating',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.reviews_outlined,
            value: _company!.reviewCount?.toString() ?? '0',
            label: 'Reviews',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            _company!.about ?? 'No description provided.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              if (_company!.email != null)
                _buildContactTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: _company!.email!,
                  onTap: () => _launchUrl('mailto:${_company!.email}'),
                ),
              if (_company!.phone != null)
                _buildContactTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: _company!.phone!,
                  onTap: () => _launchUrl('tel:${_company!.phone}'),
                ),
              if (_company!.website != null)
                _buildContactTile(
                  icon: Icons.language,
                  label: 'Website',
                  value: _company!.website!,
                  onTap: () => _launchUrl(_company!.website!),
                ),
              if (_company!.address != null)
                _buildContactTile(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: _company!.address!,
                  onTap: () => _launchUrl(
                    'https://maps.google.com/?q=${Uri.encodeComponent(_company!.address!)}',
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.open_in_new,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Social Links',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _company!.socialLinks.map((link) {
            return ActionChip(
              avatar: Icon(
                _getSocialIcon(link.type),
                size: 16,
                color: AppColors.primary,
              ),
              label: Text(
                link.type.value,
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: () => _launchUrl(link.url),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildDetailRow('Owner', _company!.owner!.fullName),
              _buildDetailRow('Industry', _company!.industry),
              if (_company!.companySize != null)
                _buildDetailRow('Company Size', _company!.companySize!),
              if (_company!.foundedYear != null)
                _buildDetailRow('Founded', _company!.foundedYear.toString()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danger Zone',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Delete Company',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Once deleted, all jobs and data will be permanently removed.',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _deleteCompany,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Delete Company'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _deleteCompany() async {
    final confirmed = await _showConfirmDialog(
      'Delete Company',
      'Are you sure you want to delete your company? '
          'This action cannot be undone and all jobs will be permanently removed.',
    );

    if (!confirmed) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final companyProvider = Provider.of<CompanyProvider>(
      context,
      listen: false,
    );

    final userId = authProvider.user?.id;
    if (userId == null || _company == null) return;

    setState(() => _isUploading = true);

    try {
      await companyProvider.deleteCompany(_company!.id, userId);

      if (mounted) {
        _showSnackBar('Company deleted successfully');
        Navigator.pushReplacementNamed(context, RouteNames.employerDashboard);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      _showSnackBar('Failed to delete company', isError: true);
    }
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCompanyProfileScreen(company: _company!),
      ),
    ).then((updated) {
      if (updated == true) {
        _loadCompanyData();
      }
    });
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Failed to load company profile',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Try Again',
              onPressed: _loadCompanyData,
              width: 150,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 80,
              color: AppColors.textDisabled.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Company Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'You haven\'t created a company profile yet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Create Company',
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  RouteNames.editCompanyProfile,
                );
              },
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
