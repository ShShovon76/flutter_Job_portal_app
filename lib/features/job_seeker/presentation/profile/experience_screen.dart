// features/job_seeker/presentation/experience/experience_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/features/job_seeker/provider/profile_provider.dart';
import 'package:job_portal_app/models/job_seeker_profile.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';

class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({super.key});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  List<Experience> _experiences = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExperiences();
  }

  Future<void> _loadExperiences() async {
    final provider = Provider.of<JobSeekerProfileProvider>(
      context,
      listen: false,
    );
    final userId = provider.profile?.userId;

    if (userId == null) {
      setState(() {
        _error = 'User not found';
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      await provider.loadExperiences();
      setState(() {
        _experiences = provider.profile?.experience ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _addExperience() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditExperienceScreen()),
    ).then((added) {
      if (added == true) {
        _loadExperiences();
      }
    });
  }

  void _editExperience(Experience experience) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExperienceScreen(experience: experience),
      ),
    ).then((updated) {
      if (updated == true) {
        _loadExperiences();
      }
    });
  }

  Future<void> _deleteExperience(int index) async {
    final confirmed = await _showConfirmDialog(
      'Delete Experience',
      'Are you sure you want to delete this work experience?',
    );

    if (!confirmed) return;

    final provider = Provider.of<JobSeekerProfileProvider>(
      context,
      listen: false,
    );
    final userId = provider.profile?.userId;

    if (userId == null) return;

    setState(() => _isSubmitting = true);

    try {
      await provider.deleteExperience(_experiences[index].hashCode);

      setState(() {
        _experiences.removeAt(index);
        _isSubmitting = false;
      });

      _showSnackBar('Experience deleted successfully');
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnackBar('Failed to delete experience', isError: true);
    }
  }

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
            child: const Text('Delete'),
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

  String _formatDateRange(DateTime? start, DateTime? end) {
    final startStr = start != null ? DateFormat('MMM yyyy').format(start) : '';
    final endStr = end != null ? DateFormat('MMM yyyy').format(end) : 'Present';
    return '$startStr - $endStr';
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading || _isSubmitting,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Work Experience',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          elevation: 0,
          actions: [
            IconButton(icon: const Icon(Icons.add), onPressed: _addExperience),
          ],
        ),
        body: _error != null
            ? _buildErrorState()
            : _experiences.isEmpty
            ? _buildEmptyState()
            : _buildExperienceList(),
      ),
    );
  }

  Widget _buildExperienceList() {
    return RefreshIndicator(
      onRefresh: _loadExperiences,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: _experiences.length,
        itemBuilder: (context, index) {
          final experience = _experiences[index];
          return _buildExperienceCard(experience, index);
        },
      ),
    );
  }

  Widget _buildExperienceCard(Experience experience, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.work,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        experience.jobTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        experience.companyName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editExperience(experience);
                    } else if (value == 'delete') {
                      _deleteExperience(index);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date Range
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateRange(experience.startDate, experience.endDate),
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Responsibilities
            Text(
              'Responsibilities:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              experience.responsibilities,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
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
              Icons.work_outline,
              size: 80,
              color: AppColors.textDisabled.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Experience Added',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your work experience to showcase your career journey',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Add Experience',
              onPressed: _addExperience,
              width: 200,
            ),
          ],
        ),
      ),
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
              _error ?? 'Failed to load experience',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Try Again',
              onPressed: _loadExperiences,
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}

// Add/Edit Experience Screen
class AddEditExperienceScreen extends StatefulWidget {
  final Experience? experience;

  const AddEditExperienceScreen({super.key, this.experience});

  @override
  State<AddEditExperienceScreen> createState() =>
      _AddEditExperienceScreenState();
}

class _AddEditExperienceScreenState extends State<AddEditExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _jobTitleController;
  late TextEditingController _companyNameController;
  late TextEditingController _responsibilitiesController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrentlyWorking = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _jobTitleController = TextEditingController(
      text: widget.experience?.jobTitle ?? '',
    );
    _companyNameController = TextEditingController(
      text: widget.experience?.companyName ?? '',
    );
    _responsibilitiesController = TextEditingController(
      text: widget.experience?.responsibilities ?? '',
    );
    _startDate = widget.experience?.startDate;
    _endDate = widget.experience?.endDate;
    _isCurrentlyWorking = widget.experience?.endDate == null;
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyNameController.dispose();
    _responsibilitiesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now().subtract(const Duration(days: 365 * 2)))
        : (_endDate ?? DateTime.now());

    final firstDate = isStart ? DateTime(1900) : (_startDate ?? DateTime(1900));
    final lastDate = isStart ? DateTime.now() : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveExperience() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      _showSnackBar('Please select start date', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final provider = Provider.of<JobSeekerProfileProvider>(
        context,
        listen: false,
      );
      final userId = provider.profile?.userId;

      if (userId == null) {
        _showSnackBar('User not found', isError: true);
        return;
      }

      final experience = Experience(
        id: widget.experience?.id,
        jobTitle: _jobTitleController.text.trim(),
        companyName: _companyNameController.text.trim(),
        startDate: _startDate!,
        endDate: _isCurrentlyWorking ? null : _endDate,
        responsibilities: _responsibilitiesController.text.trim(),
      );

      if (widget.experience == null) {
        await provider.addExperience(experience);
      } else {
        await provider.updateExperience(widget.experience!.id!, experience);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnackBar('Failed to save experience', isError: true);
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

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isSubmitting,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.experience == null ? 'Add Experience' : 'Edit Experience',
          ),
          elevation: 0,
          actions: [
            TextButton(
              onPressed: _saveExperience,
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
                // Job Title
                TextFormField(
                  controller: _jobTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Job Title *',
                    hintText: 'e.g. Senior Software Engineer',
                    prefixIcon: Icon(Icons.work),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Job title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Company Name
                TextFormField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Company Name *',
                    hintText: 'e.g. Google, Microsoft, etc.',
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Company name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Start Date
                ListTile(
                  title: const Text('Start Date *'),
                  subtitle: Text(
                    _startDate == null
                        ? 'Select start date'
                        : DateFormat('MMM yyyy').format(_startDate!),
                  ),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, true),
                  tileColor: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),

                // Currently Working Checkbox
                CheckboxListTile(
                  title: const Text('I am currently working here'),
                  value: _isCurrentlyWorking,
                  onChanged: (value) {
                    setState(() {
                      _isCurrentlyWorking = value ?? false;
                      if (_isCurrentlyWorking) {
                        _endDate = null;
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                ),

                // End Date
                if (!_isCurrentlyWorking)
                  ListTile(
                    title: const Text('End Date *'),
                    subtitle: Text(
                      _endDate == null
                          ? 'Select end date'
                          : DateFormat('MMM yyyy').format(_endDate!),
                    ),
                    leading: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                    tileColor: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                const SizedBox(height: 16),

                // Responsibilities
                TextFormField(
                  controller: _responsibilitiesController,
                  decoration: const InputDecoration(
                    labelText: 'Responsibilities *',
                    hintText:
                        'Describe your key responsibilities and achievements...',
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Responsibilities are required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
