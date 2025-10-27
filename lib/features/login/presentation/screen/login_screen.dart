import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_service_app/core/utils/constants/customtextfiled.dart';
import 'package:medical_service_app/core/utils/constants/routes.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_state.dart';
import 'package:medical_service_app/core/utils/extensions/context_extension.dart';
import 'package:medical_service_app/features/login/presentation/widget/have_an_account_section.dart';
import 'package:medical_service_app/features/login/presentation/widget/or_divider.dart';
import 'package:medical_service_app/features/login/presentation/widget/password_field.dart';
import 'package:medical_service_app/features/login/presentation/widget/password_reset.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeCubit = context.read<HomeCubit>();

    return BlocConsumer<HomeCubit, HomeStates>(
      listener: (context, state) {
        if (state is HomeLoginSuccessState) {
          context.pushReplacement<Widget>(Routes.homeRoute);
        } else if (state is HomeLoginErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email or password is incorrect"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // خلفية جمالية بتدرج وأشكال شفافة
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFEEF2FF),
                      Color(0xFFE0EAFF),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // شكل جمالي بالبلور
              Positioned(
                top: -100,
                left: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3E69FE).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -120,
                right: -100,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6FA8FF).withValues(alpha:0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // محتوى الشاشة
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22.w,
                      vertical: 30.h,
                    ),
                    child: Column(
                      children: [
                        // شعار التطبيق
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            color: Color(0xFF3E69FE),
                            size: 44,
                          ),
                        ),
                        SizedBox(height: 25.h),
                        const Text(
                          "Welcome Back ",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E69FE),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Login to your medical account",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 40.h),

                        // Glassmorphism Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(22.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha:0.3),
                                ),
                              ),
                              child: Form(
                                key: loginFormKey,
                                child: Column(
                                  children: [
                                    CustomTextFormField(
                                      controller:
                                          homeCubit.loginEmailController,
                                      preffixIcon: const Icon(
                                        Icons.email_outlined,
                                      ),
                                      hintText: 'Email address',
                                      textInputType: TextInputType.emailAddress,
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Please enter your email'
                                          : null,
                                    ),
                                    SizedBox(height: 18.h),
                                    PasswordField(
                                      controller:
                                          homeCubit.loginPasswordController,
                                      hintText: 'Password',
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Please enter your password'
                                          : null,
                                    ),
                                    SizedBox(height: 12.h),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<Object>(
                                              builder: (context) =>
                                                  const ResetPasswordView(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Forgot Password?",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 30.h),

                                    // زر الدخول المتدرج
                                    GestureDetector(
                                      onTap: () {
                                        if (loginFormKey.currentState!
                                            .validate()) {
                                          homeCubit.login();
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        width: double.infinity,
                                        height: 52.h,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF3E69FE),
                                              Color(0xFF6FA8FF),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF3E69FE,
                                              ).withValues(alpha:0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          state is HomeLoginLoadingState
                                              ? "Loading..."
                                              : "Login",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),

                                    const OrDivider(),
                                    SizedBox(height: 12.h),

                                    HaveAnAccountSection(
                                      leadingText: "Don’t have an account?",
                                      actionText: " Sign Up",
                                      onTap: () => context.push<Widget>(
                                        Routes.signupRoute,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
