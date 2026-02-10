import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  void _handleContinue() {
    if (_selectedRole == null) return;

    if (_selectedRole == 'job_seeker') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.jobSeekerShell,
        (route) => false, // removes all previous routes
      );
    } else if (_selectedRole == 'employer') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.employerShell,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.xxl),
            // Back button
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(height: AppSizes.xl),
            // Title
            Text(
              'Select Your Role',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSizes.sm),
            // Subtitle
            Text(
              'Choose how you want to use Job Portal',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizes.xl),
            // Role Cards
            Expanded(
              child: Column(
                children: [
                  // Job Seeker Card
                  GestureDetector(
                    onTap: () => setState(() => _selectedRole = 'job_seeker'),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppSizes.lg),
                      padding: const EdgeInsets.all(AppSizes.lg),
                      decoration: BoxDecoration(
                        color: _selectedRole == 'job_seeker'
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardRadius,
                        ),
                        border: Border.all(
                          color: _selectedRole == 'job_seeker'
                              ? AppColors.primary
                              : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusLg,
                              ),
                            ),
                            child: Icon(
                              Icons.person_search,
                              size: 32,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSizes.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Job Seeker',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: AppSizes.sm),
                                Text(
                                  'Find your dream job, apply to positions, and track your applications',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedRole == 'job_seeker')
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Employer Card
                  GestureDetector(
                    onTap: () => setState(() => _selectedRole = 'employer'),
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      decoration: BoxDecoration(
                        color: _selectedRole == 'employer'
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardRadius,
                        ),
                        border: Border.all(
                          color: _selectedRole == 'employer'
                              ? AppColors.primary
                              : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusLg,
                              ),
                            ),
                            child: Icon(
                              Icons.business_center,
                              size: 32,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: AppSizes.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Employer',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: AppSizes.sm),
                                Text(
                                  'Post jobs, find candidates, and manage your hiring process',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedRole == 'employer')
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Continue Button
            PrimaryButton(
              text: 'Continue',
              onPressed: _selectedRole != null ? _handleContinue : null,
              isDisabled: _selectedRole == null,
            ),
          ],
        ),
      ),
    );
  }
}
