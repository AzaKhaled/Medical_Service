import 'package:flutter/material.dart';
import 'package:medical_service_app/core/utils/app_text_styles.dart';
import 'package:provider/provider.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.amber)),
          const SizedBox(width: 18),
          Text(
            ('OR Continue with'),
            textAlign: TextAlign.center,
            style: TextStyles.montserrat400_10_black
          ),
          const SizedBox(width: 18),
          Expanded(child: Divider(color: Colors.amber)),
        ],
      ),
    );
  }
}
