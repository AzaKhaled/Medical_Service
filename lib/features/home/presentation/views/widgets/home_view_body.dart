import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return  Column(
      children: [
       const HeaderSection(),
        SizedBox(height: 10.h),
       const ServicesView(),
        SizedBox(height: 10.h),
       const DoctorsListBuilder(),
      ],
    );
  }
}
