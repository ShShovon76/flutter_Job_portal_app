// manage_employers_screen.dart
// manage_employers_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/features/employer/presentation/company/provider/company_provider.dart';
import 'package:job_portal_app/models/company_model.dart';
import 'package:provider/provider.dart';

class ManageEmployersScreen extends StatefulWidget {
  const ManageEmployersScreen({super.key});

  @override
  State<ManageEmployersScreen> createState() => _ManageEmployersScreenState();
}

class _ManageEmployersScreenState extends State<ManageEmployersScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  bool _isLoadingMore = false;

  final List<String> _filters = ['All', 'Verified', 'Pending', 'Featured'];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanies();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreCompanies();
    }
  }

  Future<void> _loadCompanies() async {
    final companyProvider = Provider.of<CompanyProvider>(
      context,
      listen: false,
    );
    await companyProvider.loadCompanies(refresh: true);
  }

  Future<void> _loadMoreCompanies() async {
    if (_isLoadingMore) return;

    final companyProvider = Provider.of<CompanyProvider>(
      context,
      listen: false,
    );
    if (companyProvider.hasMore) {
      setState(() => _isLoadingMore = true);
      await companyProvider.loadCompanies();
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refreshCompanies() async {
    final companyProvider = Provider.of<CompanyProvider>(
      context,
      listen: false,
    );
    await companyProvider.loadCompanies(refresh: true);
  }

  Future<void> _searchCompanies(String query) async {
    if (query.isEmpty) {
      _refreshCompanies();
      return;
    }

    final companyProvider = Provider.of<CompanyProvider>(
      context,
      listen: false,
    );

    bool? verified;
    if (_selectedFilter == 'Verified') verified = true;
    if (_selectedFilter == 'Pending') verified = false;

    await companyProvider.searchCompanies(
      keyword: query,
      verified: verified,
      refresh: true,
    );
  }

  void _showCompanyDetails(Company company) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CompanyDetailsSheet(company: company),
    );
  }

  void _confirmToggleVerification(Company company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(company.verified ? 'Unverify Company' : 'Verify Company'),
        content: Text(
          'Are you sure you want to ${company.verified ? 'unverify' : 'verify'} "${company.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // You'll need to add adminId from auth provider
              const adminId = 1; // Replace with actual admin ID

              final companyProvider = Provider.of<CompanyProvider>(
                context,
                listen: false,
              );

              if (!company.verified) {
                await companyProvider.verifyCompany(company.id, adminId);
              }

              _refreshCompanies();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Company ${company.verified ? 'unverified' : 'verified'} successfully',
                  ),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: company.verified
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF10B981),
            ),
            child: Text(company.verified ? 'Unverify' : 'Verify'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCompany(Company company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Company'),
        content: Text(
          'Are you sure you want to delete "${company.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final companyProvider = Provider.of<CompanyProvider>(
                context,
                listen: false,
              );

              await companyProvider.deleteCompany(
                company.id,
                company.owner?.id ?? 0,
              );

              _refreshCompanies();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Company deleted successfully'),
                  backgroundColor: Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header with Stats
          _buildHeader(),

          // Search Bar
          _buildSearchBar(),

          // Filter Chips
          _buildFilterChips(),

          // Companies List
          Expanded(child: _buildCompaniesList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<CompanyProvider>(
      builder: (context, provider, child) {
        final totalCompanies = provider.totalPages > 0
            ? provider.companies.length
            : 0;
        final verified = provider.companies.where((c) => c.verified).length;
        final pending = provider.companies.where((c) => !c.verified).length;
        final featured = provider.companies
            .where((c) => c.featured == true)
            .length;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage Employers',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatChip(
                      label: 'Total',
                      value: '$totalCompanies',
                      color: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      label: 'Verified',
                      value: '$verified',
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      label: 'Pending',
                      value: '$pending',
                      color: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      label: 'Featured',
                      value: '$featured',
                      color: const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search companies...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF64748B),
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _refreshCompanies();
                          },
                        )
                      : null,
                ),
                onSubmitted: _searchCompanies,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedFilter = filter);
                  _searchCompanies(_searchController.text);
                },
                backgroundColor: Colors.grey[100],
                selectedColor: filter == 'Verified'
                    ? const Color(0xFF10B981)
                    : filter == 'Pending'
                    ? const Color(0xFFF59E0B)
                    : filter == 'Featured'
                    ? const Color(0xFF8B5CF6)
                    : const Color(0xFF3B82F6),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCompaniesList() {
    return Consumer<CompanyProvider>(
      builder: (context, provider, child) {
        if (provider.loading && provider.companies.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFEF4444)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshCompanies,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final companies = provider.companies;

        if (companies.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 64,
                  color: Color(0xFF94A3B8),
                ),
                SizedBox(height: 16),
                Text(
                  'No companies found',
                  style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshCompanies,
          color: const Color(0xFF3B82F6),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: companies.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == companies.length) {
                return _buildLoadingIndicator();
              }
              return _buildCompanyCard(companies[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildCompanyCard(Company company) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showCompanyDetails(company),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Company Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: company.logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                         AppConstants.getImageUrl(company.logoUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.business,
                            color: Color(0xFF3B82F6),
                            size: 28,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.business,
                        color: Color(0xFF3B82F6),
                        size: 28,
                      ),
              ),
              const SizedBox(width: 12),
              // Company Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            company.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        if (company.featured == true)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star,
                              color: Color(0xFF8B5CF6),
                              size: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company.industry,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    if (company.owner != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Owner: ${company.owner!.fullName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Verification Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: company.verified
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : const Color(
                                    0xFFF59E0B,
                                  ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                company.verified
                                    ? Icons.verified
                                    : Icons.pending,
                                size: 10,
                                color: company.verified
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                company.verified ? 'Verified' : 'Pending',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: company.verified
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Job Count
                        if (company.activeJobCount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF3B82F6,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${company.activeJobCount} jobs',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 18),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'verify',
                    child: Row(
                      children: [
                        Icon(
                          company.verified ? Icons.block : Icons.verified,
                          size: 18,
                          color: company.verified
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          company.verified ? 'Unverify' : 'Verify',
                          style: TextStyle(
                            color: company.verified
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Color(0xFFEF4444)),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: Color(0xFFEF4444)),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'view') {
                    _showCompanyDetails(company);
                  } else if (value == 'verify') {
                    _confirmToggleVerification(company);
                  } else if (value == 'delete') {
                    _confirmDeleteCompany(company);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
        ),
      ),
    );
  }
}

// Bottom Sheet for Company Details
class _CompanyDetailsSheet extends StatelessWidget {
  final Company company;

  const _CompanyDetailsSheet({required this.company});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: company.logoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                           AppConstants.getImageUrl(company.logoUrl!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.business,
                          color: Color(0xFF3B82F6),
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              company.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (company.featured == true)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF8B5CF6,
                                ).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Color(0xFF8B5CF6),
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        company.industry,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Company Details
            if (company.about != null) ...[
              _buildSectionTitle('About'),
              const SizedBox(height: 8),
              Text(
                company.about!,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),
            ],

            _buildSectionTitle('Contact Information'),
            const SizedBox(height: 8),
            if (company.email != null)
              _buildDetailItem(
                icon: Icons.email,
                label: 'Email',
                value: company.email!,
              ),
            if (company.phone != null) ...[
              const SizedBox(height: 8),
              _buildDetailItem(
                icon: Icons.phone,
                label: 'Phone',
                value: company.phone!,
              ),
            ],
            if (company.website != null) ...[
              const SizedBox(height: 8),
              _buildDetailItem(
                icon: Icons.language,
                label: 'Website',
                value: company.website!,
              ),
            ],
            if (company.address != null) ...[
              const SizedBox(height: 8),
              _buildDetailItem(
                icon: Icons.location_on,
                label: 'Address',
                value: company.address!,
              ),
            ],

            const SizedBox(height: 16),
            _buildSectionTitle('Company Details'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'Size',
                    value: company.companySize ?? 'Not specified',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    label: 'Founded',
                    value: company.foundedYear?.toString() ?? 'Not specified',
                  ),
                ),
              ],
            ),
            if (company.rating != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${company.rating!.toStringAsFixed(1)} (${company.reviewCount ?? 0} reviews)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            _buildSectionTitle('Owner Information'),
            const SizedBox(height: 8),
            if (company.owner != null)
              _buildDetailItem(
                icon: Icons.person,
                label: 'Owner',
                value: company.owner!.fullName,
              ),

            if (company.createdAt != null) ...[
              const SizedBox(height: 8),
              _buildDetailItem(
                icon: Icons.calendar_today,
                label: 'Created',
                value: dateFormat.format(company.createdAt!),
              ),
            ],

            const SizedBox(height: 16),
            _buildSectionTitle('Social Links'),
            const SizedBox(height: 8),
            if (company.socialLinks.isEmpty)
              const Text(
                'No social links provided',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: company.socialLinks.map((link) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSocialIcon(link.type),
                          size: 14,
                          color: const Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          link.type.value,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: const Color(0xFF3B82F6), size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
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
}
