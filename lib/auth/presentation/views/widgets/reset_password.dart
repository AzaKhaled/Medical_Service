// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:sweet_pal/core/utils/app_text_styles.dart';
// import 'package:sweet_pal/core/utils/widgets/custombutton.dart';
// import 'package:sweet_pal/auth/presentation/views/widgets/password_field.dart';

// class ResetPasswordView extends StatefulWidget {
//   const ResetPasswordView({super.key});

//   @override
//   State<ResetPasswordView> createState() => _ResetPasswordViewState();
// }

// class _ResetPasswordViewState extends State<ResetPasswordView> {
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
//   String? password;
//   String? confirmPassword;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Form(
//           key: formKey,
//           autovalidateMode: autovalidateMode,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 80.h),

//               Center(
//                 child: Text(
//                   'Reset Password',
//                   style: TextStyles.montserrat700_36.copyWith(fontSize: 28.sp),
//                 ),
//               ),

//               SizedBox(height: 35.h),

//               PasswordField(
//                 hintText: 'New Password',
//                 onSaved: (value) => password = value,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Enter new password';
//                   }
//                   if (value.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }
//                   return null;
//                 },
//               ),

//               SizedBox(height: 16.h),

//               PasswordField(
//                 hintText: 'Confirm Password',
//                 onSaved: (value) => confirmPassword = value,
//                 validator: (value) {
//                   if (value != password) {
//                     return 'Passwords do not match';
//                   }
//                   return null;
//                 },
//               ),

//               SizedBox(height: 30.h),

//               CustomButton(
//                 text: 'Update Password',
//                 onPressed: () async {
//                   if (formKey.currentState!.validate()) {
//                     formKey.currentState!.save();
//                     try {
//                       await Supabase.instance.client.auth.updateUser(
//                         UserAttributes(password: password!),
//                       );

//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Password updated successfully!'),
//                           backgroundColor: Colors.green,
//                         ),
//                       );

//                       Navigator.pop(context);
//                     } on AuthException catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(e.message),
//                           backgroundColor: Colors.red,
//                         ),
//                       );
//                     }
//                   } else {
//                     setState(() {
//                       autovalidateMode = AutovalidateMode.always;
//                     });
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
