import 'package:flutter/material.dart';
import 'package:job_portal_app/shared/widgets/inputs/custom_textfield.dart';


class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final bool isRequired;

  const PasswordField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.enabled = true,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.onChanged,
    this.isRequired = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      hintText: widget.hintText ?? 'Enter your password',
      obscureText: _obscureText,
      enabled: widget.enabled,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      isRequired: widget.isRequired,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}