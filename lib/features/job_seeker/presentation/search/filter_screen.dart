import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:job_portal_app/shared/widgets/buttons/secondary_button.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? selectedJobType;
  String? selectedExperience;
  List<String> selectedCategories = [];
  RangeValues salaryRange = const RangeValues(50000, 150000);
  bool remoteOnly = false;

  final List<Map<String, String>> jobTypes = [
    {'value': 'full_time', 'label': 'Full Time'},
    {'value': 'part_time', 'label': 'Part Time'},
    {'value': 'contract', 'label': 'Contract'},
    {'value': 'internship', 'label': 'Internship'},
    {'value': 'remote', 'label': 'Remote'},
  ];

  final List<Map<String, String>> experienceLevels = [
    {'value': 'entry', 'label': 'Entry Level'},
    {'value': 'mid', 'label': 'Mid Level'},
    {'value': 'senior', 'label': 'Senior Level'},
    {'value': 'executive', 'label': 'Executive'},
  ];

  final List<Map<String, String>> categories = [
    {'value': 'tech', 'label': 'Technology'},
    {'value': 'design', 'label': 'Design'},
    {'value': 'marketing', 'label': 'Marketing'},
    {'value': 'finance', 'label': 'Finance'},
    {'value': 'hr', 'label': 'Human Resources'},
    {'value': 'sales', 'label': 'Sales'},
    {'value': 'healthcare', 'label': 'Healthcare'},
    {'value': 'education', 'label': 'Education'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedJobType = null;
                selectedExperience = null;
                selectedCategories.clear();
                salaryRange = const RangeValues(30000, 200000);
                remoteOnly = false;
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.md),
              children: [
                // Job Type
                _buildFilterSection(
                  'Job Type',
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: jobTypes
                        .map(
                          (type) => ChoiceChip(
                            label: Text(type['label']!),
                            selected: selectedJobType == type['value'],
                            onSelected: (selected) {
                              setState(() {
                                selectedJobType = selected
                                    ? type['value']
                                    : null;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
                // Experience Level
                _buildFilterSection(
                  'Experience Level',
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: experienceLevels
                        .map(
                          (exp) => ChoiceChip(
                            label: Text(exp['label']!),
                            selected: selectedExperience == exp['value'],
                            onSelected: (selected) {
                              setState(() {
                                selectedExperience = selected
                                    ? exp['value']
                                    : null;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
                // Categories
                _buildFilterSection(
                  'Categories',
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: categories
                        .map(
                          (category) => FilterChip(
                            label: Text(category['label']!),
                            selected: selectedCategories.contains(
                              category['value'],
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedCategories.add(category['value']!);
                                } else {
                                  selectedCategories.remove(category['value']!);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
                // Salary Range
                _buildFilterSection(
                  'Salary Range',
                  Column(
                    children: [
                      RangeSlider(
                        values: salaryRange,
                        min: 30000,
                        max: 200000,
                        divisions: 17,
                        labels: RangeLabels(
                          '\$${salaryRange.start.toInt()}',
                          '\$${salaryRange.end.toInt()}',
                        ),
                        onChanged: (values) {
                          setState(() => salaryRange = values);
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text('\$${salaryRange.start.toInt()}'),
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                          ),
                          Chip(
                            label: Text('\$${salaryRange.end.toInt()}'),
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Remote Only
                SwitchListTile(
                  title: const Text('Remote Only'),
                  subtitle: const Text('Show only remote jobs'),
                  value: remoteOnly,
                  onChanged: (value) {
                    setState(() => remoteOnly = value);
                  },
                ),
              ],
            ),
          ),
          // Apply Button
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: PrimaryButton(
                    text: 'Apply Filters',
                    onPressed: () {
                      // Apply filters and go back
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSizes.md),
          content,
        ],
      ),
    );
  }
}
