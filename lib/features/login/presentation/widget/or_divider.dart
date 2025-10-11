import 'package:flutter/material.dart';
import 'package:medical_service_app/core/utils/constants/app_text_styles.dart';


class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 60.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.amber)),
          SizedBox(width: 18),
          Text(
            ('OR Continue with'),
            textAlign: TextAlign.center,
            style: TextStyles.montserrat400_10_black
          ),
          SizedBox(width: 18),
          Expanded(child: Divider(color: Colors.amber)),
        ],
      ),
    );
  }
}
