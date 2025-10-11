import 'package:flutter/material.dart';
import 'package:medical_service_app/core/utils/constants/responsive_size.dart';

class TextStylesManager {
  static const String fontFamily = 'Almarai';

  /// Regular text styles
  static TextStyle get regular8 => TextStyle(
    fontSize: 8.rSp,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
  );

  static TextStyle get regular10 => TextStyle(
    fontSize: 10.rSp,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
  );

  static TextStyle regular12({
    String? changeFontFamily,
  }) => TextStyle(
    fontSize: 12.rSp,
    fontWeight: FontWeight.w400,
    fontFamily: changeFontFamily ?? fontFamily,
  );

  static TextStyle get regular14 => TextStyle(
    fontSize: 14.rSp,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
  );

  static TextStyle get regular16 => TextStyle(
    fontSize: 16.rSp,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
  );

  static TextStyle get regular18 => TextStyle(
    fontSize: 18.rSp,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
  );

  static TextStyle get regular20 => TextStyle(
    fontSize: 20.rSp,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
  );

  static TextStyle get regular22 => TextStyle(
    fontSize: 22.rSp,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
  );

  static TextStyle get regular24 => TextStyle(
    fontSize: 24.rSp,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
  );

  static TextStyle get regular40 => TextStyle(
    fontSize: 40.rSp,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
  );

  /// Bold text styles

  static TextStyle get bold10 => TextStyle(
    fontSize: 10.rSp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle get bold12 => TextStyle(
    fontSize: 12.rSp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle get bold14 => TextStyle(
    fontSize: 14.rSp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle get bold16 => TextStyle(
    fontSize: 16.rSp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle get bold18 => TextStyle(
    fontSize: 18.rSp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle get bold20 => TextStyle(
    fontSize: 20.rSp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle get bold22 => TextStyle(
    fontSize: 22.rSp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle get bold24 => TextStyle(
    fontSize: 24.rSp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle get bold26 => TextStyle(
    fontSize: 26.rSp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle get bold28 => TextStyle(
    fontSize: 28.rSp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle get bold30 => TextStyle(
    fontSize: 30.rSp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle get bold32 => TextStyle(
    fontSize: 32.rSp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle get bold36 => TextStyle(
    fontSize: 36.rSp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle get bold40 => TextStyle(
    fontSize: 40.rSp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle get bold48 => TextStyle(
    fontSize: 48.rSp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );
}
