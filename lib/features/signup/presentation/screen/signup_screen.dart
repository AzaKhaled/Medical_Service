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
import 'package:medical_service_app/features/login/presentation/widget/password_field.dart';
import 'package:medical_service_app/features/login/presentation/widget/public_offer_section.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
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
        if (state is HomeSignupSuccessState) {
          context.pushReplacement<Widget>(Routes.homeRoute);
        } else if (state is HomeSignupErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
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
              // 🔹 الخلفية بنفس تصميم اللوجين
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
                    color: const Color(0xFF6FA8FF).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // 🔹 المحتوى بنفس نمط اللوجين
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
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha:0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            color: Color(0xFF3E69FE),
                            size: 44,
                          ),
                        ),
                        SizedBox(height: 25.h),
                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E69FE),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Join our medical community",
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
                                color: Colors.white.withValues(alpha:.85),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha:0.3),
                                ),
                              ),
                              child: Form(
                                key: signUpFormKey,
                                child: Column(
                                  children: [
                                    CustomTextFormField(
                                      controller:
                                          homeCubit.signUpNameController,
                                      preffixIcon: const Icon(
                                        Icons.person_outline,
                                      ),
                                      hintText: 'Full Name',
                                      textInputType: TextInputType.name,
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Please enter your name'
                                          : null,
                                    ),
                                    SizedBox(height: 18.h),
                                    CustomTextFormField(
                                      controller:
                                          homeCubit.signUpEmailController,
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
                                          homeCubit.signUpPasswordController,
                                      hintText: 'Password',
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Please enter your password'
                                          : null,
                                    ),
                                    SizedBox(height: 18.h),

                                    SizedBox(height: 16.h),
                                    const PublicOffireSection(),
                                    SizedBox(height: 30.h),

                                    // 🔹 زر التسجيل المتدرج
                                    GestureDetector(
                                      onTap: () {
                                        if (signUpFormKey.currentState!
                                            .validate()) {
                                          homeCubit.signup();
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
                                              ).withValues(alpha: 0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          state is HomeSignupLoadingState
                                              ? "Creating Account..."
                                              : "Sign Up",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),

                                    HaveAnAccountSection(
                                      leadingText: "Already have an account?",
                                      actionText: " Login",
                                      onTap: () => context.push<Widget>(
                                        Routes.loginRoute,
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
