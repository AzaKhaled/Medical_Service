import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_state.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/doctor_details_view.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/doctor_similar.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/doctorcard.dart';

class DoctorsListBuilder extends StatefulWidget {
  const DoctorsListBuilder({super.key});

  @override
  State<DoctorsListBuilder> createState() => _DoctorsListBuilderState();
}

class _DoctorsListBuilderState extends State<DoctorsListBuilder> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    homeCubit.getDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<HomeCubit, HomeStates>(
        buildWhen: (previous, current) =>
            current is HomeGetDoctorsSuccessState ||
            current is HomeGetDoctorsErrorState ||
            current is HomeGetDoctorsLoadingState,
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
            return const Center(child: Text("Error, try again later"));
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
                    (double.tryParse(doctor['rating']?.toString() ?? "0") ??
                            0.0)
                        .toStringAsFixed(1),
                  ),
                  onDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<Object>(
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
    );
  }
}
