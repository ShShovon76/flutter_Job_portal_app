// features/job_seeker/presentation/company/company_details_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/features/employer/presentation/company/provider/company_provider.dart';
import 'package:job_portal_app/features/job_seeker/provider/job_provider.dart';
import 'package:job_portal_app/models/company_model.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyDetailsScreen extends StatefulWidget {
  final int companyId;

  const CompanyDetailsScreen({super.key, required this.companyId});

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen>
    with SingleTickerProviderStateMixin {
  // Add this mixin

  // ===================== STATE =====================
  Company? _company;
  List<Job> _companyJobs = [];
  bool _isLoadingCompany = true;
  bool _isLoadingJobs = true;
  String? _error;

  // ===================== TAB CONTROLLER =====================
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load data after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanyData();
      _loadCompanyJobs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Always dispose controllers
    super.dispose();
  }

  // ===================== DATA LOADING =====================
  Future<void> _loadCompanyData() async {
    if (!mounted) return; // Add this check

    setState(() {
      _isLoadingCompany = true;
      _error = null;
    });

    try {
      final companyProvider = Provider.of<CompanyProvider>(
        context,
        listen: false,
      );
      await companyProvider.loadCompanyById(widget.companyId);

      if (!mounted) return; // Add this check after async call

      setState(() {
        _company = companyProvider.selectedCompany;
        _isLoadingCompany = false;
      });
    } catch (e) {
      if (!mounted) return; // Add this check after async call

      setState(() {
        _error = e.toString();
        _isLoadingCompany = false;
      });
    }
  }

  Future<void> _loadCompanyJobs() async {
    if (!mounted) return;

    setState(() {
      _isLoadingJobs = true;
    });

    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      await jobProvider.loadJobsByCompany(widget.companyId);

      if (!mounted) return;

      setState(() {
        _companyJobs = jobProvider.jobs;
        _isLoadingJobs = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingJobs = false;
      });
    }
  }

  // ===================== UTILITY METHODS =====================
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Could not launch URL', isError: true);
    }
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM yyyy').format(date);
  }

  String _formatNumber(int? number) {
    if (number == null) return '0';
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
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
      default:
        return Icons.link;
    }
  }

  Color _getSocialColor(SocialLinkType type) {
    switch (type) {
      case SocialLinkType.WEBSITE:
        return Colors.blue;
      case SocialLinkType.LINKEDIN:
        return const Color(0xFF0077B5);
      case SocialLinkType.FACEBOOK:
        return const Color(0xFF1877F2);
      case SocialLinkType.INSTAGRAM:
        return const Color(0xFFE4405F);
      default:
        return AppColors.primary;
    }
  }

  void _viewJobDetails(int jobId) {
    Navigator.pushNamed(context, RouteNames.jobDetails, arguments: jobId);
  }

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoadingCompany,
      child: Scaffold(
        body: _error != null
            ? _buildErrorState()
            : _company == null
            ? _buildEmptyState()
            : _buildCompanyContent(),
      ),
    );
  }

  Widget _buildCompanyContent() {
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
                        AppConstants.getImageUrl(_company!.coverImageUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildDefaultCover(),
                      )
                    : _buildDefaultCover(),

                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Company Info Section
        SliverToBoxAdapter(child: _buildCompanyInfo()),

        // Tabs
        SliverToBoxAdapter(child: _buildTabs()),

        // Tab Content
        SliverToBoxAdapter(child: _buildTabContent()),

        const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
      ],
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.3),
      child: Center(
        child: Icon(
          Icons.image,
          size: 64,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Card Content
        Container(
          margin: const EdgeInsets.only(top: 50), // space for overlapping logo
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40), // space below logo
              // Company Name and Industry Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _company!.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
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

                      if (_company!.verified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: Colors.green,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Stats Row
              _buildStatsRow(),

              const SizedBox(height: 16),

              // Rating Card
              if (_company!.rating != null) _buildRatingCard(),
            ],
          ),
        ),

        // Positioned Company Logo (Overlapping)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: _company!.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        AppConstants.getImageUrl(_company!.logoUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildDefaultLogo(),
                      ),
                    )
                  : _buildDefaultLogo(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.business,
        size: 40,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.work_outline,
          value: _formatNumber(_company!.activeJobCount),
          label: 'Active Jobs',
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.calendar_today_outlined,
          value: _formatFoundedYear(_company!.foundedYear),
          label: 'Founded',
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.people_outline,
          value: _company!.companySize ?? 'N/A',
          label: 'Size',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFoundedYear(int? year) {
    if (year == null) return 'N/A';
    return year.toString();
  }

  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 24),
          const SizedBox(width: 8),
          Text(
            _company!.rating!.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(${_company!.reviewCount ?? 0} reviews)',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              // Navigate to reviews
            },
            child: const Text('View Reviews'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'About'),
          Tab(text: 'Jobs'),
          Tab(text: 'Contact'),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 600, // or calculated height
      child: TabBarView(
        controller: _tabController,
        children: [_buildAboutTab(), _buildJobsTab(), _buildContactTab()],
      ),
    );
  }

  Widget _buildAboutTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // About Section
        if (_company!.about != null) ...[
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
              _company!.about!,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Company Details
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
              _buildDetailRow('Industry', _company!.industry),
              if (_company!.companySize != null)
                _buildDetailRow('Company Size', _company!.companySize!),
              if (_company!.foundedYear != null)
                _buildDetailRow('Founded', _company!.foundedYear.toString()),
              _buildDetailRow('Member Since', _formatDate(_company!.createdAt)),
              if (_company!.owner != null)
                _buildDetailRow('Owner', _company!.owner!.fullName),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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

  Widget _buildJobsTab() {
    if (_isLoadingJobs) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_companyJobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.work_outline,
                size: 48,
                color: AppColors.textDisabled.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Active Jobs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'This company has no active jobs at the moment',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _companyJobs.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final job = _companyJobs[index];
        return _buildJobTile(job);
      },
    );
  }

  Widget _buildJobTile(Job job) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: job.company.logoUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  AppConstants.getImageUrl(job.company.logoUrl!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.business),
                ),
              )
            : const Icon(Icons.business, color: AppColors.primary),
      ),
      title: Text(
        job.title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getJobTypeColor(job.jobType).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatJobType(job.jobType),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getJobTypeColor(job.jobType),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (job.minSalary != null || job.maxSalary != null)
                Text(
                  _formatSalary(job),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _viewJobDetails(job.id),
    );
  }

  Color _getJobTypeColor(JobType type) {
    switch (type) {
      case JobType.FULL_TIME:
        return Colors.blue;
      case JobType.PART_TIME:
        return Colors.orange;
      case JobType.CONTRACT:
        return Colors.purple;
      case JobType.REMOTE:
        return Colors.green;
      case JobType.INTERNSHIP:
        return Colors.teal;
      case JobType.FREELANCE:
        return Colors.amber;
    }
  }

  String _formatJobType(JobType type) {
    return type.name.replaceAll('_', ' ').toUpperCase();
  }

  String _formatSalary(Job job) {
    if (job.minSalary == null && job.maxSalary == null) {
      return 'Not specified';
    } else if (job.minSalary != null && job.maxSalary != null) {
      return '\$${_formatNumberSalary(job.minSalary!)} - \$${_formatNumberSalary(job.maxSalary!)}';
    } else if (job.minSalary != null) {
      return 'From \$${_formatNumberSalary(job.minSalary!)}';
    } else {
      return 'Up to \$${_formatNumberSalary(job.maxSalary!)}';
    }
  }

  // Helper method to format double to String
  String _formatNumberSalary(double number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toStringAsFixed(0);
  }

  Widget _buildContactTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact Information
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

        const SizedBox(height: 8),

        // Social Links
        if (_company!.socialLinks.isNotEmpty) ...[
          const Text(
            'Social Links',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _company!.socialLinks.map((link) {
              return _buildSocialChip(link);
            }).toList(),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
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

  Widget _buildSocialChip(SocialLink link) {
    final color = _getSocialColor(link.type);

    return ActionChip(
      avatar: Icon(_getSocialIcon(link.type), size: 16, color: color),
      label: Text(
        link.type.value,
        style: TextStyle(fontSize: 12, color: color),
      ),
      onPressed: () => _launchUrl(link.url),
      backgroundColor: color.withValues(alpha: 0.1),
    );
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
              _error ?? 'Failed to load company details',
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
              color: AppColors.textDisabled.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Company Not Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'The company you\'re looking for doesn\'t exist',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Go Back',
              onPressed: () => Navigator.pop(context),
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}
