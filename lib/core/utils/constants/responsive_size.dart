import 'dart:math';
import 'package:flutter/material.dart';

extension SizerExt on num {
  static final _screenSizes = ScreenSizes();

  double get w => _screenSizes.getWidth(this);
  double get h => _screenSizes.getHeight(this);
  double get rw => _screenSizes.getRelativeWidth(this);
  double get rh => _screenSizes.getRelativeHeight(this);
  double get rSp => _screenSizes.getRelativeSize(this);
}

class ScreenSizes {
  static final ScreenSizes _instance = ScreenSizes._();
  factory ScreenSizes() => _instance;
  ScreenSizes._();

  final Size _designSize = const Size(430, 880);
  static double _screenWidth = 430;
  static double _screenHeight = 880;
  static bool _initialized = false;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _screenWidth = size.width;
    _screenHeight = size.height;
    _initialized = true;
  }

  void _checkInit() {
    if (!_initialized) {
      throw Exception("ScreenSizes.init(context) لازم يتنادى قبل الاستخدام");
    }
  }

  double get scaleWidth {
    _checkInit();
    return _screenWidth / _designSize.width;
  }

  double get scaleHeight {
    _checkInit();
    return _screenHeight / _designSize.height;
  }

  double getRelativeWidth(num size) => size * scaleWidth;
  double getRelativeHeight(num size) => size * scaleHeight;
  double getRelativeSize(num size) => size * min(scaleWidth, scaleHeight);
  double getWidth(num size) => size * _screenWidth / 100;
  double getHeight(num size) => size * _screenHeight / 100;
}
