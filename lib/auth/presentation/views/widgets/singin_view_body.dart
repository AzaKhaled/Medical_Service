import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_service_app/auth/presentation/cubits/signin/signin_cubit.dart';
import 'package:medical_service_app/auth/presentation/views/singup_view.dart';
import 'package:medical_service_app/auth/presentation/views/widgets/have_an_account_section.dart';
import 'package:medical_service_app/auth/presentation/views/widgets/or_divider.dart';
import 'package:medical_service_app/auth/presentation/views/widgets/password_field.dart';
import 'package:medical_service_app/auth/presentation/views/widgets/unified_password_reset.dart';
import 'package:medical_service_app/core/utils/app_colors.dart';
import 'package:medical_service_app/core/utils/app_text_styles.dart';
import 'package:medical_service_app/core/utils/customtextfiled.dart';
import 'package:medical_service_app/core/utils/widgets/custombutton.dart';
import 'package:provider/provider.dart';

class SigninViewBody extends StatefulWidget {
  const SigninViewBody({super.key});

  @override
  State<SigninViewBody> createState() => _SigninViewBodyState();
}

class _SigninViewBodyState extends State<SigninViewBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  late String email, password;
  late bool isTermsAccepted = false;

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
                        color: const Color(0xFF3E69FE),
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

                Text('welcome Back', style: TextStyles.montserrat700_36),
                SizedBox(height: 24.h),
                CustomTextFormField(
                  onSaved: (value) {
                    email = value!;
                  },
                  preffixIcon: const Icon(Icons.person_rounded),
                  hintText: 'Enter your email',
                  textInputType: TextInputType.name,
                ),

                SizedBox(height: 16.h),
                PasswordField(
                  hintText: 'Enter your password',
                  onSaved: (value) {
                    password = value!;
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
                          MaterialPageRoute(
                            builder: (context) => const ResetPasswordView(),
                          ),
                        );
                      },
                      child: Text(
                        'forgotPassword',
                        style: TextStyles.montserrat400_12_red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 35.h),
                CustomButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      context.read<SigninCubit>().signIn(email, password);
                    } else {
                      autovalidateMode = AutovalidateMode.always;
                      setState(() {});
                    }
                  },

                  text: 'Login',
                ),
                SizedBox(height: 16.h),
                const OrDivider(),

                SizedBox(height: 16.h),
                HaveAnAccountSection(
                  leadingText: 'already Have Account',
                  actionText: 'Sign Up',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SingUpView(),
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
