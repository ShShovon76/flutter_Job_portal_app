// features/job_seeker/presentation/profile/edit_job_seeker_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/features/job_seeker/provider/profile_provider.dart';
import 'package:job_portal_app/models/user_model.dart';
import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';

class EditJobSeekerProfileScreen extends StatefulWidget {
  const EditJobSeekerProfileScreen({super.key});

  @override
  State<EditJobSeekerProfileScreen> createState() =>
      _EditJobSeekerProfileScreenState();
}

class _EditJobSeekerProfileScreenState
    extends State<EditJobSeekerProfileScreen> {
  // ===================== CONTROLLERS =====================
  late TextEditingController _headlineController;
  late TextEditingController _summaryController;
  late TextEditingController _skillController;
  late TextEditingController _portfolioController;
  late TextEditingController _preferredJobTypeController;
  late TextEditingController _preferredLocationController;

  // ===================== FORM STATE =====================
  final _formKey = GlobalKey<FormState>();
  List<String> _skills = [];
  List<String> _portfolioLinks = [];
  List<String> _preferredJobTypes = [];
  List<String> _preferredLocations = [];

  // ===================== LOADING STATE =====================
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  // ===================== SKILL SUGGESTIONS =====================
  final List<String> _skillSuggestions = [
    'Flutter',
    'Dart',
    'JavaScript',
    'React',
    'Node.js',
    'Python',
    'Java',
    'Spring Boot',
    'SQL',
    'MongoDB',
    'AWS',
    'Docker',
    'Kubernetes',
    'Git',
    'Agile',
    'Scrum',
    'UI/UX',
    'Figma',
    'Project Management',
    'Leadership',
    'Communication',
    'Problem Solving',
  ];

  // ===================== JOB TYPE SUGGESTIONS =====================
  final List<String> _jobTypeSuggestions = [
    'FULL_TIME',
    'PART_TIME',
    'CONTRACT',
    'REMOTE',
    'INTERNSHIP',
    'FREELANCE',
  ];

  // ===================== LOCATION SUGGESTIONS =====================
  final List<String> _locationSuggestions = [
    'New York',
    'San Francisco',
    'Los Angeles',
    'Chicago',
    'Boston',
    'Seattle',
    'Austin',
    'Denver',
    'Miami',
    'Atlanta',
    'Remote',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadProfileData();
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _summaryController.dispose();
    _skillController.dispose();
    _portfolioController.dispose();
    _preferredJobTypeController.dispose();
    _preferredLocationController.dispose();
    super.dispose();
  }

  // ===================== INITIALIZATION =====================
  void _initializeControllers() {
    _headlineController = TextEditingController();
    _summaryController = TextEditingController();
    _skillController = TextEditingController();
    _portfolioController = TextEditingController();
    _preferredJobTypeController = TextEditingController();
    _preferredLocationController = TextEditingController();
  }

  void _loadProfileData() {
    final provider = Provider.of<JobSeekerProfileProvider>(
      context,
      listen: false,
    );
    final profile = provider.profile;

    if (profile != null) {
      _headlineController.text = profile.headline ?? '';
      _summaryController.text = profile.summary ?? '';
      _skills = List.from(profile.skills);
      _portfolioLinks = List.from(profile.portfolioLinks);
      _preferredJobTypes = List.from(profile.preferredJobTypes);
      _preferredLocations = List.from(profile.preferredLocations);
    }
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

    setState(() => _isLoading = true);

    try {
      final file = File(pickedFile.path);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profileProvider = Provider.of<JobSeekerProfileProvider>(
        context,
        listen: false,
      );

      await profileProvider.uploadProfilePicture(
        file: file,
        authProvider: authProvider,
      );

      if (mounted) {
        _showSnackBar('Profile picture updated successfully');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to update profile picture', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ===================== SKILLS MANAGEMENT =====================
  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isEmpty) return;

    if (_skills.contains(skill)) {
      _showSnackBar('Skill already added', isError: true);
      return;
    }

    setState(() {
      _skills.add(skill);
      _skillController.clear();
    });
  }

  void _removeSkill(int index) {
    setState(() {
      _skills.removeAt(index);
    });
  }

  // ===================== PORTFOLIO MANAGEMENT =====================
  void _addPortfolioLink() {
    final link = _portfolioController.text.trim();
    if (link.isEmpty) return;

    // Basic URL validation
    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      _showSnackBar(
        'Please enter a valid URL starting with http:// or https://',
        isError: true,
      );
      return;
    }

    if (_portfolioLinks.contains(link)) {
      _showSnackBar('Link already added', isError: true);
      return;
    }

    setState(() {
      _portfolioLinks.add(link);
      _portfolioController.clear();
    });
  }

  void _removePortfolioLink(int index) {
    setState(() {
      _portfolioLinks.removeAt(index);
    });
  }

  // ===================== PREFERRED JOB TYPES MANAGEMENT =====================
  void _addPreferredJobType() {
    final type = _preferredJobTypeController.text.trim().toUpperCase();
    if (type.isEmpty) return;

    if (_preferredJobTypes.contains(type)) {
      _showSnackBar('Job type already added', isError: true);
      return;
    }

    setState(() {
      _preferredJobTypes.add(type);
      _preferredJobTypeController.clear();
    });
  }

  void _removePreferredJobType(int index) {
    setState(() {
      _preferredJobTypes.removeAt(index);
    });
  }

  // ===================== PREFERRED LOCATIONS MANAGEMENT =====================
  void _addPreferredLocation() {
    final location = _preferredLocationController.text.trim();
    if (location.isEmpty) return;

    if (_preferredLocations.contains(location)) {
      _showSnackBar('Location already added', isError: true);
      return;
    }

    setState(() {
      _preferredLocations.add(location);
      _preferredLocationController.clear();
    });
  }

  void _removePreferredLocation(int index) {
    setState(() {
      _preferredLocations.removeAt(index);
    });
  }

  // ===================== SAVE PROFILE =====================
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final provider = Provider.of<JobSeekerProfileProvider>(
        context,
        listen: false,
      );
      final profile = provider.profile;

      if (profile == null) {
        throw Exception('Profile not found');
      }

      final updatedProfile = profile.copyWith(
        headline: _headlineController.text.isNotEmpty
            ? _headlineController.text
            : null,
        summary: _summaryController.text.isNotEmpty
            ? _summaryController.text
            : null,
        skills: _skills,
        portfolioLinks: _portfolioLinks,
        preferredJobTypes: _preferredJobTypes,
        preferredLocations: _preferredLocations,
      );

      // Note: You'll need to add this method to your provider
      await provider.saveProfile(updatedProfile);

      if (mounted) {
        _showSnackBar('Profile updated successfully');
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSaving = false;
      });
      _showSnackBar('Failed to update profile', isError: true);
    }
  }

  // ===================== UTILITY =====================
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

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return LoadingOverlay(
      isLoading: _isLoading || _isSaving,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          elevation: 0,
          actions: [
            TextButton(
              onPressed: _saveProfile,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('Save'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                _buildProfilePictureSection(user),

                const SizedBox(height: AppSizes.lg),

                // Headline
                _buildHeadlineSection(),

                const SizedBox(height: AppSizes.lg),

                // Summary
                _buildSummarySection(),

                const SizedBox(height: AppSizes.lg),

                // Skills
                _buildSkillsSection(),

                const SizedBox(height: AppSizes.lg),

                // Portfolio Links
                _buildPortfolioSection(),

                const SizedBox(height: AppSizes.lg),

                // Preferred Job Types
                _buildPreferredJobTypesSection(),

                const SizedBox(height: AppSizes.lg),

                // Preferred Locations
                _buildPreferredLocationsSection(),

                const SizedBox(height: AppSizes.xl),

                // Error Display
                if (_error != null) _buildErrorDisplay(),

                const SizedBox(height: AppSizes.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection(User? user) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primary,
                backgroundImage: user?.profilePictureUrl != null
                    ? NetworkImage(
                        AppConstants.getImageUrl(user!.profilePictureUrl),
                      )
                    : null,
                child: user?.profilePictureUrl == null
                    ? Text(
                        user?.fullName[0].toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    onPressed: _updateProfilePicture,
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            user?.fullName ?? 'User Name',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(
            user?.email ?? 'email@example.com',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadlineSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Professional Headline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),
            TextFormField(
              controller: _headlineController,
              decoration: const InputDecoration(
                hintText: 'e.g. Senior Flutter Developer at Tech Co.',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Professional Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),
            TextFormField(
              controller: _summaryController,
              decoration: const InputDecoration(
                hintText: 'Write a brief summary about yourself...',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              maxLength: 500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Skills',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),

            // Add Skill Input
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      hintText: 'Add a skill',
                      prefixIcon: Icon(Icons.add),
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _addSkill(),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                IconButton(
                  onPressed: _addSkill,
                  icon: const Icon(Icons.add_circle),
                  color: AppColors.primary,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.md),

            // Skills Tags
            if (_skills.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills.asMap().entries.map((entry) {
                  final index = entry.key;
                  final skill = entry.value;
                  return Chip(
                    label: Text(skill),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeSkill(index),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    labelStyle: TextStyle(color: AppColors.primary),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.md),
            ],

            // Skill Suggestions
            const Text(
              'Suggestions:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _skillSuggestions.map((skill) {
                if (_skills.contains(skill)) return const SizedBox();
                return ActionChip(
                  label: Text(skill),
                  onPressed: () {
                    setState(() {
                      if (!_skills.contains(skill)) {
                        _skills.add(skill);
                      }
                    });
                  },
                  backgroundColor: Colors.grey.shade200,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Portfolio Links',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),

            // Add Portfolio Link Input
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _portfolioController,
                    decoration: const InputDecoration(
                      hintText: 'https://your-portfolio.com',
                      prefixIcon: Icon(Icons.link),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.url,
                    onFieldSubmitted: (_) => _addPortfolioLink(),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                IconButton(
                  onPressed: _addPortfolioLink,
                  icon: const Icon(Icons.add_circle),
                  color: AppColors.primary,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.md),

            // Portfolio Links List
            if (_portfolioLinks.isNotEmpty) ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _portfolioLinks.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.link, size: 20),
                    title: Text(
                      _portfolioLinks[index],
                      style: const TextStyle(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => _removePortfolioLink(index),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreferredJobTypesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferred Job Types',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),

            // Add Job Type Input
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _preferredJobTypeController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. FULL_TIME, REMOTE',
                      prefixIcon: Icon(Icons.work),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onFieldSubmitted: (_) => _addPreferredJobType(),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                IconButton(
                  onPressed: _addPreferredJobType,
                  icon: const Icon(Icons.add_circle),
                  color: AppColors.primary,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.md),

            // Job Types Tags
            if (_preferredJobTypes.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _preferredJobTypes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final type = entry.value;
                  return Chip(
                    label: Text(type),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removePreferredJobType(index),
                    backgroundColor: Colors.green.withOpacity(0.1),
                    labelStyle: TextStyle(color: Colors.green),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.md),
            ],

            // Job Type Suggestions
            const Text(
              'Suggestions:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _jobTypeSuggestions.map((type) {
                if (_preferredJobTypes.contains(type)) return const SizedBox();
                return ActionChip(
                  label: Text(type),
                  onPressed: () {
                    setState(() {
                      if (!_preferredJobTypes.contains(type)) {
                        _preferredJobTypes.add(type);
                      }
                    });
                  },
                  backgroundColor: Colors.grey.shade200,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferredLocationsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferred Locations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),

            // Add Location Input
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _preferredLocationController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. New York, Remote',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _addPreferredLocation(),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                IconButton(
                  onPressed: _addPreferredLocation,
                  icon: const Icon(Icons.add_circle),
                  color: AppColors.primary,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.md),

            // Locations Tags
            if (_preferredLocations.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _preferredLocations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final location = entry.value;
                  return Chip(
                    label: Text(location),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removePreferredLocation(index),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    labelStyle: TextStyle(color: Colors.blue),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.md),
            ],

            // Location Suggestions
            const Text(
              'Suggestions:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _locationSuggestions.map((location) {
                if (_preferredLocations.contains(location))
                  return const SizedBox();
                return ActionChip(
                  label: Text(location),
                  onPressed: () {
                    setState(() {
                      if (!_preferredLocations.contains(location)) {
                        _preferredLocations.add(location);
                      }
                    });
                  },
                  backgroundColor: Colors.grey.shade200,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
