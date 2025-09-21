import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_service_app/auth/presentation/views/sigin_view.dart';
import 'package:medical_service_app/auth/presentation/views/singup_view.dart';
import 'package:medical_service_app/core/services/serv_locator.dart';
import 'package:medical_service_app/core/utils/widgets/constat_keys.dart';
import 'package:medical_service_app/futures/home/presentation/views/home_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: AppConstants.Supabase_URL,
    anonKey: AppConstants.Supabase_Key,
  );
  setupServiceLocator();
  runApp(const MedicalService());
}

class MedicalService extends StatelessWidget {
  const MedicalService({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SiginView(),
        );
      },
    );
  }
}
