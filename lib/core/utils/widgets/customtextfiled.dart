import 'package:flutter/material.dart';
import 'package:medical_service_app/core/utils/app_colors.dart';
import 'package:medical_service_app/core/utils/app_text_styles.dart';

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
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onSaved: onSaved,
      onChanged: onChanged,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'required';
            }
            return null;
          },
      keyboardType: textInputType,
      style: const TextStyle(color: Colors.black), // ← لون النص
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        prefixIcon: preffixIcon,
        hintStyle: TextStyles.montserrat500_12_grey,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white, // ← لون خلفية الحقل
        border: buildBorder(),
        enabledBorder: buildBorder(),
        focusedBorder: buildBorder(isFocused: true),
      ),
    );
  }

  OutlineInputBorder buildBorder({bool isFocused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(
        width: 1,
        color: isFocused
            ? AppColors.primaryColor
            : Colors.grey.withOpacity(0.3), // ← لون الحدود
      ),
    );
  }
}
