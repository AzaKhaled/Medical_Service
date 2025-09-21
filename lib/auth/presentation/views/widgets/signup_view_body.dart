import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_service_app/auth/presentation/cubits/signup/signup_cubit.dart';
import 'package:medical_service_app/auth/presentation/views/sigin_view.dart';
import 'package:medical_service_app/auth/presentation/views/widgets/have_an_account_section.dart';
import 'package:medical_service_app/auth/presentation/views/widgets/password_field.dart';
import 'package:medical_service_app/auth/presentation/views/widgets/public_offer_section.dart';
import 'package:medical_service_app/core/utils/app_colors.dart';
import 'package:medical_service_app/core/utils/app_text_styles.dart';
import 'package:medical_service_app/core/utils/customtextfiled.dart';
import 'package:medical_service_app/core/utils/widgets/custombutton.dart';
import 'package:provider/provider.dart';

class SignupViewBody extends StatefulWidget {
  const SignupViewBody({super.key});

  @override
  State<SignupViewBody> createState() => _SignupViewBodyState();
}

class _SignupViewBodyState extends State<SignupViewBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  late String email, userName, password;
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: formKey,
            autovalidateMode: autovalidateMode,
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
                        color: const Color(0xFF3E69FE).withOpacity(0.18),
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
                Text('create Account', style: TextStyles.montserrat700_36),
                SizedBox(height: 24.h),

                // Username field
                CustomTextFormField(
                  onSaved: (value) {
                    userName = value!;
                  },
                  preffixIcon: const Icon(Icons.person),
                  hintText: 'username',
                  textInputType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseEnterUsername';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Email field
                CustomTextFormField(
                  onSaved: (value) {
                    email = value!;
                  },
                  preffixIcon: const Icon(Icons.email),
                  hintText: 'email',
                  textInputType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseEnterEmail';
                    } else if (!EmailValidator.validate(value)) {
                      return 'invalidEmail';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Password
                PasswordField(
                  controller: passwordController,
                  hintText: 'password',
                  onSaved: (value) => password = value!,
                ),
                SizedBox(height: 16.h),

                // Confirm Password
                PasswordField(
                  controller: confirmPasswordController,
                  hintText: 'confirmPassword',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseConfirmPassword';
                    } else if (value != passwordController.text) {
                      return 'passwords DoNot Match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                const PublicOffireSection(),
                SizedBox(height: 30.h),

                CustomButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      context.read<SignupCubit>().signUp(
                        email,
                        password,
                        userName,
                      );
                    } else {
                      setState(() {
                        autovalidateMode = AutovalidateMode.always;
                      });
                    }
                  },
                  text: 'Register',
                ),
                SizedBox(height: 16.h),

                HaveAnAccountSection(
                  leadingText: 'already Have Account',
                  actionText: ' Login',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SiginView(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
