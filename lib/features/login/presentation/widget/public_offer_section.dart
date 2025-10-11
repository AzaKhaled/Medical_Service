import 'package:flutter/material.dart';
import 'package:medical_service_app/core/theme/colors.dart';



class PublicOffireSection extends StatelessWidget {
  const PublicOffireSection({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(color: Colors.indigo),
        children: [
          TextSpan(text: ('By clicking the ')),
          TextSpan(
            text: 'Register',
            style: TextStyle(
              color: AppColors.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: (' button, you agree to the public offer')),
        ],
      ),
    );
  }
}
