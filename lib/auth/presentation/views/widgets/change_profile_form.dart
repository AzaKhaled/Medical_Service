// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:sweet_pal/auth/presentation/cubits/profile/profile_cubit.dart';
// import 'package:sweet_pal/auth/presentation/views/widgets/password_field.dart';
// import 'package:sweet_pal/core/utils/app_colors.dart';
// import 'package:sweet_pal/core/providers/theme_provider.dart';
// import 'package:sweet_pal/core/utils/localization_helper.dart';
// import 'package:sweet_pal/features/home/presentation/views/widgets/header_section.dart';

// class ChangeProfileForm extends StatefulWidget {
//   const ChangeProfileForm({super.key});

//   @override
//   State<ChangeProfileForm> createState() => _ChangeProfileFormState();
// }

// class _ChangeProfileFormState extends State<ChangeProfileForm> {
//   File? _image;
//   String? _currentAvatarUrl;
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _currentPasswordController =
//       TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   bool _isUploading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentUserData();
//   }

//   Future<void> _loadCurrentUserData() async {
//     final user = Supabase.instance.client.auth.currentUser;
//     if (user != null) {
//       final response = await Supabase.instance.client
//           .from('users')
//           .select()
//           .eq('auth_id', user.id)
//           .maybeSingle();

//       if (response != null && mounted) {
//         setState(() {
//           _currentAvatarUrl = response['avatar_url'];
//         });
//       }
//     }
//   }

//   Future<void> _pickImage() async {
//     final picked = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 80,
//     );
//     if (picked != null) {
//       setState(() => _image = File(picked.path));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cubit = context.read<ProfileCubit>();

//     return BlocConsumer<ProfileCubit, ProfileState>(
//       listener: (context, state) {
//         if (state is ProfileSuccess) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Center(child: Text(state.message)),
//               backgroundColor: Colors.green,
//             ),
//           );
//         } else if (state is ProfileError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Center(child: Text(state.error)),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: CircleAvatar(
//                   radius: 60,
//                   backgroundImage: _image != null
//                       ? FileImage(_image!)
//                       : (_currentAvatarUrl != null &&
//                               _currentAvatarUrl!.isNotEmpty)
//                           ? NetworkImage(_currentAvatarUrl!)
//                           : const AssetImage('assets/images/person.png')
//                               as ImageProvider,
//                   child: _image == null &&
//                           (_currentAvatarUrl == null ||
//                               _currentAvatarUrl!.isEmpty)
//                       ? Icon(
//                           Icons.camera_alt,
//                           size: 40,
//                           color: Provider.of<ThemeProvider>(context).secondaryTextColor,
//                         )
//                       : null,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 LocalizationHelper.translate('Change image', 'تغيير الصورة'),
//                 style: TextStyle(
//                   fontSize: 14, 
//                   color: Provider.of<ThemeProvider>(context).secondaryTextColor,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               if (_image != null)
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: _isUploading
//                         ? null
//                         : () async {
//                             setState(() => _isUploading = true);
// final imageUrl = await cubit.uploadImage(_image!);
// await _loadCurrentUserData();

// // Notify the HeaderSection to refresh the avatar
// WidgetsBinding.instance.addPostFrameCallback((_) {
//   final headerSectionState = HeaderSection.headerKey.currentState;
//   headerSectionState?.fetchUserData();
// });
//                             setState(() => _isUploading = false);
//                           },
//                     label: Text(_isUploading 
//                       ? LocalizationHelper.translate('Uploading...', 'جاري التحميل...') 
//                       : LocalizationHelper.translate('Upload Image', 'تحميل الصورة')),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       foregroundColor: Provider.of<ThemeProvider>(context).textColor,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//               const SizedBox(height: 30),
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Provider.of<ThemeProvider>(context).scaffoldBackgroundColor,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         LocalizationHelper.changePasswordText,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Provider.of<ThemeProvider>(context).textColor,
//                         ),
//                       ),
//                       const SizedBox(height: 20),

//                       // Current Password
//                       PasswordField(
//                         controller: _currentPasswordController,
//                         hintText: LocalizationHelper.translate('Current Password', 'كلمة المرور الحالية'),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return LocalizationHelper.translate('Please enter your current password', 'يرجى إدخال كلمة المرور الحالية');
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),

//                       // New Password
//                       PasswordField(
//                         controller: _newPasswordController,
//                         hintText: LocalizationHelper.translate('New Password', 'كلمة المرور الجديدة'),
//                         validator: (value) {
//                           if (value == null || value.length < 6) {
//                             return LocalizationHelper.translate('Password must be at least 6 characters', 'يجب أن تكون كلمة المرور 6 أحرف على الأقل');
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),

//                       // Confirm Password
//                       PasswordField(
//                         controller: _confirmPasswordController,
//                         hintText: LocalizationHelper.confirmPasswordText,
//                         validator: (value) {
//                           if (value != _newPasswordController.text) {
//                             return LocalizationHelper.passwordsDoNotMatchText;
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 24),

//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             if (_formKey.currentState!.validate()) {
//                               final user =
//                                   Supabase.instance.client.auth.currentUser;
//                               if (user != null) {
//                                 try {
//                                   final response = await Supabase.instance.client
//                                       .auth
//                                       .signInWithPassword(
//                                           email: user.email!,
//                                           password: _currentPasswordController
//                                               .text);

//                                   if (response.user != null) {
//                                     cubit.changePassword(
//                                         _newPasswordController.text);
//                                   } else {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content:
//                                             Center(child: Text('Current password is incorrect')),
//                                         backgroundColor: Colors.red,
//                                       ),
//                                     );
//                                   }
//                                 } catch (e) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content:
//                                           Center(child: Text('Current password is incorrect')),
//                                       backgroundColor: Colors.red,
//                                     ),
//                                   );
//                                 }
//                               }
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primaryColor,
//                             foregroundColor: Provider.of<ThemeProvider>(context).textColor,
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: Text(LocalizationHelper.changePasswordText),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (state is ProfileLoading)
//                 const Padding(
//                   padding: EdgeInsets.all(20),
//                   child: Center(child: CircularProgressIndicator()),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
