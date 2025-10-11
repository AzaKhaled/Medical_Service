import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_state.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/doctor_details_view.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/doctor_similar.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/doctorcard.dart';
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
    final homeCubit = context.read<HomeCubit>();

    // ✅ استدعاء بيانات المستخدم عشان الاسم والصورة تظهر في الهيدر
    homeCubit.getCurrentUserData();
     homeCubit.initNotifications();
    homeCubit.getDoctors();
    homeCubit.getCategories();
    homeCubit.getTopRatedDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🟡 BlocBuilder عشان نجيب الاسم والصورة من Cubit
        BlocBuilder<HomeCubit, HomeStates>(
          builder: (context, state) {
            final homeCubit = context.read<HomeCubit>();
            final user = homeCubit.currentUserData; // جاي من Cubit

            return HeaderSection(
              name: user?['name'],
              avatarUrl: user?['image_url'],
              searchController: _searchController,
              onSearchChanged: (value) {
                context.read<HomeCubit>().searchDoctors(value);
              },
            );
            ;
          },
        ),

        const SizedBox(height: 10),
        const ServicesView(),
        const SizedBox(height: 10),

        Expanded(
  child: BlocBuilder<HomeCubit, HomeStates>(
    builder: (context, state) {
      if (state is HomeGetDoctorsLoadingState) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: 5,
          itemBuilder: (context, index) => const DoctorCardShimmer(),
        );
      }

      if (state is HomeGetDoctorsErrorState) {
        debugPrint('Error fetching doctors: ${state.error}');
        return Center(child: Text("error try again later"));
      }

      if (state is HomeGetDoctorsSuccessState ||
          state is HomeGetTopRatedDoctorsSuccessState) {
        final doctors = state is HomeGetDoctorsSuccessState
            ? state.doctors
            : (state as HomeGetTopRatedDoctorsSuccessState).doctors;

        if (doctors.isEmpty) {
          return const Center(child: Text("No doctors found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return DoctorCard(
              imageUrl: doctor['image_url'] ?? "assets/images/doctor.jfif",
              name: doctor['name'] ?? "Unknown",
              level: doctor['specialty_name'] ?? "Unknown",
              workTime: doctor['working_hours'] ?? "N/A",
              price: doctor['price']?.toString() ?? "0",
              rating: double.parse(
                (double.tryParse(doctor['rating']?.toString() ?? "0") ?? 0.0)
                    .toStringAsFixed(1),
              ),
              onDetails: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorDetailsView(doctor: doctor),
                  ),
                );
              },
            );
          },
        );
      }

      return const SizedBox();
    },
  ),
),
],
    );
  }
}


//  مثال: السماح للمستخدم بقراءة الإشعارات الخاصة به فقط
// CREATE POLICY "Users can read their own notifications"
// ON public.notifications
// FOR SELECT
// USING (auth.uid() = user_id);
