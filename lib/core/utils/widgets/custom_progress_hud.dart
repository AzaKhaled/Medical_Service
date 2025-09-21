
import 'package:flutter/material.dart';
import 'package:medical_service_app/core/utils/app_colors.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class CustomProgressHUD extends StatelessWidget {
  const CustomProgressHUD({super.key, required this.isLoading, required this.child});
  final bool isLoading;
  final Widget child; 
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      color: AppColors.primaryColor,
      inAsyncCall: isLoading, child: child);
  }
}