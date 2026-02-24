// manage_users_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/features/auth/provider/user_provider.dart';
import 'package:job_portal_app/models/user_model.dart';
import 'package:provider/provider.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'All';
  String _selectedStatus = 'All';
  bool _isLoadingMore = false;
  Timer? _debounceTimer;

  final List<String> _roles = ['All', 'JOB_SEEKER', 'EMPLOYER', 'ADMIN'];
  final List<String> _statuses = ['All', 'Enabled', 'Disabled'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });

    _scrollController.addListener(_onScroll);
    _setupSearchListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _searchUsers(_searchController.text);
      });
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreUsers();
    }
  }

  Future<void> _loadUsers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUsers(page: 0, size: 10);
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoadingMore) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentPage = userProvider.usersPage?.page ?? 0;
    final totalPages = userProvider.usersPage?.totalPages ?? 1;

    if (currentPage + 1 < totalPages) {
      setState(() => _isLoadingMore = true);
      await userProvider.loadUsers(page: currentPage + 1, size: 10);
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refreshUsers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUsers(page: 0, size: 10);
  }

  Future<void> _searchUsers(String query) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await userProvider.searchUsers(
      keyword: query.isNotEmpty ? query : null,
      role: _selectedRole != 'All' ? _selectedRole : null,
      enabled: _selectedStatus != 'All' ? _selectedStatus == 'Enabled' : null,
      page: 0,
      size: 10,
    );
  }

  void _applyFilters() {
    _searchUsers(_searchController.text);
  }

  void _showUserDetails(User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _UserDetailsSheet(user: user),
    );
  }

  void _confirmToggleStatus(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.enabled == true ? 'Disable User' : 'Enable User'),
        content: Text(
          'Are you sure you want to ${user.enabled == true ? 'disable' : 'enable'} "${user.fullName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              await userProvider.enableUser(user.id, user.enabled == false);
              _refreshUsers();

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'User ${user.enabled == true ? 'disabled' : 'enabled'} successfully',
                  ),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user.enabled == true
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF10B981),
            ),
            child: Text(user.enabled == true ? 'Disable' : 'Enable'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete "${user.fullName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              await userProvider.deleteUser(user.id);
              _refreshUsers();

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User deleted successfully'),
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
      body: SafeArea(
        child: Column(
          children: [
            // Header with Stats
            _buildHeader(),

            // Search Bar
            _buildSearchBar(),

            // Filter Chips
            _buildFilterChips(),

            // Users List
            Expanded(child: _buildUsersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        final totalUsers = provider.usersPage?.totalItems ?? 0;
        final users = provider.usersPage?.items ?? [];

        final jobSeekers = users
            .where((u) => u.role == UserRole.JOB_SEEKER)
            .length;
        final employers = users
            .where((u) => u.role == UserRole.EMPLOYER)
            .length;
        final admins = users.where((u) => u.role == UserRole.ADMIN).length;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
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
                'Manage Users',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              // Wrap the row to prevent overflow on small screens
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatChip(
                    label: 'Total',
                    value: '$totalUsers',
                    color: const Color(0xFF3B82F6),
                  ),
                  _buildStatChip(
                    label: 'Job Seekers',
                    value: '$jobSeekers',
                    color: const Color(0xFF10B981),
                  ),
                  _buildStatChip(
                    label: 'Employers',
                    value: '$employers',
                    color: const Color(0xFFF59E0B),
                  ),
                  _buildStatChip(
                    label: 'Admins',
                    value: '$admins',
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
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
      constraints: const BoxConstraints(minWidth: 70),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
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
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
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
                            _refreshUsers();
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: _applyFilters,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _roles.map((role) {
                final isSelected = _selectedRole == role;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(role.replaceAll('_', ' ')),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedRole = role);
                      _applyFilters();
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: const Color(0xFF3B82F6),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1E293B),
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Status Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statuses.map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedStatus = status);
                      _applyFilters();
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: status == 'Enabled'
                        ? const Color(0xFF10B981)
                        : status == 'Disabled'
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF3B82F6),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1E293B),
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.usersPage == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                    onPressed: _refreshUsers,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        final users = provider.usersPage?.items ?? [];

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No users found',
                  style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshUsers,
          color: const Color(0xFF3B82F6),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: users.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == users.length) {
                return _buildLoadingIndicator();
              }
              return _buildUserCard(users[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildUserCard(User user) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final roleColor = _getRoleColor(user.role);

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
        onTap: () => _showUserDetails(user),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 28,
                backgroundColor: roleColor.withValues(alpha: 0.1),
                backgroundImage: user.profilePictureUrl != null
                    ? NetworkImage(
                        AppConstants.getImageUrl(user.profilePictureUrl!),
                      )
                    : null,
                child: user.profilePictureUrl == null
                    ? Text(
                        user.fullName[0].toUpperCase(),
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // User Info - Expanded to take available space
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.role?.value ?? 'USER',
                            style: TextStyle(
                              fontSize: 10,
                              color: roleColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (user.enabled ?? true)
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : const Color(
                                    0xFFEF4444,
                                  ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            (user.enabled ?? true) ? 'Enabled' : 'Disabled',
                            style: TextStyle(
                              fontSize: 10,
                              color: (user.enabled ?? true)
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Joined Date and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (user.createdAt != null)
                    Column(
                      children: [
                        Text(
                          'Joined',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[400],
                          ),
                        ),
                        Text(
                          dateFormat.format(user.createdAt!),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  // Actions
                  PopupMenuButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
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
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              user.enabled == true
                                  ? Icons.block
                                  : Icons.check_circle,
                              size: 18,
                              color: user.enabled == true
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user.enabled == true ? 'Disable' : 'Enable',
                              style: TextStyle(
                                color: user.enabled == true
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
                            Icon(
                              Icons.delete,
                              size: 18,
                              color: Color(0xFFEF4444),
                            ),
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
                        _showUserDetails(user);
                      } else if (value == 'toggle') {
                        _confirmToggleStatus(user);
                      } else if (value == 'delete') {
                        _confirmDeleteUser(user);
                      }
                    },
                  ),
                ],
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

  Color _getRoleColor(UserRole? role) {
    switch (role) {
      case UserRole.ADMIN:
        return const Color(0xFFEF4444);
      case UserRole.EMPLOYER:
        return const Color(0xFFF59E0B);
      case UserRole.JOB_SEEKER:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }
}

// Bottom Sheet for User Details
class _UserDetailsSheet extends StatelessWidget {
  final User user;

  const _UserDetailsSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(user.role);
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
                CircleAvatar(
                  radius: 40,
                  backgroundColor: roleColor.withValues(alpha: 0.1),
                  backgroundImage: user.profilePictureUrl != null
                      ? NetworkImage(
                          AppConstants.getImageUrl(user.profilePictureUrl!),
                        )
                      : null,
                  child: user.profilePictureUrl == null
                      ? Text(
                          user.fullName[0].toUpperCase(),
                          style: TextStyle(
                            color: roleColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role?.value ?? 'USER',
                          style: TextStyle(
                            fontSize: 12,
                            color: roleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // User Details
            _buildDetailItem(
              icon: Icons.email,
              label: 'Email',
              value: user.email,
            ),
            if (user.phone != null) ...[
              const SizedBox(height: 12),
              _buildDetailItem(
                icon: Icons.phone,
                label: 'Phone',
                value: user.phone!,
              ),
            ],
            if (user.createdAt != null) ...[
              const SizedBox(height: 12),
              _buildDetailItem(
                icon: Icons.calendar_today,
                label: 'Joined',
                value: dateFormat.format(user.createdAt!),
              ),
            ],
            const SizedBox(height: 12),
            _buildDetailItem(
              icon: Icons.info,
              label: 'Status',
              value: (user.enabled ?? true) ? 'Enabled' : 'Disabled',
              valueColor: (user.enabled ?? true)
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
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

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF3B82F6), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(UserRole? role) {
    switch (role) {
      case UserRole.ADMIN:
        return const Color(0xFFEF4444);
      case UserRole.EMPLOYER:
        return const Color(0xFFF59E0B);
      case UserRole.JOB_SEEKER:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }
}
