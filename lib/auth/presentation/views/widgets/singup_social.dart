import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInWithSocial extends StatelessWidget {
  const SignInWithSocial({
    super.key,
    required this.onPressed,
    required this.imagePath,
    required this.text,
    this.width = double.infinity,
    required this.color,
  });

  final VoidCallback onPressed;
  final String imagePath;
  final String text;
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(imagePath, height: 24, width: 24),

            Padding(
              padding: const EdgeInsets.only(right: 40.0),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
