// import 'package:flutter/material.dart';
// import 'package:job_app/core/constants/app_colors.dart';
// import 'package:job_app/core/constants/app_sizes.dart';
// import 'package:job_app/shared/services/demo_data_service.dart';
// import 'package:job_app/shared/widgets/buttons/primary_button.dart';
// import 'package:job_app/shared/widgets/buttons/secondary_button.dart';
// import 'package:job_app/shared/widgets/inputs/custom_textfield.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _locationController = TextEditingController();
//   final _headlineController = TextEditingController();
//   final _bioController = TextEditingController();

//   String selectedGender = 'male';
//   DateTime? selectedDate;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   void _loadUserData() {
//     final user = DemoDataService.demoUser;
//     _fullNameController.text = user.fullName;
//     _emailController.text = user.email;
//     _phoneController.text = '+1 (555) 123-4567';
//     _locationController.text = 'San Francisco, CA';
//     _headlineController.text = 'Senior Flutter Developer';
//     _bioController.text = 'Passionate mobile developer with 5+ years of experience in Flutter and native development. Love building beautiful and performant applications.';
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime(1990, 1, 1),
//       firstDate: DateTime(1950, 1, 1),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   void _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     // Show loading
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Row(
//           children: [
//             CircularProgressIndicator(color: Colors.white),
//             SizedBox(width: AppSizes.md),
//             Text('Saving profile...'),
//           ],
//         ),
//         duration: Duration(seconds: 2),
//       ),
//     );

//     // Simulate API call
//     await Future.delayed(const Duration(seconds: 2));

//     // Show success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Profile updated successfully!'),
//         backgroundColor: AppColors.success,
//       ),
//     );

//     // Navigate back
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Profile'),
//         actions: [
//           TextButton(
//             onPressed: _saveProfile,
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(AppSizes.md),
//           child: Column(
//             children: [
//               // Profile Picture
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(AppSizes.lg),
//                   child: Column(
//                     children: [
//                       Stack(
//                         children: [
//                           Container(
//                             width: 100,
//                             height: 100,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: AppColors.primary.withOpacity(0.1),
//                             ),
//                             child: const Icon(
//                               Icons.person,
//                               size: 48,
//                               color: AppColors.primary,
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: Container(
//                               width: 32,
//                               height: 32,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: AppColors.primary,
//                                 border: Border.all(color: Colors.white, width: 2),
//                               ),
//                               child: const Icon(
//                                 Icons.camera_alt,
//                                 size: 16,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: AppSizes.md),
//                       const Text(
//                         'Profile Picture',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: AppSizes.xs),
//                       Text(
//                         'Recommended: 300x300px, JPG or PNG',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: AppSizes.lg),
//               // Personal Information
//               const Text(
//                 'Personal Information',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: AppSizes.md),
//               CustomTextField(
//                 label: 'Full Name',
//                 controller: _fullNameController,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your full name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: AppSizes.lg),
//               CustomTextField(
//                 label: 'Email',
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   if (!value.contains('@')) {
//                     return 'Please enter a valid email';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: AppSizes.lg),
//               CustomTextField(
//                 label: 'Phone Number',
//                 controller: _phoneController,
//                 keyboardType: TextInputType.phone,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your phone number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: AppSizes.lg),
//               CustomTextField(
//                 label: 'Location',
//                 controller: _locationController,
//                 hintText: 'City, Country',
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your location';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: AppSizes.lg),
//               // Date of Birth
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Date of Birth',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                   const SizedBox(height: AppSizes.xs),
//                   InkWell(
//                     onTap: () => _selectDate(context),
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: AppSizes.md,
//                         vertical: AppSizes.sm,
//                       ),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: AppColors.border),
//                         borderRadius: BorderRadius.circular(AppSizes.inputRadius),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.calendar_today_outlined,
//                             size: 20,
//                             color: AppColors.textSecondary,
//                           ),
//                           const SizedBox(width: AppSizes.md),
//                           Text(
//                             selectedDate != null
//                                 ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
//                                 : 'Select date',
//                             style: TextStyle(
//                               color: selectedDate != null
//                                   ? AppColors.textPrimary
//                                   : AppColors.textDisabled,
//                             ),
//                           ),
//                           const Spacer(),
//                           const Icon(
//                             Icons.arrow_drop_down,
//                             color: AppColors.textSecondary,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppSizes.lg),
//               // Gender
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Gender',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                   const SizedBox(height: AppSizes.xs),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ChoiceChip(
//                           label: const Text('Male'),
//                           selected: selectedGender == 'male',
//                           onSelected: (selected) {
//                             setState(() => selectedGender = 'male');
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: AppSizes.md),
//                       Expanded(
//                         child: ChoiceChip(
//                           label: const Text('Female'),
//                           selected: selectedGender == 'female',
//                           onSelected: (selected) {
//                             setState(() => selectedGender = 'female');
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: AppSizes.md),
//                       Expanded(
//                         child: ChoiceChip(
//                           label: const Text('Other'),
//                           selected: selectedGender == 'other',
//                           onSelected: (selected) {
//                             setState(() => selectedGender = 'other');
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppSizes.xl),
//               // Professional Information
//               const Text(
//                 'Professional Information',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: AppSizes.md),
//               CustomTextField(
//                 label: 'Headline',
//                 controller: _headlineController,
//                 hintText: 'e.g., Senior Flutter Developer',
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your professional headline';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: AppSizes.lg),
//               CustomTextField(
//                 label: 'Bio',
//                 controller: _bioController,
//                 maxLines: 4,
//                 hintText: 'Tell us about yourself...',
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your bio';
//                   }
//                   if (value.length < 50) {
//                     return 'Bio should be at least 50 characters';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: AppSizes.lg),
//               // Social Links
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(AppSizes.md),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Social Links',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: AppSizes.md),
//                       _buildSocialLink('LinkedIn', 'linkedin.com/in/johndoe'),
//                       const SizedBox(height: AppSizes.md),
//                       _buildSocialLink('GitHub', 'github.com/johndoe'),
//                       const SizedBox(height: AppSizes.md),
//                       _buildSocialLink('Portfolio', 'johndoe.dev'),
//                       const SizedBox(height: AppSizes.md),
//                       TextButton.icon(
//                         onPressed: () {
//                           // Add more social links
//                         },
//                         icon: const Icon(Icons.add),
//                         label: const Text('Add Another Link'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: AppSizes.xl),
//               // Action Buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: SecondaryButton(
//                       text: 'Cancel',
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                   const SizedBox(width: AppSizes.md),
//                   Expanded(
//                     child: PrimaryButton(
//                       text: 'Save Changes',
//                       onPressed: _saveProfile,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppSizes.xl),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSocialLink(String platform, String url) {
//     return Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: AppColors.background,
//             borderRadius: BorderRadius.circular(AppSizes.radiusSm),
//           ),
//           child: Icon(
//             _getPlatformIcon(platform),
//             size: 20,
//             color: AppColors.textSecondary,
//           ),
//         ),
//         const SizedBox(width: AppSizes.md),
//         Expanded(
//           child: Text(
//             url,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         IconButton(
//           onPressed: () {
//             // Edit link
//           },
//           icon: const Icon(Icons.edit, size: 18),
//         ),
//       ],
//     );
//   }

//   IconData _getPlatformIcon(String platform) {
//     switch (platform.toLowerCase()) {
//       case 'linkedin':
//         return Icons.business;
//       case 'github':
//         return Icons.code;
//       case 'portfolio':
//         return Icons.public;
//       default:
//         return Icons.link;
//     }
//   }
// }