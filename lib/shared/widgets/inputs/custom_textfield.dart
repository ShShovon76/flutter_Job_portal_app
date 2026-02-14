import 'package:flutter/material.dart';
import 'package:job_portal_app/core/constants/app_colors.dart';
import 'package:job_portal_app/core/constants/app_sizes.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final bool isRequired;
  final bool readOnly;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.isRequired = false,
    this.readOnly = false,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText.isNotEmpty) ...[
          Row(
            children: [
              Text(
                labelText,
                style: const TextStyle(
                  fontSize: AppSizes.textMd,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: AppSizes.textMd,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          textInputAction: textInputAction,
          focusNode: focusNode,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(
            fontSize: AppSizes.textXl,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.textDisabled,
              fontSize: AppSizes.textXl,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: contentPadding ?? const EdgeInsets.all(AppSizes.p12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.textSecondary,
                width: AppSizes.inputBorderWidth,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.textSecondary,
                width: AppSizes.inputBorderWidth,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: AppSizes.inputBorderWidth * 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: AppSizes.inputBorderWidth,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: AppSizes.inputBorderWidth * 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.textSecondary,
                width: AppSizes.inputBorderWidth,
              ),
            ),
            filled: true,
            fillColor: enabled ? AppColors.textInverse : AppColors.textSecondary,
            errorStyle: const TextStyle(
              color: AppColors.error,
              fontSize: AppSizes.sm,
            ),
          ),
        ),
      ],
    );
  }
}