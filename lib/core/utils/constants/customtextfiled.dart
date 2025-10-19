import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.textInputType,
    this.suffixIcon,
    this.onSaved,
    this.onChanged,
    this.obscureText = false,
    this.preffixIcon,
    this.controller,
    this.validator,
  });

  final String hintText;
  final TextInputType textInputType;
  final Widget? suffixIcon;
  final Widget? preffixIcon;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onSaved: onSaved,
      onChanged: onChanged,
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'required';
            }
            return null;
          },
      keyboardType: textInputType,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        prefixIcon: preffixIcon,
        hintText: hintText,
        // hintStyle: Colors.lightBlue,
        filled: true,
        fillColor:
            theme.inputDecorationTheme.fillColor ??
            theme.colorScheme.surface.withValues(alpha: 0.05),
        border: buildBorder(theme),
        enabledBorder: buildBorder(theme),
        focusedBorder: buildBorder(theme, isFocused: true),
      ),
    );
  }

  OutlineInputBorder buildBorder(ThemeData theme, {bool isFocused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        width: 1,
        color: isFocused ? theme.colorScheme.primary : theme.dividerColor,
      ),
    );
  }
}
