import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_service_app/core/utils/constants/routes.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_state.dart';
import 'package:medical_service_app/core/utils/extensions/context_extension.dart';
import 'package:medical_service_app/features/setting/views/widgets/settings_tile.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/user_data.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
    homeCubit.getCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<HomeCubit, HomeStates>(
        buildWhen: (previous, current) =>
            current is HomeGetUserLoadingState ||
            current is HomeGetUserSuccessState,

        builder: (context, state) {
          if (state is HomeGetUserLoadingState &&
              homeCubit.currentUserData == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = homeCubit.currentUserData;
          final userName = user!.name;
          final userEmail = user.email;
          final imageUrl = user.imageUrl;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                UserData(
                  name: userName ?? '',
                  email: userEmail,
                  imageUrl: imageUrl,
                ),
                SizedBox(height: 24.h),
                SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Change Profile Image',
                  onTap: () {
                    context.push<Object>(Routes.changeProfileRoute);
                  },
                ),
                SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {
                    context.push<Object>(Routes.changePasswordRoute);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute<Object>(
                    //     builder: (_) => const ChangePasswordView(),
                    //   ),
                    //);
                  },
                ),
                SettingsTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () => homeCubit.signOut(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
