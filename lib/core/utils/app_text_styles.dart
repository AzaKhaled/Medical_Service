import 'package:flutter/material.dart';

abstract class TextStyles {
  // 1. Montserrat - 800 - 24px - 100% - Center
  static const TextStyle montserrat800_24 = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w800,
    fontSize: 24,
    // height: 1.0,
    // letterSpacing: 0,
    textBaseline: TextBaseline.alphabetic,
    color: Colors.black, // افتراضي
  );

  // 2. Montserrat - 600 - 14px - 24px line-height - 2% letter spacing - Center - #A8A8A9
  static const TextStyle montserrat600_14_grey = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    // height: 24 / 14,
    // letterSpacing: 0.02 * 14,
    textBaseline: TextBaseline.alphabetic,
    color: Color(0xFFA8A8A9),
  );

  // 3. Montserrat - 700 - 36px - 43px line-height
  static const TextStyle montserrat700_36 = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w700,
    fontSize: 36,
    // height: 43 / 36,
    // letterSpacing: 0,
    color: Colors.black,
  );

  // 4. Montserrat - 400 - 12px - 100% - Center - #F83758
  static const TextStyle montserrat400_12_red = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600,
    fontSize: 12,
    // height: 1.0,
    // letterSpacing: 0,
    color: Color(0xFFF83758),
  );

  // 5. Montserrat - 600 - 20px - 100% - #FFFFFF
  static const TextStyle montserrat600_20_white = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    // height: 1.0,
    // letterSpacing: 0,
    color: Colors.white,
  );

  // 6. Montserrat - 500 - 12px - 100% - #676767
  static const TextStyle montserrat500_12_grey = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
    fontSize: 12,
    // height: 1.0,
    // letterSpacing: 0,
    color: Color(0xFF676767),
  );

  // 7. Montserrat - 400 - 10px - 16px - #21003D
  static const TextStyle montserrat400_10_purple = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w400,
    fontSize: 10,
    // height: 16 / 10,
    // letterSpacing: 0,
    color: Color(0xFF21003D),
  );

  // 8. Montserrat - 400 - 10px - 16px - #000000
  static const TextStyle montserrat400_10_black = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w400,
    fontSize: 10,
    // height: 16 / 10,
    // letterSpacing: 0,
    color: Colors.black,
  );

  // 9. Montserrat - 500 - 16px - 20px - #000000
  static const TextStyle montserrat500_16_black = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    // height: 20 / 16,
    // letterSpacing: 0,
    color: Colors.black,
  );
}
