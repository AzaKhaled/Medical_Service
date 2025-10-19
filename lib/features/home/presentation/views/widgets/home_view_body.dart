import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_state.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/doctors_list_builder.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/header_section.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/services_view.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    homeCubit.getTopRatedDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<HomeCubit, HomeStates>(
          builder: (context, state) {
            final user = homeCubit.currentUserData;
            return HeaderSection(
              name: user?['name'],
              avatarUrl: user?['image_url'],
              searchController: _searchController,
              onSearchChanged: (value) {
                homeCubit.searchDoctors(value);
              },
            );
          },
        ),
        const SizedBox(height: 10),
        const ServicesView(),
        const SizedBox(height: 10),
        const DoctorsListBuilder(),
      ],
    );
  }
}

//  مثال: السماح للمستخدم بقراءة الإشعارات الخاصة به فقط
// CREATE POLICY "Users can read their own notifications"
// ON public.notifications
// FOR SELECT
// USING (auth.uid() = user_id);
