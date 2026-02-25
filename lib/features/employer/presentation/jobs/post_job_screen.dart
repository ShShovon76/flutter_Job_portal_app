// screens/employer/job_post_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/api/company_api.dart';
import 'package:job_portal_app/core/api/job_api.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/services/category-service.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/features/job_seeker/provider/job_provider.dart';
import 'package:job_portal_app/models/category.dart';
import 'package:job_portal_app/models/company_model.dart';
import 'package:job_portal_app/models/job_model.dart';
import 'package:job_portal_app/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobPostScreen extends StatefulWidget {
  final int? jobId;
  const JobPostScreen({super.key, this.jobId});

  @override
  State<JobPostScreen> createState() => _JobPostScreenState();
}

class _JobPostScreenState extends State<JobPostScreen> {
  // ---------------------------
  // FORM STATE
  // ---------------------------
  final _formKey = GlobalKey<FormState>();
  final _companyApi = CompanyApi();
  final _categoryService = CategoryService();

  User? currentUser;
  List<Company> companies = [];
  List<Category> categories = [];
  bool _isEditMode = false;
  Job? _editingJob;

  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _minSalaryController;
  late TextEditingController _maxSalaryController;
  late TextEditingController _deadlineController;
  late TextEditingController _skillController;

  // Form values
  int? selectedCompanyId;
  int? selectedCategoryId;
  JobType selectedJobType = JobType.FULL_TIME;
  ExperienceLevel selectedExperienceLevel = ExperienceLevel.MID;
  SalaryType selectedSalaryType = SalaryType.YEARLY;
  bool remoteAllowed = false;
  List<String> skills = [];

  // UI State
  bool isLoading = false;
  bool isSubmitting = false;
  bool showSuccess = false;

  // Enums for dropdowns
  final List<JobType> jobTypes = JobType.values;
  final List<ExperienceLevel> experienceLevels = ExperienceLevel.values;
  final List<SalaryType> salaryTypes = SalaryType.values;

  // Skill suggestions
  final List<String> skillSuggestions = [
    'JavaScript',
    'Dart',
    'Flutter',
    'React',
    'Vue.js',
    'Node.js',
    'Java',
    'Spring Boot',
    'Python',
    'Django',
    'SQL',
    'MongoDB',
    'AWS',
    'Docker',
    'Kubernetes',
    'Git',
    'Agile',
    'Scrum',
    'REST API',
    'TypeScript',
    'Angular',
    'Firebase',
    'TensorFlow',
    'Machine Learning',
    'UI/UX',
    'Figma',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _isEditMode = widget.jobId != null;
    _loadInitialData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _deadlineController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  // ---------------------------
  // INITIALIZATION
  // ---------------------------
  void _initializeControllers() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _minSalaryController = TextEditingController();
    _maxSalaryController = TextEditingController();
    _deadlineController = TextEditingController(
      text: DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now().add(const Duration(days: 30))),
    );
    _skillController = TextEditingController();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      currentUser = authProvider.user;

      if (currentUser == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      await Future.wait([_loadCompanies(), _loadCategories()]);
      if (_isEditMode && widget.jobId != null) {
        await _loadJobForEdit(widget.jobId!);
      } else {
        // Only load draft if not in edit mode
        _loadDraft();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadJobForEdit(int jobId) async {
    try {
      final job = await JobApi.getJobById(jobId);

      setState(() {
        _editingJob = job;

        // Populate all form fields with job data
        selectedCompanyId = job.company.id;
        selectedCategoryId = job.category.id;
        _titleController.text = job.title;
        _descriptionController.text = job.description;
        selectedJobType = job.jobType;
        selectedExperienceLevel = job.experienceLevel;

        if (job.minSalary != null) {
          _minSalaryController.text = job.minSalary!.toString();
        }
        if (job.maxSalary != null) {
          _maxSalaryController.text = job.maxSalary!.toString();
        }
        selectedSalaryType = job.salaryType;
        _locationController.text = job.location;
        remoteAllowed = job.remoteAllowed;
        skills = List.from(job.skills);
        _deadlineController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(job.deadline);
      });
    } catch (e) {
      debugPrint('Error loading job for edit: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load job: $e')));
      }
    }
  }

  Future<void> _loadCompanies() async {
    try {
      final response = await _companyApi.getCompaniesByOwner(
        ownerId: currentUser!.id,
        page: 0,
        size: 20,
      );

      setState(() {
        companies = response.items;
        if (companies.length == 1) {
          selectedCompanyId = companies.first.id;
        }
      });
    } catch (e) {
      debugPrint('Error loading companies: $e');
      setState(() => companies = []);

      if (e.toString().contains('401') && mounted) {
        _showSessionExpiredDialog();
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesList = await _categoryService.getAllCategories();
      setState(() {
        categories = categoriesList;
        if (categories.isNotEmpty && selectedCategoryId == null) {
          selectedCategoryId = categories.first.id;
        }
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() => categories = []);
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please login again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // SKILLS MANAGEMENT
  // ---------------------------
  void _addSkill([String? skill]) {
    final value = (skill ?? _skillController.text).trim();
    if (value.isEmpty) return;

    final exists = skills.any((s) => s.toLowerCase() == value.toLowerCase());
    if (exists) {
      _skillController.clear();
      return;
    }

    setState(() {
      skills.add(value);
      _skillController.clear();
    });
  }

  void _removeSkill(int index) {
    setState(() {
      skills.removeAt(index);
    });
  }

  // ---------------------------
  // DRAFT MANAGEMENT
  // ---------------------------
  void _saveAsDraft() async {
    if (currentUser == null) return;

    final draft = {
      'companyId': selectedCompanyId,
      'categoryId': selectedCategoryId,
      'title': _titleController.text,
      'description': _descriptionController.text,
      'jobType': selectedJobType.name,
      'experienceLevel': selectedExperienceLevel.name,
      'minSalary': _minSalaryController.text.isEmpty
          ? null
          : double.tryParse(_minSalaryController.text),
      'maxSalary': _maxSalaryController.text.isEmpty
          ? null
          : double.tryParse(_maxSalaryController.text),
      'salaryType': selectedSalaryType.name,
      'location': _locationController.text,
      'remoteAllowed': remoteAllowed,
      'skills': skills,
      'deadline': _deadlineController.text,
      'draftSavedAt': DateTime.now().toIso8601String(),
      'employerId': currentUser!.id,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('job_draft_${currentUser!.id}', jsonEncode(draft));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job saved as draft. You can continue later.'),
        ),
      );
    }
  }

  void _loadDraft() async {
    if (currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    final draftData = prefs.getString('job_draft_${currentUser!.id}');

    if (draftData != null) {
      try {
        final draft = jsonDecode(draftData);
        setState(() {
          selectedCompanyId = draft['companyId'];
          selectedCategoryId = draft['categoryId'];
          _titleController.text = draft['title'] ?? '';
          _descriptionController.text = draft['description'] ?? '';
          selectedJobType =
              _jobTypeFromString(draft['jobType']) ?? JobType.FULL_TIME;
          selectedExperienceLevel =
              _experienceLevelFromString(draft['experienceLevel']) ??
              ExperienceLevel.MID;
          _minSalaryController.text = draft['minSalary']?.toString() ?? '';
          _maxSalaryController.text = draft['maxSalary']?.toString() ?? '';
          selectedSalaryType =
              _salaryTypeFromString(draft['salaryType']) ?? SalaryType.YEARLY;
          _locationController.text = draft['location'] ?? '';
          remoteAllowed = draft['remoteAllowed'] ?? false;
          _deadlineController.text =
              draft['deadline'] ??
              DateFormat(
                'yyyy-MM-dd',
              ).format(DateTime.now().add(const Duration(days: 30)));

          if (draft['skills'] != null) {
            skills = List<String>.from(draft['skills']);
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Draft loaded successfully!')),
          );
        }
      } catch (e) {
        debugPrint('Error loading draft: $e');
      }
    }
  }

  void _clearDraft() async {
    if (currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('job_draft_${currentUser!.id}');
  }

  // ---------------------------
  // HELPER METHODS FOR ENUM PARSING
  // ---------------------------
  JobType? _jobTypeFromString(String? value) {
    if (value == null) return null;
    try {
      return JobType.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }

  ExperienceLevel? _experienceLevelFromString(String? value) {
    if (value == null) return null;
    try {
      return ExperienceLevel.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }

  SalaryType? _salaryTypeFromString(String? value) {
    if (value == null) return null;
    try {
      return SalaryType.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }

  String _formatEnumName(String name) {
    return name
        .split('_')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // ---------------------------
  // VALIDATION
  // ---------------------------
  bool _validateSalary() {
    final minSalaryText = _minSalaryController.text;
    final maxSalaryText = _maxSalaryController.text;

    if (minSalaryText.isEmpty || maxSalaryText.isEmpty) return true;

    final minSalary = double.tryParse(minSalaryText);
    final maxSalary = double.tryParse(maxSalaryText);

    if (minSalary != null && maxSalary != null) {
      return minSalary <= maxSalary;
    }
    return true;
  }

  bool _validateDeadline() {
    try {
      final deadline = DateTime.parse(_deadlineController.text);
      final today = DateTime.now();
      return deadline.isAfter(today) ||
          DateFormat('yyyy-MM-dd').format(deadline) ==
              DateFormat('yyyy-MM-dd').format(today);
    } catch (e) {
      return false;
    }
  }

  List<String> _getFormErrors() {
    final errors = <String>[];

    if (!_validateSalary()) {
      errors.add(
        'Minimum salary must be less than or equal to maximum salary.',
      );
    }
    if (!_validateDeadline()) {
      errors.add('Deadline must be today or in the future.');
    }
    if (skills.isEmpty) {
      errors.add('Please add at least one skill.');
    }
    if (selectedCompanyId == null) {
      errors.add('Please select a company.');
    }
    if (selectedCategoryId == null) {
      errors.add('Please select a category.');
    }
    return errors;
  }

  // ---------------------------
  // FORM SUBMISSION
  // ---------------------------
  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    final formErrors = _getFormErrors();
    if (formErrors.isNotEmpty) {
      _showErrorDialog('Please fix the following errors:', formErrors);
      return;
    }

    if (currentUser == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() => isSubmitting = true);

    try {
      if (_isEditMode && _editingJob != null) {
        // UPDATE MODE
        final request = JobUpdateRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryId: selectedCategoryId,
          jobType: selectedJobType,
          experienceLevel: selectedExperienceLevel,
          minSalary: _minSalaryController.text.isEmpty
              ? null
              : double.parse(_minSalaryController.text),
          maxSalary: _maxSalaryController.text.isEmpty
              ? null
              : double.parse(_maxSalaryController.text),
          salaryType: selectedSalaryType,
          location: _locationController.text.trim(),
          remoteAllowed: remoteAllowed,
          skills: skills.map((s) => s.trim()).toList(),
          deadline: DateTime.parse(_deadlineController.text),
        );

        final updatedJob = await JobApi.updateJob(
          jobId: _editingJob!.id,
          request: request,
          employerId: currentUser!.id,
        );

        // Update job in provider
        final jobProvider = Provider.of<JobProvider>(context, listen: false);
        await jobProvider.updateJobInList(updatedJob);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context, updatedJob); // Return to previous screen
        }
      } else {
        // CREATE MODE (existing code)
        final request = JobCreateRequest(
          companyId: selectedCompanyId!,
          categoryId: selectedCategoryId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          jobType: selectedJobType,
          experienceLevel: selectedExperienceLevel,
          minSalary: _minSalaryController.text.isEmpty
              ? null
              : double.parse(_minSalaryController.text),
          maxSalary: _maxSalaryController.text.isEmpty
              ? null
              : double.parse(_maxSalaryController.text),
          salaryType: selectedSalaryType,
          location: _locationController.text.trim(),
          remoteAllowed: remoteAllowed,
          skills: skills.map((s) => s.trim()).toList(),
          deadline: DateTime.parse(_deadlineController.text),
        );

        final createdJob = await JobApi.createJob(
          request: request,
          employerId: currentUser!.id,
        );

        _clearDraft();
        setState(() => showSuccess = true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job posted successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacementNamed(
                context,
                '/employer/manage-jobs',
                arguments: {'created': true, 'jobId': createdJob.id},
              );
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error submitting job: $e');

      String errorMessage = _isEditMode
          ? 'Failed to update job. Please try again.'
          : 'Failed to create job. Please try again.';

      if (e.toString().contains('401')) {
        errorMessage = 'Your session has expired. Please login again.';
        _showSessionExpiredDialog();
      } else if (e.toString().contains('403')) {
        errorMessage =
            'You are not authorized to ${_isEditMode ? 'update' : 'create'} jobs for this company.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Job or company not found. Please check your selection.';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid job data. Please check all fields.';
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _showErrorDialog(String title, List<String> errors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e)),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // UI HELPERS
  // ---------------------------
  double _getCompletionPercentage() {
    int completedFields = 0;
    if (selectedCompanyId != null) completedFields++;
    if (selectedCategoryId != null) completedFields++;
    if (_titleController.text.isNotEmpty) completedFields++;
    if (_descriptionController.text.length >= 100) completedFields++;
    completedFields++; // Job type
    completedFields++; // Experience level
    if (_locationController.text.isNotEmpty) completedFields++;
    if (skills.isNotEmpty) completedFields++;
    if (_minSalaryController.text.isNotEmpty ||
        _maxSalaryController.text.isNotEmpty)
      completedFields++;
    if (_deadlineController.text.isNotEmpty) completedFields++;

    const totalFields = 10;
    return (completedFields / totalFields * 100).roundToDouble();
  }

  // ---------------------------
  // BUILD UI - SINGLE SCREEN MOBILE DESIGN
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Job' : 'Post a Job'),
        elevation: 0,
        actions: [
          if (!_isEditMode)
            TextButton.icon(
              onPressed: _saveAsDraft,
              icon: const Icon(Icons.save),
              label: const Text('Save Draft'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
        ],
      ),
      body: isLoading || isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : showSuccess
          ? _buildSuccessView()
          : _buildMobileFormView(),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Job Posted Successfully!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your job is now live and visible to candidates.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/employer/manage-jobs',
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('View My Jobs'),
            ),
          ],
        ),
      ),
    );
  }

  // SINGLE SCROLLABLE MOBILE FORM
  Widget _buildMobileFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Tracker
            _buildProgressTracker(),
            const SizedBox(height: 20),

            // Basic Information
            _buildBasicInfoSection(),
            const SizedBox(height: 16),

            // Job Details
            _buildJobDetailsSection(),
            const SizedBox(height: 16),

            // Salary Information
            _buildSalarySection(),
            const SizedBox(height: 16),

            // Location
            _buildLocationSection(),
            const SizedBox(height: 16),

            // Skills
            _buildSkillsSection(),
            const SizedBox(height: 16),

            // Deadline
            _buildDeadlineSection(),
            const SizedBox(height: 24),

            // Tips Section (Moved from sidebar)
            _buildTipsSection(),
            const SizedBox(height: 24),

            // Submit Buttons
            _buildSubmitButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Basic Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

            // Company Dropdown - FIXED
            DropdownButtonFormField<int>(
              value: selectedCompanyId,
              decoration: const InputDecoration(
                labelText: 'Company *',
                hintText: 'Select a company',
                prefixIcon: Icon(Icons.business, size: 20),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              isExpanded: true, // ADD THIS
              items: companies.isEmpty
                  ? [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('No companies available'),
                      ),
                    ]
                  : companies.map((company) {
                      return DropdownMenuItem<int>(
                        value: company.id,
                        child: Container(
                          // WRAP WITH CONTAINER
                          constraints: const BoxConstraints(
                            maxWidth: 220,
                          ), // LIMIT WIDTH
                          child: Text(
                            company.name,
                            overflow: TextOverflow.ellipsis, // ADD ELLIPSIS
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      );
                    }).toList(),
              onChanged: (value) {
                setState(() => selectedCompanyId = value);
              },
              validator: (value) {
                if (value == null) return 'Please select a company';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category Dropdown - FIXED
            DropdownButtonFormField<int>(
              value: selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Category *',
                hintText: 'Select a category',
                prefixIcon: Icon(Icons.category, size: 20),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              isExpanded: true, // ADD THIS
              items: categories.isEmpty
                  ? [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('No categories available'),
                      ),
                    ]
                  : categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Container(
                          // WRAP WITH CONTAINER
                          constraints: const BoxConstraints(
                            maxWidth: 220,
                          ), // LIMIT WIDTH
                          child: Text(
                            category.name,
                            overflow: TextOverflow.ellipsis, // ADD ELLIPSIS
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      );
                    }).toList(),
              onChanged: (value) {
                setState(() => selectedCategoryId = value);
              },
              validator: (value) {
                if (value == null) return 'Please select a category';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Job Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Job Title *',
                hintText: 'e.g. Senior Flutter Developer',
                prefixIcon: Icon(Icons.title, size: 20),
                helperText: '5-200 characters',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              maxLength: 200,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Job title is required';
                }
                if (value.trim().length < 5) {
                  return 'Job title must be at least 5 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDetailsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Job Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

            // Job Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Job Description *',
                hintText:
                    'Describe the role, responsibilities, and requirements...',
                prefixIcon: Icon(Icons.text_snippet, size: 20),
                helperText: 'Minimum 50 characters',
                alignLabelWithHint: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: 6,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Job description is required';
                }
                if (value.trim().length < 50) {
                  return 'Description must be at least 100 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Job Type & Experience Level - Column for mobile
            DropdownButtonFormField<JobType>(
              value: selectedJobType,
              decoration: const InputDecoration(
                labelText: 'Job Type *',
                prefixIcon: Icon(Icons.work_outline, size: 20),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: jobTypes.map((type) {
                return DropdownMenuItem<JobType>(
                  value: type,
                  child: Text(_formatEnumName(type.name)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedJobType = value!;
                  if (value == JobType.FREELANCE || value == JobType.CONTRACT) {
                    selectedSalaryType = SalaryType.HOURLY;
                  }
                });
              },
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<ExperienceLevel>(
              value: selectedExperienceLevel,
              decoration: const InputDecoration(
                labelText: 'Experience Level *',
                prefixIcon: Icon(Icons.trending_up, size: 20),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: experienceLevels.map((level) {
                return DropdownMenuItem<ExperienceLevel>(
                  value: level,
                  child: Text(_formatEnumName(level.name)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedExperienceLevel = value!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalarySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Salary Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

            // Column layout for mobile
            TextFormField(
              controller: _minSalaryController,
              decoration: const InputDecoration(
                labelText: 'Minimum Salary',
                hintText: '0',
                prefixIcon: Icon(Icons.trending_down, size: 20),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _maxSalaryController,
              decoration: const InputDecoration(
                labelText: 'Maximum Salary',
                hintText: '0',
                prefixIcon: Icon(Icons.trending_up, size: 20),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<SalaryType>(
              value: selectedSalaryType,
              decoration: const InputDecoration(
                labelText: 'Salary Period *',
                prefixIcon: Icon(Icons.timer, size: 20),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: salaryTypes.map((type) {
                return DropdownMenuItem<SalaryType>(
                  value: type,
                  child: Text(_formatEnumName(type.name)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedSalaryType = value!);
              },
            ),

            if (!_validateSalary())
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Minimum salary must be less than maximum salary',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location *',
                hintText: 'e.g. New York, NY or Remote',
                prefixIcon: Icon(Icons.location_city, size: 20),
                helperText: 'Maximum 100 characters',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Location is required';
                }
                return null;
              },
            ),

            Row(
              children: [
                Checkbox(
                  value: remoteAllowed,
                  onChanged: (value) {
                    setState(() => remoteAllowed = value ?? false);
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 4),
                const Text('Remote work allowed'),
              ],
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.build,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Required Skills',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

            // Add Skill - Column for mobile
            TextFormField(
              controller: _skillController,
              decoration: InputDecoration(
                hintText: 'e.g. Flutter, Dart, Firebase...',
                prefixIcon: const Icon(Icons.add, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () => _addSkill(),
                  color: Theme.of(context).primaryColor,
                ),
                helperText: 'Press enter or tap + to add skill',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onFieldSubmitted: (_) => _addSkill(),
            ),
            const SizedBox(height: 16),

            // Skill Tags
            if (skills.isNotEmpty) ...[
              Container(
                constraints: const BoxConstraints(maxHeight: 100),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skills.asMap().entries.map((entry) {
                      final index = entry.key;
                      final skill = entry.value;
                      return Chip(
                        label: Text(skill),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeSkill(index),
                        backgroundColor: Colors.blue.shade50,
                        labelStyle: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 12,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],

            if (skills.isEmpty &&
                _getFormErrors().contains('Please add at least one skill.'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'At least one skill is required',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Skill Suggestions
            if (skillSuggestions.isNotEmpty) ...[
              const Text(
                'Suggestions:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 120),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: skillSuggestions.map((skill) {
                      return ActionChip(
                        label: Text(
                          skill,
                          style: const TextStyle(fontSize: 11),
                        ),
                        onPressed: () => _addSkill(skill),
                        backgroundColor: Colors.grey.shade200,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Application Deadline',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

            TextFormField(
              controller: _deadlineController,
              decoration: const InputDecoration(
                labelText: 'Deadline *',
                hintText: 'YYYY-MM-DD',
                prefixIcon: Icon(Icons.calendar_today, size: 20),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(_deadlineController.text),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _deadlineController.text = DateFormat(
                      'yyyy-MM-dd',
                    ).format(date);
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Deadline is required';
                }
                if (!_validateDeadline()) {
                  return 'Deadline must be today or in the future';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Tips for better responses',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(4, (index) {
              final icons = [
                Icons.campaign,
                Icons.attach_money,
                Icons.list,
                Icons.access_time,
              ];
              final colors = [
                Colors.blue,
                Colors.green,
                Colors.purple,
                Colors.orange,
              ];
              final titles = [
                'Clear Job Title',
                'Include Salary',
                'List Key Skills',
                'Set Deadline',
              ];
              final descriptions = [
                'Be specific about the role and level',
                'Jobs with salary get more applications',
                'Mention specific technologies required',
                'Give candidates time to apply',
              ];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icons[index], size: 18, color: colors[index]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titles[index],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            descriptions[index],
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTracker() {
    final percentage = _getCompletionPercentage();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Job Completion',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${percentage.round()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              color: Colors.blue,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _submitJob,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: _isEditMode
                  ? AppColors.primary
                  : Colors.green, // Dynamic color
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _isEditMode ? 'UPDATE JOB' : 'POST JOB', // Dynamic text
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _isEditMode
                ? () =>
                      Navigator.pop(context) // Cancel/Go back in edit mode
                : _saveAsDraft, // Save draft in create mode
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(
                color: _isEditMode ? Colors.red.shade300 : Colors.grey.shade400,
              ),
              foregroundColor: _isEditMode ? Colors.red : null,
            ),
            child: Text(
              _isEditMode ? 'CANCEL' : 'SAVE DRAFT', // Dynamic text
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
