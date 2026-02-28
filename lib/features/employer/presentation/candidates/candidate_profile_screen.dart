// features/employer/presentation/candidates/candidate_profile_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/api/resume_api.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/core/constants/constants.dart';
import 'package:job_portal_app/features/job_seeker/provider/profile_provider.dart';
import 'package:job_portal_app/models/application_model.dart';
import 'package:job_portal_app/models/job_seeker_profile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class CandidateProfileScreen extends StatefulWidget {
  final int profileId;
  final int? jobId;

  const CandidateProfileScreen({super.key, required this.profileId, this.jobId});

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen>
    with SingleTickerProviderStateMixin {
  // ===================== STATE =====================
  ApplicantProfile? _profile;
  bool _isLoading = true;
  String? _error;

  // ===================== TAB CONTROLLER =====================
  late TabController _tabController;

  // ===================== RESUME PREVIEW =====================
  bool _isPreviewing = false;
  String? _previewPath;
  String? _previewFileName;
  int? _totalPages;
  int _currentPage = 0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cleanupPreview();
    super.dispose();
  }

  // ===================== DATA LOADING =====================
  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = Provider.of<JobSeekerProfileProvider>(
        context,
        listen: false,
      );
      await provider.loadApplicantProfile(widget.profileId);

      setState(() {
        _profile = provider.applicantProfile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ===================== RESUME ACTIONS =====================
  Future<void> _previewResume(Resume resume) async {
    setState(() {
      _isPreviewing = true;
      _previewFileName = resume.title;
    });

    try {
      final bytes = await ResumeApi.downloadResume(resume.id);
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/resume_${resume.id}.pdf';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(bytes);

      setState(() {
        _previewPath = tempPath;
      });
    } catch (e) {
      setState(() {
        _isPreviewing = false;
      });
      _showSnackBar('Failed to load resume preview', isError: true);
    }
  }

  Future<void> _downloadResume(Resume resume) async {
    setState(() => _isDownloading = true);

    try {
      final bytes = await ResumeApi.downloadResume(resume.id);

      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        final file = File('${directory?.path}/${resume.title}.pdf');
        await file.writeAsBytes(bytes);
        _showSnackBar('Downloaded to: ${file.path}');
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/${resume.title}.pdf');
        await file.writeAsBytes(bytes);
        _showSnackBar('Downloaded to: ${file.path}');
      } else {
        _showSnackBar('Download complete');
      }
    } catch (e) {
      _showSnackBar('Failed to download resume', isError: true);
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  void _closePreview() {
    _cleanupPreview();
    setState(() {
      _isPreviewing = false;
      _previewPath = null;
      _previewFileName = null;
      _totalPages = null;
      _currentPage = 0;
    });
  }

  void _cleanupPreview() {
    if (_previewPath != null) {
      File(_previewPath!).deleteSync();
    }
  }

  // ===================== UTILITY METHODS =====================
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

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null) return '';
    final startStr = DateFormat('MMM yyyy').format(start);
    final endStr = end != null ? DateFormat('MMM yyyy').format(end) : 'Present';
    return '$startStr - $endStr';
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Could not launch URL', isError: true);
    }
  }

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isPreviewing) {
          _closePreview();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: _isPreviewing
            ? AppBar(
                title: Text(
                  _previewFileName ?? 'Resume Preview',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _closePreview,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: _isDownloading
                        ? null
                        : () {
                            if (_profile?.resumes.isNotEmpty == true) {
                              _downloadResume(_profile!.resumes.first);
                            }
                          },
                  ),
                ],
              )
            : AppBar(
                title: const Text(
                  'Candidate Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                elevation: 0,
              ),
        body: _isPreviewing && _previewPath != null
            ? _buildPdfViewer()
            : _isLoading
            ? _buildLoadingView()
            : _error != null
            ? _buildErrorView()
            : _profile == null
            ? _buildEmptyView()
            : _buildProfileContent(),
      ),
    );
  }

  Widget _buildPdfViewer() {
    return Column(
      children: [
        // PDF Info Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _previewFileName ?? 'Resume',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_totalPages != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Page ${_currentPage + 1} of $_totalPages',
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),

        // PDF Viewer
        Expanded(
          child: PDFView(
            filePath: _previewPath!,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
            onRender: (pages) {
              setState(() {
                _totalPages = pages;
              });
            },
            onError: (error) {
              print(error.toString());
            },
            onPageError: (page, error) {
              print('$page: ${error.toString()}');
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                if (page != null) _currentPage = page;
              });
            },
          ),
        ),

        // PDF Controls (Mobile friendly)
        if (_totalPages != null && _totalPages! > 1)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  offset: const Offset(0, -1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPageButton(
                  icon: Icons.chevron_left,
                  enabled: _currentPage > 0,
                  onTap: () {},
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentPage + 1} / $_totalPages',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildPageButton(
                  icon: Icons.chevron_right,
                  enabled: _currentPage < (_totalPages! - 1),
                  onTap: () {},
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: enabled ? AppColors.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 48,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return Column(
      children: [
        // Profile Header - fixed height based on content
        _buildProfileHeader(),

        // Tabs - fixed height
        _buildTabs(),

        // Tab Content - takes remaining space
        Expanded(
          child: Container(
            color: Colors.white,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildExperienceTab(),
                _buildEducationTab(),
                _buildCertificationsTab(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: _profile!.profilePictureUrl != null
                ? NetworkImage(
                    AppConstants.getImageUrl(_profile!.profilePictureUrl!),
                  )
                : null,
            child: _profile!.profilePictureUrl == null
                ? Text(
                    _profile!.fullName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppSizes.md),

          // Name
          Text(
            _profile!.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            _profile!.email,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),

          // Phone (if available)
          if (_profile!.phone != null) ...[
            Text(
              _profile!.phone!,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
          ],

          // Headline (if available)
          if (_profile!.headline != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _profile!.headline!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSizes.md),

          // Resume Button (if available)
          if (_profile!.resumes.isNotEmpty) _buildResumeButton(),
        ],
      ),
    );
  }

  Widget _buildResumeButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Resume',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _profile!.resumes.map((resume) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: _buildResumeChip(resume),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeChip(Resume resume) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            resume.title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          if (resume.primaryResume)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Primary',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () => _previewResume(resume),
            icon: const Icon(Icons.visibility, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: AppColors.primary,
          ),
          IconButton(
            onPressed: () => _downloadResume(resume),
            icon: const Icon(Icons.download, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: const [
          Tab(text: 'Summary'),
          Tab(text: 'Experience'),
          Tab(text: 'Education'),
          Tab(text: 'Certifications'),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: Color(0xFF64748B),
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          if (_profile!.summary != null) ...[
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              width: double.infinity,
              child: Text(
                _profile!.summary!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Skills
          const Text(
            'Skills',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          if (_profile!.skills.isEmpty)
            const Text(
              'No skills listed',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _profile!.skills.map((skill) {
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
                    skill,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),

          // Preferred Job Types
          if (_profile!.preferredJobTypes.isNotEmpty) ...[
            const Text(
              'Preferred Job Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _profile!.preferredJobTypes.map((type) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Preferred Locations
          if (_profile!.preferredLocations.isNotEmpty) ...[
            const Text(
              'Preferred Locations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _profile!.preferredLocations.map((location) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    location,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExperienceTab() {
    if (_profile!.experience.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No experience added yet',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _profile!.experience.length,
      itemBuilder: (context, index) {
        final exp = _profile!.experience[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exp.jobTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                exp.companyName,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateRange(exp.startDate, exp.endDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                exp.responsibilities,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (index < _profile!.experience.length - 1)
                const Divider(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEducationTab() {
    if (_profile!.education.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No education added yet',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _profile!.education.length,
      itemBuilder: (context, index) {
        final edu = _profile!.education[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                edu.degree,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                edu.institution,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateRange(edu.startDate, edu.endDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (edu.grade != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.grade, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Grade: ${edu.grade}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
              if (index < _profile!.education.length - 1)
                const Divider(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCertificationsTab() {
    if (_profile!.certifications.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No certifications added yet',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _profile!.certifications.length,
      itemBuilder: (context, index) {
        final cert = _profile!.certifications[index];
        final isExpired =
            cert.expiryDate != null &&
            cert.expiryDate!.isBefore(DateTime.now());

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cert.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cert.issuer,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.event, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Issued: ${_formatDate(cert.issueDate)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (cert.expiryDate != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.update,
                      size: 12,
                      color: isExpired ? Colors.red : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expires: ${_formatDate(cert.expiryDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isExpired ? Colors.red : Colors.grey.shade600,
                        fontWeight: isExpired
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
              if (cert.credentialUrl != null) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _launchUrl(cert.credentialUrl!),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.link,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'View Credential',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (index < _profile!.certifications.length - 1)
                const Divider(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Failed to load profile',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            const Text(
              'Profile Not Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The candidate profile could not be found',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
