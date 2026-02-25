// import 'package:flutter/material.dart';
// import 'package:job_portal_app/core/utils/validators.dart';
// import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
// import 'package:provider/provider.dart';

// class RegisterJobSeekerScreen extends StatefulWidget {
//   const RegisterJobSeekerScreen({super.key});

//   @override
//   State<RegisterJobSeekerScreen> createState() =>
//       _RegisterJobSeekerScreenState();
// }

// class _RegisterJobSeekerScreenState extends State<RegisterJobSeekerScreen> {
//   final formKey = GlobalKey<FormState>();
//   final fullNameCtrl = TextEditingController();
//   final emailCtrl = TextEditingController();
//   final passwordCtrl = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthProvider>(context);

//     return Scaffold(
//       appBar: AppBar(title: Text('Register Job Seeker')),
//       body: Form(
//         key: formKey,
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: fullNameCtrl,
//                 decoration: InputDecoration(labelText: 'Full Name'),
//                 validator: Validators.required,
//               ),
//               TextFormField(
//                 controller: emailCtrl,
//                 decoration: InputDecoration(labelText: 'Email'),
//                 validator: Validators.email,
//               ),
//               TextFormField(
//                 controller: passwordCtrl,
//                 decoration: InputDecoration(labelText: 'Password'),
//                 obscureText: true,
//                 validator: Validators.password,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: auth.isLoading
//                     ? null
//                     : () {
//                         if (formKey.currentState!.validate()) {
//                           auth.registerJobSeeker(
//                             fullNameCtrl.text,
//                             emailCtrl.text,
//                             passwordCtrl.text,
//                           );
//                         }
//                       },
//                 child: Text('Register'),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// class RegisterEmployerScreen extends StatefulWidget {
//   const RegisterEmployerScreen({super.key});

//   @override
//   State<RegisterEmployerScreen> createState() =>
//       _RegisterEmployerScreenState();
// }

// class _RegisterEmployerScreenState extends State<RegisterEmployerScreen> {
//   final formKey = GlobalKey<FormState>();
//   final fullNameCtrl = TextEditingController();
//   final emailCtrl = TextEditingController();
//   final passwordCtrl = TextEditingController();
//   final companyCtrl = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthProvider>(context);

//     return Scaffold(
//       appBar: AppBar(title: Text('Register Employer')),
//       body: Form(
//         key: formKey,
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: fullNameCtrl,
//                 decoration: InputDecoration(labelText: 'Full Name'),
//                 validator: Validators.required,
//               ),
//               TextFormField(
//                 controller: emailCtrl,
//                 decoration: InputDecoration(labelText: 'Email'),
//                 validator: Validators.email,
//               ),
//               TextFormField(
//                 controller: passwordCtrl,
//                 decoration: InputDecoration(labelText: 'Password'),
//                 obscureText: true,
//                 validator: Validators.password,
//               ),
//               TextFormField(
//                 controller: companyCtrl,
//                 decoration: InputDecoration(labelText: 'Company Name'),
//                 validator: Validators.required,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: auth.isLoading
//                     ? null
//                     : () {
//                         if (formKey.currentState!.validate()) {
//                           auth.registerEmployer(
//                             fullNameCtrl.text,
//                             emailCtrl.text,
//                             passwordCtrl.text,
//                             companyCtrl.text,
//                           );
//                         }
//                       },
//                 child: Text('Register'),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// features/auth/presentation/register_screen.dart
import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/routes/route_names.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  // ===================== CONTROLLERS =====================
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();

  // ===================== STATE =====================
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _error;
  int _selectedRole = 0; // 0 = Job Seeker, 1 = Employer

  // ===================== TAB CONTROLLER =====================
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedRole = _tabController.index;
        _error = null; // Clear errors when switching tabs
      });
    }
  }

  // ===================== VALIDATION =====================
  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateCompanyName(String? value) {
    if (_selectedRole == 1) { // Only required for employer
      if (value == null || value.trim().isEmpty) {
        return 'Company name is required';
      }
      if (value.trim().length < 2) {
        return 'Company name must be at least 2 characters';
      }
    }
    return null;
  }

  // ===================== REGISTRATION =====================
  Future<void> _register() async {
    // Clear previous error
    setState(() => _error = null);

    // Validate form based on selected role
    if (_selectedRole == 0) {
      // Job Seeker validation
      if (_fullNameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        setState(() => _error = 'Please fill in all fields');
        return;
      }
      
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() => _error = 'Passwords do not match');
        return;
      }
      
      if (_passwordController.text.length < 6) {
        setState(() => _error = 'Password must be at least 6 characters');
        return;
      }
    } else {
      // Employer validation
      if (_fullNameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty ||
          _companyNameController.text.isEmpty) {
        setState(() => _error = 'Please fill in all fields');
        return;
      }
      
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() => _error = 'Passwords do not match');
        return;
      }
      
      if (_passwordController.text.length < 6) {
        setState(() => _error = 'Password must be at least 6 characters');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (_selectedRole == 0) {
        // Register as Job Seeker
        await authProvider.registerJobSeeker(
          _fullNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        // Register as Employer
        await authProvider.registerEmployer(
          _fullNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _companyNameController.text.trim(),
        );
      }

      if (mounted) {
        // Navigate to appropriate dashboard based on role
        final route = authProvider.getRoleBasedRoute();
        Navigator.pushReplacementNamed(context, route);
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Create Account',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Role Selection Tabs
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Color(0xFF64748B),
                  tabs: const [
                    Tab(text: 'Job Seeker'),
                    Tab(text: 'Employer'),
                  ],
                ),
              ),

              // Registration Form
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildJobSeekerForm(),
                    _buildEmployerForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobSeekerForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Join as a Job Seeker',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Find your dream job and connect with top employers',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),

          // Full Name
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF64748B)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
            ),
            validator: _validateFullName,
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF64748B)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Create a password',
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B)),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFF64748B),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 16),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B)),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFF64748B),
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
            ),
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 24),

          // Error Message
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFEE2E2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Register Button
          PrimaryButton(
            text: 'Create Account',
            onPressed: _register,
            width: double.infinity,
          ),
          const SizedBox(height: 16),

          // Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account?',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, RouteNames.login);
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmployerForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Join as an Employer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Post jobs and find the perfect candidates for your company',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),

          // Full Name
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF64748B)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
              ),
            ),
            validator: _validateFullName,
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF64748B)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Company Name
          TextFormField(
            controller: _companyNameController,
            decoration: InputDecoration(
              labelText: 'Company Name',
              hintText: 'Enter your company name',
              prefixIcon: const Icon(Icons.business_outlined, color: Color(0xFF64748B)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
              ),
            ),
            validator: _validateCompanyName,
          ),
          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Create a password',
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B)),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFF64748B),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
              ),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 16),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B)),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFF64748B),
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
              ),
            ),
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 24),

          // Error Message
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFEE2E2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Register Button
          PrimaryButton(
            text: 'Create Account',
            onPressed: _register,
            width: double.infinity,
          ),
          const SizedBox(height: 16),

          // Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account?',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, RouteNames.login);
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}