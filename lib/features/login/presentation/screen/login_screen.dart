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
import 'package:medical_service_app/features/login/presentation/widget/or_divider.dart';
import 'package:medical_service_app/features/login/presentation/widget/password_field.dart';
import 'package:medical_service_app/features/login/presentation/widget/unified_password_reset.dart';

class LoginScreen extends StatelessWidget {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeStates>(
      listener: (context, state) {
        if (state is HomeLoginSuccessState) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Login successful'),
          //     backgroundColor: Colors.green,
          //   ),
          // );
          context.pushReplacement<Widget>(Routes.homeRoute);
        }
        if (state is HomeLoginErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
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
                  key: loginFormKey,
                  child: Column(
                    children: [
                      SizedBox(height: 15.h),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF3E69FE),
                            ),
                          ),
                          const Icon(
                            Icons.health_and_safety,
                            size: 36,
                            color: Colors.white,
                          ),
                        ],
                      ),

                      SizedBox(height: 32.h),
                      const Text(
                        'Welcome Back',
                        style: TextStyles.montserrat700_36,
                      ),
                      SizedBox(height: 24.h),

                      // Email
                      CustomTextFormField(
                        controller: homeCubit.loginEmailController,
                        preffixIcon: const Icon(Icons.person_rounded),
                        hintText: 'Enter your email',
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
                        controller: homeCubit.loginPasswordController,
                        hintText: 'Enter your password',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
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
                              'Forgot Password?',
                              style: TextStyles.montserrat400_12_red,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 35.h),
                      CustomButton(
                        onPressed: () {
                          if (loginFormKey.currentState!.validate()) {
                            homeCubit.login();
                          }
                        },
                        text: state is HomeLoginLoadingState
                            ? "Loading..."
                            : "Login",
                      ),
                      SizedBox(height: 16.h),

                      const OrDivider(),
                      SizedBox(height: 16.h),

                      HaveAnAccountSection(
                        leadingText: 'Don\'t have an account?',
                        actionText: ' Sign Up',
                        onTap: () {
                          context.push<Widget>(Routes.signupRoute);
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
