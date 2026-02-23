// // features/job_seeker/presentation/resume/resume_upload_screen.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:job_portal_app/core/api/resume_api.dart';
// import 'package:job_portal_app/core/constants/app_colors.dart';
// import 'package:job_portal_app/core/constants/app_sizes.dart';
// import 'package:job_portal_app/features/job_seeker/provider/profile_provider.dart';
// import 'package:job_portal_app/models/application_model.dart';
// import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
// import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
// import 'package:provider/provider.dart';


// class ResumeUploadScreen extends StatefulWidget {
//   const ResumeUploadScreen({super.key});

//   @override
//   State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
// }

// class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
//   // ===================== STATE =====================
//   List<Resume> _resumes = [];
//   bool _isLoading = true;
//   bool _isUploading = false;
//   String? _error;
//   int? _uploadingProgress;

//   @override
//   void initState() {
//     super.initState();
//     _loadResumes();
//   }

//   // ===================== LOAD RESUMES =====================
//   Future<void> _loadResumes() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final resumes = await ResumeApi.getMyResumes();
//       setState(() {
//         _resumes = resumes;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   // ===================== UPLOAD RESUME =====================
//   Future<void> _uploadResume() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'doc', 'docx'],
//         allowMultiple: false,
//       );

//       if (result == null || result.files.single.path == null) return;

//       // Show title dialog
//       final title = await _showTitleDialog(result.files.single.name);
//       if (title == null) return;

//       setState(() => _isUploading = true);

//       final file = File(result.files.single.path!);
//       final uploadedResume = await ResumeApi.uploadResume(
//         file: file,
//         title: title,
//       );

//       setState(() {
//         _resumes.insert(0, uploadedResume);
//         _isUploading = false;
//       });

//       _showSnackBar('Resume uploaded successfully');
//     } catch (e) {
//       setState(() => _isUploading = false);
//       _showSnackBar('Failed to upload resume', isError: true);
//     }
//   }

//   Future<String?> _showTitleDialog(String defaultTitle) async {
//     final controller = TextEditingController(text: defaultTitle);
//     return showDialog<String>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Resume Title'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             hintText: 'Enter a title for this resume',
//             border: OutlineInputBorder(),
//           ),
//           autofocus: true,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, controller.text),
//             child: const Text('Upload'),
//           ),
//         ],
//       ),
//     );
//   }

//   // ===================== SET PRIMARY RESUME =====================
//   Future<void> _setPrimaryResume(int resumeId) async {
//     try {
//       await ResumeApi.setPrimaryResume(resumeId);
      
//       setState(() {
//         _resumes = _resumes.map((r) {
//           return r.copyWith(primaryResume: r.id == resumeId);
//         }).toList();
//       });

//       _showSnackBar('Primary resume updated');
      
//       // Update provider
//       final provider = Provider.of<JobSeekerProfileProvider>(context, listen: false);
//       await provider.loadProfileAndDashboard(provider.profile?.userId ?? 0);
//     } catch (e) {
//       _showSnackBar('Failed to set primary resume', isError: true);
//     }
//   }

//   // ===================== DELETE RESUME =====================
//   Future<void> _deleteResume(int resumeId) async {
//     final confirmed = await _showConfirmDialog(
//       'Delete Resume',
//       'Are you sure you want to delete this resume?',
//     );

//     if (!confirmed) return;

//     try {
//       await ResumeApi.deleteResume(resumeId);
      
//       setState(() {
//         _resumes.removeWhere((r) => r.id == resumeId);
//       });

//       _showSnackBar('Resume deleted successfully');
//     } catch (e) {
//       _showSnackBar('Failed to delete resume', isError: true);
//     }
//   }

//   // ===================== DOWNLOAD RESUME =====================
//   Future<void> _downloadResume(int resumeId) async {
//     try {
//       _showSnackBar('Downloading...');
//       final bytes = await ResumeApi.downloadResume(resumeId);
//       _showSnackBar('Download complete');
//     } catch (e) {
//       _showSnackBar('Failed to download resume', isError: true);
//     }
//   }

//   // ===================== UTILITY =====================
//   Future<bool> _showConfirmDialog(String title, String message) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//     return result ?? false;
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   String _formatFileSize(int bytes) {
//     if (bytes < 1024) return '$bytes B';
//     if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
//     return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
//   }

//   String _formatDate(String dateString) {
//     final date = DateTime.parse(dateString);
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inDays == 0) {
//       return 'Today';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays} days ago';
//     } else {
//       return '${(difference.inDays / 7).floor()} weeks ago';
//     }
//   }

//   // ===================== BUILD UI =====================
//   @override
//   Widget build(BuildContext context) {
//     return LoadingOverlay(
//       isLoading: _isUploading,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Resume & Documents',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//           ),
//           elevation: 0,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.add),
//               onPressed: _uploadResume,
//             ),
//           ],
//         ),
//         body: _isLoading
//             ? _buildShimmerLoader()
//             : _error != null
//                 ? _buildErrorState()
//                 : _resumes.isEmpty
//                     ? _buildEmptyState()
//                     : _buildResumeList(),
//       ),
//     );
//   }

//   Widget _buildResumeList() {
//     return RefreshIndicator(
//       onRefresh: _loadResumes,
//       color: AppColors.primary,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(AppSizes.md),
//         itemCount: _resumes.length,
//         itemBuilder: (context, index) {
//           final resume = _resumes[index];
//           return _buildResumeCard(resume);
//         },
//       ),
//     );
//   }

//   Widget _buildResumeCard(Resume resume) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: AppSizes.md),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(
//           color: resume.primaryResume ? AppColors.primary : Colors.transparent,
//           width: 2,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(AppSizes.md),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     Icons.description,
//                     color: AppColors.primary,
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         resume.title,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Uploaded ${_formatDate(resume.uploadedAt)}',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (resume.primaryResume)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColors.primary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: const [
//                         Icon(
//                           Icons.star,
//                           size: 14,
//                           color: AppColors.primary,
//                         ),
//                         SizedBox(width: 4),
//                         Text(
//                           'Primary',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: AppColors.primary,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // Action Buttons
//             Row(
//               children: [
//                 if (!resume.primaryResume)
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: () => _setPrimaryResume(resume.id),
//                       icon: const Icon(Icons.star_border, size: 16),
//                       label: const Text('Set as Primary'),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                       ),
//                     ),
//                   ),
//                 if (!resume.primaryResume) const SizedBox(width: 8),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () => _downloadResume(resume.id),
//                     icon: const Icon(Icons.download, size: 16),
//                     label: const Text('Download'),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 10),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: () => _deleteResume(resume.id),
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   style: IconButton.styleFrom(
//                     backgroundColor: Colors.red.withOpacity(0.1),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildShimmerLoader() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(AppSizes.md),
//       itemCount: 3,
//       itemBuilder: (context, index) {
//         return Card(
//           margin: const EdgeInsets.only(bottom: AppSizes.md),
//           child: Padding(
//             padding: const EdgeInsets.all(AppSizes.md),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 48,
//                       height: 48,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             width: double.infinity,
//                             height: 16,
//                             color: Colors.grey.shade300,
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             width: 150,
//                             height: 12,
//                             color: Colors.grey.shade300,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Container(
//                         height: 36,
//                         color: Colors.grey.shade300,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Container(
//                         height: 36,
//                         color: Colors.grey.shade300,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.upload_file_outlined,
//               size: 80,
//               color: AppColors.textDisabled.withOpacity(0.5),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'No Resumes Yet',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Upload your resume to start applying for jobs',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
//             ),
//             const SizedBox(height: 24),
//             PrimaryButton(
//               text: 'Upload Resume',
//               onPressed: _uploadResume,
//               width: 200,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 64, color: Colors.red),
//             const SizedBox(height: 16),
//             const Text(
//               'Something went wrong',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _error ?? 'Failed to load resumes',
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: AppColors.textSecondary),
//             ),
//             const SizedBox(height: 24),
//             PrimaryButton(
//               text: 'Try Again',
//               onPressed: _loadResumes,
//               width: 150,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






// features/job_seeker/presentation/resume/resume_upload_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:job_portal_app/core/api/resume_api.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/features/job_seeker/provider/profile_provider.dart';
import 'package:job_portal_app/models/application_model.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';


class ResumeUploadScreen extends StatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  // ===================== STATE =====================
  List<Resume> _resumes = [];
  bool _isLoading = true;
  bool _isUploading = false;
  String? _error;
  
  // Preview state
  bool _isPreviewing = false;
  String? _previewPath;
  String? _previewFileName;
  int? _totalPages;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadResumes();
  }

  @override
  void dispose() {
    // Clean up temporary files
    if (_previewPath != null) {
      File(_previewPath!).deleteSync();
    }
    super.dispose();
  }

  // ===================== LOAD RESUMES =====================
  Future<void> _loadResumes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resumes = await ResumeApi.getMyResumes();
      setState(() {
        _resumes = resumes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ===================== UPLOAD RESUME =====================
  Future<void> _uploadResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) return;

      // Show title dialog
      final title = await _showTitleDialog(result.files.single.name);
      if (title == null) return;

      setState(() => _isUploading = true);

      final file = File(result.files.single.path!);
      final uploadedResume = await ResumeApi.uploadResume(
        file: file,
        title: title,
      );

      setState(() {
        _resumes.insert(0, uploadedResume);
        _isUploading = false;
      });

      _showSnackBar('Resume uploaded successfully');
    } catch (e) {
      setState(() => _isUploading = false);
      _showSnackBar('Failed to upload resume', isError: true);
    }
  }

  Future<String?> _showTitleDialog(String defaultTitle) async {
    final controller = TextEditingController(text: defaultTitle);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resume Title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter a title for this resume',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  // ===================== SET PRIMARY RESUME =====================
  Future<void> _setPrimaryResume(int resumeId) async {
    try {
      await ResumeApi.setPrimaryResume(resumeId);
      
      setState(() {
        _resumes = _resumes.map((r) {
          return r.copyWith(primaryResume: r.id == resumeId);
        }).toList();
      });

      _showSnackBar('Primary resume updated');
      
      // Update provider
      final provider = Provider.of<JobSeekerProfileProvider>(context, listen: false);
      await provider.loadProfileAndDashboard(provider.profile?.userId ?? 0);
    } catch (e) {
      _showSnackBar('Failed to set primary resume', isError: true);
    }
  }

  // ===================== DELETE RESUME =====================
  Future<void> _deleteResume(int resumeId) async {
    final confirmed = await _showConfirmDialog(
      'Delete Resume',
      'Are you sure you want to delete this resume?',
    );

    if (!confirmed) return;

    try {
      await ResumeApi.deleteResume(resumeId);
      
      setState(() {
        _resumes.removeWhere((r) => r.id == resumeId);
      });

      _showSnackBar('Resume deleted successfully');
    } catch (e) {
      _showSnackBar('Failed to delete resume', isError: true);
    }
  }

  // ===================== DOWNLOAD RESUME =====================
  Future<void> _downloadResume(int resumeId) async {
    try {
      _showSnackBar('Downloading...');
      final bytes = await ResumeApi.downloadResume(resumeId);
      
      // Save to downloads folder
      final directory = await getExternalStorageDirectory();
      final file = File('${directory?.path}/resume_$resumeId.pdf');
      await file.writeAsBytes(bytes);
      
      _showSnackBar('Download complete: ${file.path}');
    } catch (e) {
      _showSnackBar('Failed to download resume', isError: true);
    }
  }

  // ===================== PREVIEW RESUME =====================
  Future<void> _previewResume(Resume resume) async {
    setState(() {
      _isPreviewing = true;
      _previewFileName = resume.title;
    });

    try {
      final bytes = await ResumeApi.downloadResume(resume.id);
      
      // Save to temporary file for PDF viewer
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
      _showSnackBar('Failed to load preview', isError: true);
    }
  }

  void _closePreview() {
    // Clean up temporary file
    if (_previewPath != null) {
      File(_previewPath!).deleteSync();
    }
    
    setState(() {
      _isPreviewing = false;
      _previewPath = null;
      _previewFileName = null;
      _totalPages = null;
      _currentPage = 0;
    });
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

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }

  bool _isPdf(String fileName) {
    return path.extension(fileName).toLowerCase() == '.pdf';
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
        appBar: AppBar(
          title: const Text(
            'Resume & Documents',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          elevation: 0,
          leading: _isPreviewing
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _closePreview,
                )
              : null,
          actions: _isPreviewing
              ? [
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      // Download from preview
                      _closePreview();
                    },
                  ),
                ]
              : [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _uploadResume,
                  ),
                ],
        ),
        body: _isPreviewing && _previewPath != null
            ? _buildPdfViewer()
            : _isLoading
                ? _buildShimmerLoader()
                : _error != null
                    ? _buildErrorState()
                    : _resumes.isEmpty
                        ? _buildEmptyState()
                        : _buildResumeList(),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
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
            onViewCreated: (PDFViewController controller) {
              // You can save controller if needed
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
                // Previous Page Button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: _currentPage > 0
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: _currentPage > 0
                          ? () {
                              // PDFViewController would need to be saved
                            }
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 40,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Page Indicator (for mobile)
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

                // Next Page Button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: _currentPage < (_totalPages! - 1)
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: _currentPage < (_totalPages! - 1)
                          ? () {
                              // PDFViewController would need to be saved
                            }
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 40,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildResumeList() {
    return RefreshIndicator(
      onRefresh: _loadResumes,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: _resumes.length,
        itemBuilder: (context, index) {
          final resume = _resumes[index];
          return _buildResumeCard(resume);
        },
      ),
    );
  }

  Widget _buildResumeCard(Resume resume) {
    final isPdf = _isPdf(resume.title);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: resume.primaryResume ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isPdf ? Colors.red.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.description,
                    color: isPdf ? Colors.red : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resume.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uploaded ${_formatDate(resume.uploadedAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (resume.primaryResume)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Primary',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons - Mobile friendly row with wrap
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Preview Button (always show)
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 48) / 3,
                  child: OutlinedButton(
                    onPressed: isPdf ? () => _previewResume(resume) : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(
                        color: isPdf ? AppColors.primary : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 16,
                          color: isPdf ? AppColors.primary : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Preview',
                          style: TextStyle(
                            fontSize: 12,
                            color: isPdf ? AppColors.primary : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Download Button
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 48) / 3,
                  child: OutlinedButton(
                    onPressed: () => _downloadResume(resume.id),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download, size: 16),
                        SizedBox(width: 4),
                        Text('Download', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),

                // Primary/Delete Button
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 48) / 3,
                  child: resume.primaryResume
                      ? OutlinedButton(
                          onPressed: () => _deleteResume(resume.id),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: Colors.red),
                            foregroundColor: Colors.red,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete, size: 16),
                              SizedBox(width: 4),
                              Text('Delete', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        )
                      : OutlinedButton(
                          onPressed: () => _setPrimaryResume(resume.id),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star_border, size: 16),
                              SizedBox(width: 4),
                              Text('Primary', style: TextStyle(fontSize: 12)),
                            ],
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

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 150,
                            height: 12,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 36,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
              Icons.upload_file_outlined,
              size: 80,
              color: AppColors.textDisabled.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Resumes Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload your resume to start applying for jobs',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Upload Resume',
              onPressed: _uploadResume,
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
              _error ?? 'Failed to load resumes',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Try Again',
              onPressed: _loadResumes,
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}

