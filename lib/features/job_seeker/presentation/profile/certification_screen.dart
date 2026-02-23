// features/job_seeker/presentation/certifications/certifications_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/features/job_seeker/provider/profile_provider.dart';
import 'package:job_portal_app/models/job_seeker_profile.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class CertificationsScreen extends StatefulWidget {
  const CertificationsScreen({super.key});

  @override
  State<CertificationsScreen> createState() => _CertificationsScreenState();
}

class _CertificationsScreenState extends State<CertificationsScreen> {
  List<Certification> _certifications = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCertifications();
  }

  Future<void> _loadCertifications() async {
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
      await provider.loadCertifications();
      setState(() {
        _certifications = provider.profile?.certifications ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _addCertification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditCertificationScreen(),
      ),
    ).then((added) {
      if (added == true) {
        _loadCertifications();
      }
    });
  }

  void _editCertification(Certification certification) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddEditCertificationScreen(certification: certification),
      ),
    ).then((updated) {
      if (updated == true) {
        _loadCertifications();
      }
    });
  }

  Future<void> _deleteCertification(int index) async {
    final confirmed = await _showConfirmDialog(
      'Delete Certification',
      'Are you sure you want to delete this certification?',
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
      await provider.deleteCertification(_certifications[index].id!);

      setState(() {
        _certifications.removeAt(index);
        _isSubmitting = false;
      });

      _showSnackBar('Certification deleted successfully');
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnackBar('Failed to delete certification', isError: true);
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

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _isExpired(DateTime? expiryDate) {
    if (expiryDate == null) return 'No Expiry';
    final now = DateTime.now();
    return expiryDate.isAfter(now) ? 'Valid' : 'Expired';
  }

  Color _getExpiryColor(DateTime? expiryDate) {
    if (expiryDate == null) return Colors.green;
    final now = DateTime.now();
    return expiryDate.isAfter(now) ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading || _isSubmitting,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Certifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addCertification,
            ),
          ],
        ),
        body: _error != null
            ? _buildErrorState()
            : _certifications.isEmpty
            ? _buildEmptyState()
            : _buildCertificationList(),
      ),
    );
  }

  Widget _buildCertificationList() {
    return RefreshIndicator(
      onRefresh: _loadCertifications,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: _certifications.length,
        itemBuilder: (context, index) {
          final certification = _certifications[index];
          return _buildCertificationCard(certification, index);
        },
      ),
    );
  }

  Widget _buildCertificationCard(Certification certification, int index) {
    final expiryStatus = _isExpired(certification.expiryDate);
    final expiryColor = _getExpiryColor(certification.expiryDate);

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
                    Icons.verified,
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
                        certification.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        certification.issuer,
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
                      _editCertification(certification);
                    } else if (value == 'delete') {
                      _deleteCertification(index);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Issue Date
            Row(
              children: [
                Icon(Icons.event, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Issued: ${DateFormat('MMM yyyy').format(certification.issueDate)}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),

            // Expiry Date
            Row(
              children: [
                Icon(Icons.update, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  certification.expiryDate != null
                      ? 'Expires: ${DateFormat('MMM yyyy').format(certification.expiryDate!)}'
                      : 'No Expiry',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: expiryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    expiryStatus,
                    style: TextStyle(
                      fontSize: 11,
                      color: expiryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Credential URL
            if (certification.credentialUrl != null &&
                certification.credentialUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _launchUrl(certification.credentialUrl),
                child: Row(
                  children: [
                    Icon(Icons.link, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'View Credential',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
              Icons.verified_outlined,
              size: 80,
              color: AppColors.textDisabled.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Certifications Added',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your certifications to showcase your expertise',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Add Certification',
              onPressed: _addCertification,
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
              _error ?? 'Failed to load certifications',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Try Again',
              onPressed: _loadCertifications,
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}

// Add/Edit Certification Screen
class AddEditCertificationScreen extends StatefulWidget {
  final Certification? certification;

  const AddEditCertificationScreen({super.key, this.certification});

  @override
  State<AddEditCertificationScreen> createState() =>
      _AddEditCertificationScreenState();
}

class _AddEditCertificationScreenState
    extends State<AddEditCertificationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _issuerController;
  late TextEditingController _credentialUrlController;
  DateTime? _issueDate;
  DateTime? _expiryDate;
  bool _hasExpiry = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.certification?.title ?? '',
    );
    _issuerController = TextEditingController(
      text: widget.certification?.issuer ?? '',
    );
    _credentialUrlController = TextEditingController(
      text: widget.certification?.credentialUrl ?? '',
    );
    _issueDate = widget.certification?.issueDate ?? DateTime.now();
    _expiryDate = widget.certification?.expiryDate;
    _hasExpiry = widget.certification?.expiryDate != null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _issuerController.dispose();
    _credentialUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final initialDate = isIssueDate
        ? (_issueDate ?? DateTime.now().subtract(const Duration(days: 365)))
        : (_expiryDate ?? DateTime.now().add(const Duration(days: 365)));

    final firstDate = isIssueDate
        ? DateTime(1900)
        : (_issueDate ?? DateTime.now());
    final lastDate = isIssueDate
        ? DateTime.now()
        : DateTime.now().add(const Duration(days: 3650));

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
        if (isIssueDate) {
          _issueDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  Future<void> _saveCertification() async {
    if (!_formKey.currentState!.validate()) return;
    if (_issueDate == null) {
      _showSnackBar('Please select issue date', isError: true);
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

      final certification = Certification(
        id: widget.certification?.id,
        title: _titleController.text.trim(),
        issuer: _issuerController.text.trim(),
        issueDate: _issueDate!,
        expiryDate: _hasExpiry ? _expiryDate : null,
        credentialUrl: _credentialUrlController.text.isNotEmpty
            ? _credentialUrlController.text.trim()
            : null,
      );

      if (widget.certification == null) {
        await provider.addCertification(certification);
      } else {
        await provider.updateCertification(
          widget.certification!.id!,
          certification,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnackBar('Failed to save certification', isError: true);
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
            widget.certification == null
                ? 'Add Certification'
                : 'Edit Certification',
          ),
          elevation: 0,
          actions: [
            TextButton(
              onPressed: _saveCertification,
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
                // Certification Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Certification Title *',
                    hintText: 'e.g. AWS Certified Solutions Architect',
                    prefixIcon: Icon(Icons.verified),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Issuing Organization
                TextFormField(
                  controller: _issuerController,
                  decoration: const InputDecoration(
                    labelText: 'Issuing Organization *',
                    hintText: 'e.g. Amazon Web Services',
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Issuing organization is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Issue Date
                ListTile(
                  title: const Text('Issue Date *'),
                  subtitle: Text(
                    _issueDate == null
                        ? 'Select issue date'
                        : DateFormat('MMM yyyy').format(_issueDate!),
                  ),
                  leading: const Icon(Icons.event),
                  onTap: () => _selectDate(context, true),
                  tileColor: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),

                // Has Expiry Checkbox
                CheckboxListTile(
                  title: const Text('This certification has an expiry date'),
                  value: _hasExpiry,
                  onChanged: (value) {
                    setState(() {
                      _hasExpiry = value ?? false;
                      if (!_hasExpiry) {
                        _expiryDate = null;
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                ),

                // Expiry Date
                if (_hasExpiry)
                  ListTile(
                    title: const Text('Expiry Date'),
                    subtitle: Text(
                      _expiryDate == null
                          ? 'Select expiry date'
                          : DateFormat('MMM yyyy').format(_expiryDate!),
                    ),
                    leading: const Icon(Icons.update),
                    onTap: () => _selectDate(context, false),
                    tileColor: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                const SizedBox(height: 16),

                // Credential URL (Optional)
                TextFormField(
                  controller: _credentialUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Credential URL (Optional)',
                    hintText: 'https://example.com/credential',
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
