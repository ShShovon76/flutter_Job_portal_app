import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:job_portal_app/shared/widgets/inputs/custom_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  void _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _emailSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
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
                'Forgot Password',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppSizes.sm),
              // Subtitle
              Text(
                _emailSent
                    ? 'Check your email for reset instructions'
                    : 'Enter your email to reset your password',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSizes.xl),
              if (_emailSent)
                // Success State
                Container(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 64,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: AppSizes.lg),
                      const Text(
                        'Reset Email Sent!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'We have sent password reset instructions to your email',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSizes.xl),
                      PrimaryButton(
                        text: 'Back to Login',
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            RouteNames.login,
                          );
                        },
                      ),
                      const SizedBox(height: AppSizes.md),
                      TextButton(
                        onPressed: () {
                          setState(() => _emailSent = false);
                        },
                        child: const Text('Resend Email'),
                      ),
                    ],
                  ),
                )
              else
                // Reset Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.xl),
                      PrimaryButton(
                        text: 'Send Reset Link',
                        onPressed: _handleResetPassword,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: AppSizes.xl),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            RouteNames.login,
                          );
                        },
                        child: const Text('Back to Login'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
