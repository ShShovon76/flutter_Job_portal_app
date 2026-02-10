import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';


class EditCompanyProfileScreen extends StatefulWidget {
  const EditCompanyProfileScreen({super.key});

  @override
  State<EditCompanyProfileScreen> createState() =>
      _EditCompanyProfileScreenState();
}

class _EditCompanyProfileScreenState extends State<EditCompanyProfileScreen> {
 


  void _saveCompanyProfile() async {

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: AppSizes.md),
            Text('Saving company profile...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Company profile updated successfully!'),
        backgroundColor: AppColors.success,
      ),
    );

    // Navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Company Profile'),
        actions: [
          TextButton(
            onPressed: _saveCompanyProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Text(
        "edit company profile"
      )
    );
  }

  Widget _buildSocialLink(String platform, String url) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(
            _getPlatformIcon(platform),
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Text(
            url,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            // Edit link
          },
          icon: const Icon(Icons.edit, size: 18),
        ),
      ],
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return Icons.business;
      case 'twitter':
        return Icons.chat_bubble_outline;
      case 'facebook':
        return Icons.thumb_up_outlined;
      case 'instagram':
        return Icons.camera_alt_outlined;
      default:
        return Icons.link;
    }
  }
}