import 'package:flutter/material.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/doctors_list_builder.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/header_section.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/services_view.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {

  @override
  void initState() {
    super.initState();
    homeCubit.getTopRatedDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        HeaderSection(),
        SizedBox(height: 10),
        ServicesView(),
        SizedBox(height: 10),
        DoctorsListBuilder(),
      ],
    );
  }
}

//  مثال: السماح للمستخدم بقراءة الإشعارات الخاصة به فقط
// CREATE POLICY "Users can read their own notifications"
// ON public.notifications
// FOR SELECT
// USING (auth.uid() = user_id);
