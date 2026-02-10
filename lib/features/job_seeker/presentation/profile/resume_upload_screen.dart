import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';


class ResumeUploadScreen extends StatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  List<Map<String, dynamic>> resumes = [
    {
      'id': '1',
      'name': 'John_Doe_Resume.pdf',
      'size': '2.4 MB',
      'date': 'Jan 15, 2024',
      'isDefault': true,
    },
    {
      'id': '2',
      'name': 'John_Doe_CV.docx',
      'size': '1.8 MB',
      'date': 'Dec 20, 2023',
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Resume'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 64,
                      color: AppColors.primary.withAlpha(26),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    const Text(
                      'Upload Resume',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    const Text(
                      'Upload your resume in PDF, DOC, or DOCX format',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Upload from device
                            },
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload File'),
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Create from template
                            },
                            icon: const Icon(Icons.description),
                            label: const Text('Use Template'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            // Current Resume
            const Text(
              'Current Resume',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            if (resumes.isNotEmpty)
              Column(
                children: resumes.map((resume) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.md),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        ),
                        child: Icon(
                          resume['name'].toString().endsWith('.pdf')
                              ? Icons.picture_as_pdf
                              : Icons.description,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(resume['name']),
                      subtitle: Text('${resume['size']} • ${resume['date']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (resume['isDefault'])
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppSizes.radiusXs),
                              ),
                              child: const Text(
                                'Default',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          IconButton(
                            onPressed: () {
                              _showResumeActions(resume['id']);
                            },
                            icon: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                      onTap: () {
                        // View resume
                      },
                    ),
                  );
                }).toList(),
              )
            else
              _buildEmptyState(),
            const SizedBox(height: AppSizes.xl),
            // Resume Tips
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resume Tips',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    _buildTip(
                      'Keep it concise',
                      'Limit your resume to 1-2 pages',
                    ),
                    _buildTip(
                      'Use keywords',
                      'Include keywords from job descriptions',
                    ),
                    _buildTip(
                      'Highlight achievements',
                      'Use numbers to quantify your impact',
                    ),
                    _buildTip(
                      'Proofread',
                      'Check for spelling and grammar errors',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            // Build Resume Button
            PrimaryButton(
              text: 'Build Resume with AI',
              onPressed: () {
                // AI resume builder
              },
              prefixIcon: const Icon(Icons.auto_awesome, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: AppColors.textDisabled.withAlpha(26),
            ),
            const SizedBox(height: AppSizes.lg),
            const Text(
              'No Resume Uploaded',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'Upload your resume to apply for jobs faster',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResumeActions(String resumeId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('View Resume'),
                onTap: () {
                  Navigator.pop(context);
                  // View resume
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download'),
                onTap: () {
                  Navigator.pop(context);
                  // Download
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(resumeId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star_border),
                title: const Text('Set as Default'),
                onTap: () {
                  Navigator.pop(context);
                  _setAsDefault(resumeId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(resumeId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(String resumeId) {
    final resume = resumes.firstWhere((r) => r['id'] == resumeId);
    final controller = TextEditingController(text: resume['name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Resume'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter new name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                resume['name'] = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _setAsDefault(String resumeId) {
    setState(() {
      for (var resume in resumes) {
        resume['isDefault'] = resume['id'] == resumeId;
      }
    });
  }

  void _showDeleteDialog(String resumeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resume'),
        content: const Text('Are you sure you want to delete this resume?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                resumes.removeWhere((r) => r['id'] == resumeId);
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}