import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_service_app/auth/presentation/views/sigin_view.dart';
import 'package:medical_service_app/auth/presentation/views/widgets/password_field.dart';
import 'package:medical_service_app/core/utils/app_text_styles.dart';
import 'package:medical_service_app/core/utils/widgets/custombutton.dart';
import 'package:medical_service_app/core/utils/widgets/customtextfiled.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  late String email;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isResetMode = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: formKey,
          autovalidateMode: autovalidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80.h),
              Center(
                child: Text(
                  _isResetMode ? 'Change Password' : 'Forgot Password',
                  style: TextStyles.montserrat700_36.copyWith(fontSize: 28.sp),
                ),
              ),
              SizedBox(height: 35.h),

              // ===== Forget Password Mode =====
              if (!_isResetMode) ...[
                CustomTextFormField(
                  onSaved: (value) {
                    email = value!.trim();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Invalid email address';
                    }
                    return null;
                  },
                  preffixIcon: const Icon(Icons.email_rounded),
                  hintText: 'Email',
                  textInputType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text('*', style: TextStyles.montserrat400_12_red),
                    SizedBox(width: 4.w),
                    const Flexible(
                      child: Text(
                        'We will send you a message to reset your password',
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                CustomButton(
                  text: 'Send Reset Email',
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      try {
                        final supabase = Supabase.instance.client;
                        await supabase.auth.resetPasswordForEmail(
                          email,
                          redirectTo: 'myapp://reset-password?type=recovery',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password reset email sent'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        setState(() {
                          _isResetMode = true;
                        });
                      } on AuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } catch (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unexpected error occurred'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      setState(() {
                        autovalidateMode = AutovalidateMode.always;
                      });
                    }
                  },
                ),
              ]

              // ===== Reset Password Mode =====
              else ...[
                PasswordField(
                  controller: passwordController,
                  hintText: 'New Password',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                PasswordField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30.h),
                CustomButton(
                  text: 'Change Password',
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        await Supabase.instance.client.auth.updateUser(
                          UserAttributes(password: passwordController.text),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SiginView(),
                          ),
                        );
                      } on AuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      setState(() {
                        autovalidateMode = AutovalidateMode.always;
                      });
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
