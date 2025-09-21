// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:sweet_pal/auth/presentation/cubits/profile/profile_cubit.dart';
// import 'package:sweet_pal/auth/presentation/views/widgets/change_profile_form.dart';
// import 'package:sweet_pal/core/services/storage_service.dart';
// import 'package:sweet_pal/core/services/supabase_auth_service.dart';
// import 'package:sweet_pal/core/utils/app_colors.dart';

// class ChangeProfileView extends StatelessWidget {
//   const ChangeProfileView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => ProfileCubit(SupabaseAuthService(), StorageService()),
//       child: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           title: const Center(
//             child: Text(
//               'Change Profile',
//               style: TextStyle(color: AppColors.secondaryColor),
//             ),
//           ),
//         ),

//         body: const ChangeProfileForm(),
//       ),
//     );
//   }
// }
