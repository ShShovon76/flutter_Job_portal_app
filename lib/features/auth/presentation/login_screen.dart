import 'package:flutter/material.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/models/user_model.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:job_portal_app/shared/widgets/buttons/secondary_button.dart';
import 'package:job_portal_app/shared/widgets/inputs/custom_textfield.dart';
import 'package:job_portal_app/shared/widgets/inputs/password_field.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool _rememberMe = false;
  
  // Error message state
  String? _errorMessage;

  // Demo accounts
  final List<Map<String, String>> _demoAccounts = [
    {
      'role': 'Job Seeker',
      'email': 'jobseeker@example.com',
      'password': 'demo123',
      'color': '#10B981',
    },
    {
      'role': 'Employer',
      'email': 'employer@example.com',
      'password': 'demo123',
      'color': '#F59E0B',
    },
    {
      'role': 'Admin',
      'email': 'admin@example.com',
      'password': 'demo123',
      'color': '#EF4444',
    },
  ];

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await auth.login(emailCtrl.text.trim(), passwordCtrl.text);
      
      if (mounted) {
        if (auth.isAuthenticated) {
          _redirectBasedOnRole(auth.user!.role!);
        } else {
          // This case shouldn't happen normally, but just in case
          setState(() {
            _errorMessage = 'Login failed. Please check your credentials.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // Parse error message from exception
        String errorMsg = e.toString();
        
        // Check for specific error messages from your API
        if (errorMsg.toLowerCase().contains('user not found') || 
            errorMsg.toLowerCase().contains('no user found')) {
          setState(() {
            _errorMessage = 'No account found with this email. Please sign up.';
          });
        } else if (errorMsg.toLowerCase().contains('password') && 
                   errorMsg.toLowerCase().contains('invalid')) {
          setState(() {
            _errorMessage = 'Incorrect password. Please try again.';
          });
        } else {
          setState(() {
            _errorMessage = 'Login failed: ${errorMsg.replaceFirst('Exception:', '').trim()}';
          });
        }
      }
    }
  }

  Future<void> _handleDemoLogin(String email, String password) async {
    // Clear any previous errors
    setState(() {
      _errorMessage = null;
      emailCtrl.text = email;
      passwordCtrl.text = password;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await auth.login(email, password);
      
      if (mounted) {
        if (auth.isAuthenticated) {
          _redirectBasedOnRole(auth.user!.role!);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Demo login failed: ${e.toString().replaceFirst('Exception:', '').trim()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3B82F6),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Title
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to continue',
                style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              ),

              const SizedBox(height: 32),

              // Error Message Display
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFFEF4444),
                          size: 16,
                        ),
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field - Using CustomTextField
                    CustomTextField(
                      controller: emailCtrl,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                    ),

                    const SizedBox(height: 24),

                    // Password Field - Using PasswordField
                    PasswordField(
                      controller: passwordCtrl,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      validator: _validatePassword,
                      textInputAction: TextInputAction.done,
                      isRequired: true,
                    ),

                    const SizedBox(height: 16),

                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF3B82F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const Text(
                              'Remember me',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to forgot password
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Login Button - Using PrimaryButton
                    PrimaryButton(
                      text: 'Sign In',
                      onPressed: auth.isLoading ? null : _handleLogin,
                      isLoading: auth.isLoading,
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Social Login - Using SecondaryButton
                    SecondaryButton(
                      text: 'Continue with Google',
                      onPressed: () {},
                      prefixIcon: const Icon(Icons.g_mobiledata, size: 24),
                    ),

                    const SizedBox(height: 32),

                    // Demo Accounts Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Demo Accounts',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Quick login with demo accounts',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Demo Buttons
                          ..._demoAccounts.map((account) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildDemoButton(
                              role: account['role']!,
                              email: account['email']!,
                              color: Color(int.parse('0xFF${account['color']!.substring(1)}')),
                              onTap: () => _handleDemoLogin(
                                account['email']!,
                                account['password']!,
                              ),
                            ),
                          )).toList(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, RouteNames.register);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDemoButton({
    required String role,
    required String email,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getRoleIcon(role),
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login as $role',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Demo',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'job seeker':
        return Icons.person_search;
      case 'employer':
        return Icons.business_center;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  void _redirectBasedOnRole(UserRole role) {
    switch (role) {
      case UserRole.JOB_SEEKER:
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.jobSeekerShell,
          (Route<dynamic> route) => false,
        );
        break;
      case UserRole.EMPLOYER:
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.employerShell,
          (Route<dynamic> route) => false,
        );
        break;
      case UserRole.ADMIN:
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.adminShell,
          (Route<dynamic> route) => false,
        );
        break;
    }
  }
}