import 'package:flutter/material.dart';
import 'package:medical_service_app/features/home/presentation/views/home_view.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/favorite_view.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/notification_view.dart';
import 'package:medical_service_app/features/login/presentation/screen/login_screen.dart';
import 'package:medical_service_app/features/signup/presentation/screen/signup_screen.dart';

class Routes {
  static const String homeRoute = '/home';
  static const String favoriteRoute = '/favorite';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String notificationsRoute = '/notifications';
  static Map<String, WidgetBuilder> get routes => {
    homeRoute: (context) => const HomeView(),
    favoriteRoute: (context) => const FavoriteView(),
    loginRoute: (context) => const LoginScreen(),
    signupRoute: (context) => const SignupScreen(),
    notificationsRoute: (context) => const NotificationsView(),
  };
}
