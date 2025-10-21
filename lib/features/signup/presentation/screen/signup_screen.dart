import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_service_app/core/utils/constants/app_text_styles.dart';
import 'package:medical_service_app/core/utils/constants/custombutton.dart';
import 'package:medical_service_app/core/utils/constants/customtextfiled.dart';
import 'package:medical_service_app/core/utils/constants/routes.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_state.dart';
import 'package:medical_service_app/core/utils/extensions/context_extension.dart';
import 'package:medical_service_app/features/login/presentation/widget/have_an_account_section.dart';
import 'package:medical_service_app/features/login/presentation/widget/password_field.dart';
import 'package:medical_service_app/features/login/presentation/widget/public_offer_section.dart';

class SignupScreen extends StatelessWidget {
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeStates>(
      listener: (context, state) {
        if (state is HomeSignupSuccessState) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Signup successful'),
          //     backgroundColor: Colors.green,
          //   ),
          // );
          context.pushReplacement<Object>(Routes.homeRoute);
        }
        if (state is HomeSignupErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: signUpFormKey,
                  child: Column(
                    children: [
                      SizedBox(height: 15.h),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(
                                0xFF3E69FE,
                              ).withValues(alpha: 0.18),
                            ),
                          ),
                          const Icon(
                            Icons.priority_high,
                            size: 36,
                            color: Color(0xFF3E69FE),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      const Text(
                        'Create Account',
                        style: TextStyles.montserrat700_36,
                      ),
                      SizedBox(height: 24.h),

                      // Username
                      CustomTextFormField(
                        controller: homeCubit.signUpNameController,
                        preffixIcon: const Icon(Icons.person),
                        hintText: 'Username',
                        textInputType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Email
                      CustomTextFormField(
                        controller: homeCubit.signUpEmailController,
                        preffixIcon: const Icon(Icons.email),
                        hintText: 'Email',
                        textInputType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Password
                      PasswordField(
                        controller: homeCubit.signUpPasswordController,
                        hintText: 'Password',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      const PublicOffireSection(),
                      SizedBox(height: 30.h),

                      CustomButton(
                        onPressed: () {
                          if (signUpFormKey.currentState!.validate()) {
                            homeCubit.signup();
                          }
                        },
                        text: state is HomeSignupLoadingState
                            ? "Loading..."
                            : "Register",
                      ),
                      SizedBox(height: 16.h),

                      HaveAnAccountSection(
                        leadingText: 'Already have an account?',
                        actionText: ' Login',
                        onTap: () {
                          context.pop; // أو يوديك لصفحة اللوجين
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
