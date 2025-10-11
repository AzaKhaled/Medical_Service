import 'package:flutter/material.dart';
import 'package:medical_service_app/core/utils/constants/customtextfiled.dart';

class CustomSearch extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String hintText; // ← هنا ضفت المتغير

  const CustomSearch({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText = '...', // ← قيمة افتراضية لو ما كتبتش
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: controller,
      onChanged: onChanged,
      preffixIcon: const Icon(Icons.search),
      hintText: hintText, 
      textInputType: TextInputType.text,
    );
  }
}
