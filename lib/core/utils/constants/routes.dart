import 'package:flutter/material.dart';
import 'package:medical_service_app/features/home/presentation/views/home_view.dart';
import 'package:medical_service_app/features/appoinment/view/appointment_view.dart';
import 'package:medical_service_app/features/setting/views/widgets/change_password_view.dart';
import 'package:medical_service_app/features/setting/views/widgets/change_profile.dart';
import 'package:medical_service_app/features/doctors/view/doctor_details_view.dart';
import 'package:medical_service_app/features/favorite/view/favorite_view.dart';
import 'package:medical_service_app/features/notification/views/notification_view.dart';
import 'package:medical_service_app/features/payment/view/payment_view.dart';
import 'package:medical_service_app/features/review/view/review_view.dart';
import 'package:medical_service_app/features/setting/views/settting_view.dart';
import 'package:medical_service_app/features/login/presentation/screen/login_screen.dart';
import 'package:medical_service_app/features/signup/presentation/screen/signup_screen.dart';

class Routes {
  static const String homeRoute = '/home';
  static const String favoriteRoute = '/favorite';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String notificationsRoute = '/notifications';
  static const String appointmentsRoute = '/appointments';
  static const String settingsRoute = '/settings';
  static const String changeProfileRoute = '/changeProfile';
  static const String changePasswordRoute = '/changePassword';
  static const String doctorDetailsRoute = '/doctorDetails';
  static const String reviewRoute = '/reviews';
  static const String paymentRoute = '/payment';
  static Map<String, WidgetBuilder> get routes => {
    homeRoute: (context) => const HomeView(),
    favoriteRoute: (context) => const FavoriteView(),
    loginRoute: (context) => const LoginScreen(),
    signupRoute: (context) => const SignupScreen(),
    notificationsRoute: (context) => const NotificationsView(),
    appointmentsRoute: (context) => const AppointmentView(),
    settingsRoute: (context) => const SettingsView(),
    changeProfileRoute: (context) => const ChangeProfileImageView(),
    changePasswordRoute: (context) => const ChangePasswordView(),
    doctorDetailsRoute: (context) => const DoctorDetailsView(),
    reviewRoute: (context) => const ReviewView(),
    paymentRoute: (context) => const PaymentView(),
  };
}
