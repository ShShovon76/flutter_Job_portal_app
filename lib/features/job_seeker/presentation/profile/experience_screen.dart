// import 'package:flutter/material.dart';
// import 'package:job_app/core/constants/app_colors.dart';
// import 'package:job_app/core/constants/app_sizes.dart';
// import 'package:job_app/shared/services/demo_data_service.dart';
// import 'package:job_app/shared/widgets/buttons/primary_button.dart';

// class ExperienceScreen extends StatefulWidget {
//   const ExperienceScreen({super.key});

//   @override
//   State<ExperienceScreen> createState() => _ExperienceScreenState();
// }

// class _ExperienceScreenState extends State<ExperienceScreen> {
//   List<Experience> experiences = DemoDataService.demoExperience;
//   bool showAddForm = false;

//   final TextEditingController _companyController = TextEditingController();
//   final TextEditingController _positionController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   DateTime? _startDate;
//   DateTime? _endDate;
//   bool _currentlyWorking = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Work Experience'),
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
//             // Add Experience Form
//             Expanded(child: _buildExperienceForm())
//           else
//             // Experience List
//             Expanded(
//               child: experiences.isEmpty
//                   ? _buildEmptyState()
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(AppSizes.md),
//                       itemCount: experiences.length,
//                       itemBuilder: (context, index) {
//                         final experience = experiences[index];
//                         return _buildExperienceCard(experience);
//                       },
//                     ),
//             ),
//           // Floating Action Button for adding
//           if (!showAddForm && experiences.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.all(AppSizes.md),
//               child: PrimaryButton(
//                 text: 'Add Experience',
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

//   Widget _buildExperienceCard(Experience experience) {
//     final duration = _calculateDuration(
//       experience.startDate,
//       experience.endDate,
//     );

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
//                     experience.position,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 PopupMenuButton(
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(value: 'edit', child: Text('Edit')),
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
//                       _editExperience(experience);
//                     } else if (value == 'delete') {
//                       _deleteExperience(experience.id);
//                     }
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: AppSizes.sm),
//             Text(
//               experience.company,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             const SizedBox(height: AppSizes.sm),
//             Text(
//               '${_formatDate(experience.startDate)} - ${experience.currentlyWorking ? 'Present' : _formatDate(experience.endDate!)} • $duration',
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             const SizedBox(height: AppSizes.sm),
//             Text(
//               experience.description,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildExperienceForm() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(AppSizes.md),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Add Work Experience',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: AppSizes.lg),
//           _buildFormField('Company', 'Company name', _companyController),
//           const SizedBox(height: AppSizes.lg),
//           _buildFormField(
//             'Position',
//             'Job title or position',
//             _positionController,
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
//           // Currently Working Checkbox
//           Row(
//             children: [
//               Checkbox(
//                 value: _currentlyWorking,
//                 onChanged: (value) {
//                   setState(() {
//                     _currentlyWorking = value ?? false;
//                     if (_currentlyWorking) {
//                       _endDate = null;
//                     }
//                   });
//                 },
//               ),
//               const Text('I currently work here'),
//             ],
//           ),
//           // End Date (if not currently working)
//           if (!_currentlyWorking) ...[
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
//             'Description',
//             'Describe your responsibilities and achievements',
//             _descriptionController,
//             maxLines: 4,
//           ),
//           const SizedBox(height: AppSizes.lg),
//           // Key Achievements
//           const Text(
//             'Key Achievements (Optional)',
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: AppSizes.xs),
//           const TextField(
//             decoration: InputDecoration(
//               hintText: 'Add an achievement and press enter',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           const SizedBox(height: AppSizes.sm),
//           Wrap(
//             spacing: AppSizes.sm,
//             children: [
//               Chip(
//                 label: const Text('Increased app performance by 40%'),
//                 onDeleted: () {},
//               ),
//               Chip(
//                 label: const Text('Led a team of 5 developers'),
//                 onDeleted: () {},
//               ),
//               Chip(
//                 label: const Text('Reduced bug reports by 60%'),
//                 onDeleted: () {},
//               ),
//             ],
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
//                   text: 'Save Experience',
//                   onPressed: _saveExperience,
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
//             Icons.work_outline,
//             size: 80,
//             color: AppColors.textDisabled.withOpacity(0.5),
//           ),
//           const SizedBox(height: AppSizes.xl),
//           const Text(
//             'No Work Experience',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: AppSizes.sm),
//           const Text(
//             'Add your work experience to showcase your career journey',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: AppColors.textSecondary),
//           ),
//           const SizedBox(height: AppSizes.xl),
//           PrimaryButton(
//             text: 'Add Experience',
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
//           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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

//   void _saveExperience() {
//     if (_companyController.text.isEmpty ||
//         _positionController.text.isEmpty ||
//         _descriptionController.text.isEmpty ||
//         _startDate == null ||
//         (!_currentlyWorking && _endDate == null)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill all required fields'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//       return;
//     }

//     final newExperience = Experience(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       company: _companyController.text,
//       position: _positionController.text,
//       startDate: _startDate!,
//       endDate: _currentlyWorking ? null : _endDate,
//       currentlyWorking: _currentlyWorking,
//       description: _descriptionController.text,
//     );

//     setState(() {
//       experiences.add(newExperience);
//       showAddForm = false;
//       _clearForm();
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Experience added successfully'),
//         backgroundColor: AppColors.success,
//       ),
//     );
//   }

//   void _editExperience(Experience experience) {
//     _companyController.text = experience.company;
//     _positionController.text = experience.position;
//     _startDate = experience.startDate;
//     _endDate = experience.endDate;
//     _descriptionController.text = experience.description;
//     _currentlyWorking = experience.currentlyWorking;

//     setState(() => showAddForm = true);
//   }

//   void _deleteExperience(String id) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Experience'),
//         content: const Text('Are you sure you want to delete this experience?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 experiences.removeWhere((exp) => exp.id == id);
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
//     _companyController.clear();
//     _positionController.clear();
//     _descriptionController.clear();
//     _startDate = null;
//     _endDate = null;
//     _currentlyWorking = false;
//   }

//   String _formatDate(DateTime date) {
//     return '${_getMonthName(date.month)} ${date.year}';
//   }

//   String _getMonthName(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return months[month - 1];
//   }

//   String _calculateDuration(DateTime start, DateTime? end) {
//     final endDate = end ?? DateTime.now();
//     final years = endDate.year - start.year;
//     final months = endDate.month - start.month;

//     var totalMonths = years * 12 + months;
//     if (endDate.day < start.day) {
//       totalMonths--;
//     }

//     if (totalMonths >= 12) {
//       final years = totalMonths ~/ 12;
//       final remainingMonths = totalMonths % 12;
//       if (remainingMonths > 0) {
//         return '$years yr ${remainingMonths} mo';
//       }
//       return '$years yr';
//     } else {
//       return '$totalMonths mo';
//     }
//   }
// }
