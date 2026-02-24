// import 'package:flutter/material.dart';
// import 'package:job_app/core/constants/app_colors.dart';
// import 'package:job_app/core/constants/app_sizes.dart';
// import 'package:job_app/shared/services/demo_data_service.dart';
// import 'package:job_app/shared/widgets/buttons/primary_button.dart';
// import 'package:job_app/shared/widgets/buttons/secondary_button.dart';
// import 'package:job_app/shared/widgets/inputs/search_field.dart';

// class SkillsScreen extends StatefulWidget {
//   const SkillsScreen({super.key});

//   @override
//   State<SkillsScreen> createState() => _SkillsScreenState();
// }

// class _SkillsScreenState extends State<SkillsScreen> {
//   List<String> selectedSkills = DemoDataService.demoSkills;
//   List<String> suggestedSkills = [
//     'React Native',
//     'TypeScript',
//     'GraphQL',
//     'AWS',
//     'Docker',
//     'Kubernetes',
//     'CI/CD',
//     'Testing',
//     'Agile',
//     'Scrum',
//   ];

//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _customSkillController = TextEditingController();

//   void _addSkill(String skill) {
//     if (!selectedSkills.contains(skill)) {
//       setState(() {
//         selectedSkills.add(skill);
//       });
//     }
//   }

//   void _removeSkill(String skill) {
//     setState(() {
//       selectedSkills.remove(skill);
//     });
//   }

//   void _addCustomSkill() {
//     final skill = _customSkillController.text.trim();
//     if (skill.isNotEmpty && !selectedSkills.contains(skill)) {
//       setState(() {
//         selectedSkills.add(skill);
//         _customSkillController.clear();
//       });
//     }
//   }

//   void _reorderSkill(int oldIndex, int newIndex) {
//     if (newIndex > oldIndex) newIndex -= 1;
//     setState(() {
//       final skill = selectedSkills.removeAt(oldIndex);
//       selectedSkills.insert(newIndex, skill);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Skills'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minHeight: constraints.maxHeight),
//               child: IntrinsicHeight(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Search Field
//                     Padding(
//                       padding: const EdgeInsets.all(AppSizes.md),
//                       child: SearchField(
//                         controller: _searchController,
//                         hintText: 'Search skills...',
//                       ),
//                     ),

//                     // Selected Skills (Reorderable List)
//                     Flexible(
//                       child: SizedBox(
//                         height: 300, // Limits height to avoid overflow
//                         child: ReorderableListView.builder(
//                           padding: const EdgeInsets.all(AppSizes.md),
//                           itemCount: selectedSkills.length,
//                           itemBuilder: (context, index) {
//                             final skill = selectedSkills[index];
//                             return Card(
//                               key: ValueKey(skill),
//                               margin: const EdgeInsets.only(
//                                 bottom: AppSizes.sm,
//                               ),
//                               child: ListTile(
//                                 leading: Container(
//                                   width: 40,
//                                   height: 40,
//                                   decoration: BoxDecoration(
//                                     color: AppColors.primary.withValues(alpha: 0.1),
//                                     borderRadius: BorderRadius.circular(
//                                       AppSizes.radiusSm,
//                                     ),
//                                   ),
//                                   child: const Icon(
//                                     Icons.star,
//                                     color: AppColors.primary,
//                                     size: 20,
//                                   ),
//                                 ),
//                                 title: Text(skill),
//                                 trailing: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(
//                                       '${index + 1}',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: AppColors.textSecondary,
//                                       ),
//                                     ),
//                                     IconButton(
//                                       onPressed: () => _removeSkill(skill),
//                                       icon: const Icon(Icons.close, size: 18),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                           onReorder: _reorderSkill,
//                         ),
//                       ),
//                     ),

//                     // Add Custom Skill
//                     Container(
//                       padding: const EdgeInsets.all(AppSizes.md),
//                       decoration: BoxDecoration(
//                         color: AppColors.surface,
//                         border: Border(
//                           top: BorderSide(color: AppColors.border),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: _customSkillController,
//                               decoration: InputDecoration(
//                                 hintText: 'Add custom skill...',
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: AppSizes.md,
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(
//                                     AppSizes.radiusLg,
//                                   ),
//                                 ),
//                               ),
//                               onSubmitted: (_) => _addCustomSkill(),
//                             ),
//                           ),
//                           const SizedBox(width: AppSizes.md),
//                           IconButton(
//                             onPressed: _addCustomSkill,
//                             icon: const Icon(Icons.add_circle),
//                             color: AppColors.primary,
//                           ),
//                         ],
//                       ),
//                     ),

//                     // Suggested Skills
//                     Container(
//                       padding: const EdgeInsets.all(AppSizes.md),
//                       decoration: BoxDecoration(
//                         color: AppColors.background,
//                         border: Border(
//                           top: BorderSide(color: AppColors.border),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Suggested Skills',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(height: AppSizes.md),
//                           Wrap(
//                             spacing: AppSizes.sm,
//                             runSpacing: AppSizes.sm,
//                             children: suggestedSkills
//                                 .where(
//                                   (skill) => !selectedSkills.contains(skill),
//                                 )
//                                 .map(
//                                   (skill) => InputChip(
//                                     label: Text(skill),
//                                     onPressed: () => _addSkill(skill),
//                                   ),
//                                 )
//                                 .toList(),
//                           ),
//                         ],
//                       ),
//                     ),

//                     // Action Buttons
//                     Container(
//                       padding: const EdgeInsets.all(AppSizes.md),
//                       decoration: BoxDecoration(
//                         color: AppColors.surface,
//                         border: Border(
//                           top: BorderSide(color: AppColors.border),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: SecondaryButton(
//                               text: 'Cancel',
//                               onPressed: () => Navigator.pop(context),
//                             ),
//                           ),
//                           const SizedBox(width: AppSizes.md),
//                           Expanded(
//                             child: PrimaryButton(
//                               text: 'Save Skills',
//                               onPressed: () => Navigator.pop(context),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
