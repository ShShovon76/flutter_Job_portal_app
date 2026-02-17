import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';
import 'package:job_portal_app/features/auth/provider/auth_provider.dart';
import 'package:job_portal_app/features/employer/presentation/company/provider/company_provider.dart';
import 'package:job_portal_app/models/company_model.dart';
import 'package:job_portal_app/shared/widgets/buttons/primary_button.dart';
import 'package:job_portal_app/shared/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';

class EditCompanyProfileScreen extends StatefulWidget {
  final Company company;

  const EditCompanyProfileScreen({super.key, required this.company});

  @override
  State<EditCompanyProfileScreen> createState() =>
      _EditCompanyProfileScreenState();
}

class _EditCompanyProfileScreenState extends State<EditCompanyProfileScreen> {
  // ===================== CONTROLLERS =====================
  late TextEditingController _nameController;
  late TextEditingController _industryController;
  late TextEditingController _companySizeController;
  late TextEditingController _aboutController;
  late TextEditingController _websiteController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _foundedYearController;

  // ===================== STATE =====================
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // ===================== INIT =====================
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _companySizeController.dispose();
    _aboutController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _foundedYearController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.company.name);
    _industryController = TextEditingController(text: widget.company.industry);
    _companySizeController = TextEditingController(
      text: widget.company.companySize ?? '',
    );
    _aboutController = TextEditingController(text: widget.company.about ?? '');
    _websiteController = TextEditingController(
      text: widget.company.website ?? '',
    );
    _emailController = TextEditingController(text: widget.company.email ?? '');
    _phoneController = TextEditingController(text: widget.company.phone ?? '');
    _addressController = TextEditingController(
      text: widget.company.address ?? '',
    );
    _foundedYearController = TextEditingController(
      text: widget.company.foundedYear?.toString() ?? '',
    );
  }

  // ===================== SAVE =====================
Future<void> _saveChanges() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final companyProvider = Provider.of<CompanyProvider>(
      context,
      listen: false,
    );

    // Prepare socialLinks DTOs
    final socialLinks = widget.company.socialLinks
        ?.map((link) => SocialLink(type: link.type, url: link.url))
        .toList();

    final request = CompanyUpdateRequest(
      name: _nameController.text.trim(),
      industry: _industryController.text.trim(),
      companySize: _companySizeController.text.trim().isNotEmpty
          ? _companySizeController.text.trim()
          : widget.company.companySize,
      about: _aboutController.text.trim().isNotEmpty
          ? _aboutController.text.trim()
          : widget.company.about,
      website: _websiteController.text.trim().isNotEmpty
          ? _websiteController.text.trim()
          : widget.company.website,
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : widget.company.email,
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : widget.company.phone,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : widget.company.address,
      foundedYear: _foundedYearController.text.trim().isNotEmpty
          ? int.tryParse(_foundedYearController.text)
          : widget.company.foundedYear,
      socialLinks: socialLinks, // ✅ Include social links
    );

    // Call provider
    await companyProvider.updateCompany(
      request,
      logo: null, // optional: selected File
      cover: null, // optional: selected File
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Company profile updated successfully'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to update: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}



  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Company Profile'),
          elevation: 0,
          actions: [
            TextButton(
              onPressed: _saveChanges,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Save'),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Basic Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),

                        // Company Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Company Name *',
                            prefixIcon: Icon(Icons.business),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Company name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Industry
                        TextFormField(
                          controller: _industryController,
                          decoration: const InputDecoration(
                            labelText: 'Industry *',
                            prefixIcon: Icon(Icons.category),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Industry is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Company Size
                        DropdownButtonFormField<String>(
                          value: _companySizeController.text.isNotEmpty
                              ? _companySizeController.text
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Company Size',
                            prefixIcon: Icon(Icons.people),
                          ),
                          items:
                              [
                                '1-10 employees',
                                '11-50 employees',
                                '51-200 employees',
                                '201-500 employees',
                                '501-1000 employees',
                                '1000+ employees',
                              ].map((size) {
                                return DropdownMenuItem(
                                  value: size,
                                  child: Text(size),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _companySizeController.text = value ?? '';
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Founded Year
                        TextFormField(
                          controller: _foundedYearController,
                          decoration: const InputDecoration(
                            labelText: 'Founded Year',
                            prefixIcon: Icon(Icons.cake),
                            hintText: 'YYYY',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // About Company
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About Company',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),

                        // About
                        TextFormField(
                          controller: _aboutController,
                          decoration: const InputDecoration(
                            labelText: 'About',
                            hintText: 'Describe your company...',
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Contact Information
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contact Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),

                        // Website
                        TextFormField(
                          controller: _websiteController,
                          decoration: const InputDecoration(
                            labelText: 'Website',
                            prefixIcon: Icon(Icons.language),
                            hintText: 'https://example.com',
                          ),
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),

                        // Address
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button
                PrimaryButton(
                  text: 'Save Changes',
                  onPressed: _saveChanges,
                  width: double.infinity,
                ),

                const SizedBox(height: 16),

                // Cancel Button
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cancel'),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
