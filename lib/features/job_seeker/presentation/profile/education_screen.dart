// import 'package:flutter/material.dart';
// import 'package:job_app/core/constants/app_colors.dart';
// import 'package:job_app/core/constants/app_sizes.dart';
// import 'package:job_app/shared/services/demo_data_service.dart';
// import 'package:job_app/shared/widgets/buttons/primary_button.dart';

// class EducationScreen extends StatefulWidget {
//   const EducationScreen({super.key});

//   @override
//   State<EducationScreen> createState() => _EducationScreenState();
// }

// class _EducationScreenState extends State<EducationScreen> {
//   List<Education> educations = DemoDataService.demoEducation;
//   bool showAddForm = false;

//   final TextEditingController _institutionController = TextEditingController();
//   final TextEditingController _degreeController = TextEditingController();
//   final TextEditingController _fieldController = TextEditingController();
//   final TextEditingController _gpaController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   DateTime? _startDate;
//   DateTime? _endDate;
//   bool _currentlyStudying = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Education'),
//         actions: [
//           if (!showAddForm)
//             IconButton(
//               onPressed: () {
//                 setState(() => showAddForm = true);
//               },
//               icon: const Icon(Icons.add),
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
//           if (showAddForm)
//             // Add Education Form
//             Expanded(
//               child: _buildEducationForm(),
//             )
//           else
//             // Education List
//             Expanded(
//               child: educations.isEmpty
//                   ? _buildEmptyState()
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(AppSizes.md),
//                       itemCount: educations.length,
//                       itemBuilder: (context, index) {
//                         final education = educations[index];
//                         return _buildEducationCard(education);
//                       },
//                     ),
//             ),
//           // Floating Action Button for adding
//           if (!showAddForm && educations.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.all(AppSizes.md),
//               child: PrimaryButton(
//                 text: 'Add Education',
//                 onPressed: () {
//                   setState(() => showAddForm = true);
//                 },
//                 prefixIcon: const Icon(Icons.add, size: 20),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEducationCard(Education education) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: AppSizes.md),
//       child: Padding(
//         padding: const EdgeInsets.all(AppSizes.md),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     education.institution,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 PopupMenuButton(
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(
//                       value: 'edit',
//                       child: Text('Edit'),
//                     ),
//                     const PopupMenuItem(
//                       value: 'delete',
//                       child: Text(
//                         'Delete',
//                         style: TextStyle(color: AppColors.error),
//                       ),
//                     ),
//                   ],
//                   onSelected: (value) {
//                     if (value == 'edit') {
//                       _editEducation(education);
//                     } else if (value == 'delete') {
//                       _deleteEducation(education.id);
//                     }
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: AppSizes.sm),
//             Text(
//               '${education.degree} in ${education.field}',
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             const SizedBox(height: AppSizes.sm),
//             Text(
//               '${_formatDate(education.startDate)} - ${education.endDate != null ? _formatDate(education.endDate!) : 'Present'}',
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             if (education.gpa != null) ...[
//               const SizedBox(height: AppSizes.sm),
//               Text(
//                 'GPA: ${education.gpa}',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//             if (education.description != null && education.description!.isNotEmpty) ...[
//               const SizedBox(height: AppSizes.sm),
//               Text(
//                 education.description!,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEducationForm() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(AppSizes.md),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Add Education',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: AppSizes.lg),
//           _buildFormField(
//             'Institution',
//             'University or college name',
//             _institutionController,
//           ),
//           const SizedBox(height: AppSizes.lg),
//           _buildFormField(
//             'Degree',
//             'e.g., Bachelor of Science',
//             _degreeController,
//           ),
//           const SizedBox(height: AppSizes.lg),
//           _buildFormField(
//             'Field of Study',
//             'e.g., Computer Science',
//             _fieldController,
//           ),
//           const SizedBox(height: AppSizes.lg),
//           // Start Date
//           InkWell(
//             onTap: () => _selectDate(true),
//             child: Container(
//               padding: const EdgeInsets.all(AppSizes.md),
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppColors.border),
//                 borderRadius: BorderRadius.circular(AppSizes.inputRadius),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.calendar_today_outlined),
//                   const SizedBox(width: AppSizes.md),
//                   Expanded(
//                     child: Text(
//                       _startDate != null
//                           ? 'Start Date: ${_formatDate(_startDate!)}'
//                           : 'Select Start Date',
//                       style: TextStyle(
//                         color: _startDate != null
//                             ? AppColors.textPrimary
//                             : AppColors.textDisabled,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: AppSizes.lg),
//           // Currently Studying Checkbox
//           Row(
//             children: [
//               Checkbox(
//                 value: _currentlyStudying,
//                 onChanged: (value) {
//                   setState(() {
//                     _currentlyStudying = value ?? false;
//                     if (_currentlyStudying) {
//                       _endDate = null;
//                     }
//                   });
//                 },
//               ),
//               const Text('I am currently studying here'),
//             ],
//           ),
//           // End Date (if not currently studying)
//           if (!_currentlyStudying) ...[
//             const SizedBox(height: AppSizes.lg),
//             InkWell(
//               onTap: () => _selectDate(false),
//               child: Container(
//                 padding: const EdgeInsets.all(AppSizes.md),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: AppColors.border),
//                   borderRadius: BorderRadius.circular(AppSizes.inputRadius),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.calendar_today_outlined),
//                     const SizedBox(width: AppSizes.md),
//                     Expanded(
//                       child: Text(
//                         _endDate != null
//                             ? 'End Date: ${_formatDate(_endDate!)}'
//                             : 'Select End Date',
//                         style: TextStyle(
//                           color: _endDate != null
//                               ? AppColors.textPrimary
//                               : AppColors.textDisabled,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//           const SizedBox(height: AppSizes.lg),
//           _buildFormField(
//             'GPA (Optional)',
//             'e.g., 3.8',
//             _gpaController,
//           ),
//           const SizedBox(height: AppSizes.lg),
//           _buildFormField(
//             'Description (Optional)',
//             'Additional information about your education',
//             _descriptionController,
//             maxLines: 3,
//           ),
//           const SizedBox(height: AppSizes.xl),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () {
//                     setState(() => showAddForm = false);
//                     _clearForm();
//                   },
//                   child: const Text('Cancel'),
//                 ),
//               ),
//               const SizedBox(width: AppSizes.md),
//               Expanded(
//                 child: PrimaryButton(
//                   text: 'Save Education',
//                   onPressed: _saveEducation,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.school_outlined,
//             size: 80,
//             color: AppColors.textDisabled.withOpacity(0.5),
//           ),
//           const SizedBox(height: AppSizes.xl),
//           const Text(
//             'No Education Added',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: AppSizes.sm),
//           const Text(
//             'Add your educational background to complete your profile',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: AppColors.textSecondary,
//             ),
//           ),
//           const SizedBox(height: AppSizes.xl),
//           PrimaryButton(
//             text: 'Add Education',
//             onPressed: () {
//               setState(() => showAddForm = true);
//             },
//             width: 200,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFormField(
//     String label,
//     String hint,
//     TextEditingController controller, {
//     int maxLines = 1,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: AppSizes.xs),
//         TextField(
//           controller: controller,
//           decoration: InputDecoration(
//             hintText: hint,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(AppSizes.inputRadius),
//             ),
//           ),
//           maxLines: maxLines,
//         ),
//       ],
//     );
//   }

//   Future<void> _selectDate(bool isStartDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1950, 1, 1),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStartDate) {
//           _startDate = picked;
//         } else {
//           _endDate = picked;
//         }
//       });
//     }
//   }

//   void _saveEducation() {
//     if (_institutionController.text.isEmpty ||
//         _degreeController.text.isEmpty ||
//         _fieldController.text.isEmpty ||
//         _startDate == null ||
//         (!_currentlyStudying && _endDate == null)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill all required fields'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//       return;
//     }

//     final newEducation = Education(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       institution: _institutionController.text,
//       degree: _degreeController.text,
//       field: _fieldController.text,
//       startDate: _startDate!,
//       endDate: _currentlyStudying ? null : _endDate,
//       gpa: _gpaController.text.isNotEmpty ? _gpaController.text : null,
//       description: _descriptionController.text.isNotEmpty
//           ? _descriptionController.text
//           : null,
//     );

//     setState(() {
//       educations.add(newEducation);
//       showAddForm = false;
//       _clearForm();
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Education added successfully'),
//         backgroundColor: AppColors.success,
//       ),
//     );
//   }

//   void _editEducation(Education education) {
//     _institutionController.text = education.institution;
//     _degreeController.text = education.degree;
//     _fieldController.text = education.field;
//     _startDate = education.startDate;
//     _endDate = education.endDate;
//     _gpaController.text = education.gpa ?? '';
//     _descriptionController.text = education.description ?? '';
//     _currentlyStudying = education.endDate == null;

//     setState(() => showAddForm = true);
//   }

//   void _deleteEducation(String id) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Education'),
//         content: const Text('Are you sure you want to delete this education?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 educations.removeWhere((edu) => edu.id == id);
//               });
//               Navigator.pop(context);
//             },
//             child: const Text(
//               'Delete',
//               style: TextStyle(color: AppColors.error),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _clearForm() {
//     _institutionController.clear();
//     _degreeController.clear();
//     _fieldController.clear();
//     _gpaController.clear();
//     _descriptionController.clear();
//     _startDate = null;
//     _endDate = null;
//     _currentlyStudying = false;
//   }

//   String _formatDate(DateTime date) {
//     return '${date.month}/${date.year}';
//   }
// }