import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_service_app/core/models/doctor_model.dart';
import 'package:medical_service_app/core/theme/colors.dart';
import 'package:medical_service_app/core/utils/constants/routes.dart';
import 'package:medical_service_app/core/utils/cubit/favorite_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/extensions/context_extension.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/info_icons.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/review_view.dart';

class DoctorDetailsView extends StatefulWidget {
  const DoctorDetailsView({super.key});

  @override
  State<DoctorDetailsView> createState() => _DoctorDetailsViewState();
}

class _DoctorDetailsViewState extends State<DoctorDetailsView> {
  bool isExpanded = false;
  int reviewsCount = 0;
  late DoctorModel doctor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    doctor =
        context.getArg()
            as DoctorModel; // ✅ نحصل على الـ DoctorModel من الـ arguments
    fetchReviewsCount();
  }

  Future<void> fetchReviewsCount() async {
    final count = await homeCubit.getReviewsCount(
      doctor.id.toString(),
    );
    setState(() {
      reviewsCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text('Doctor')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.pop;
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child:
                      (doctor.imageUrl != null &&
                          doctor.imageUrl.toString().isNotEmpty)
                      ? Image.network(
                          doctor.imageUrl!,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                "assets/images/doctor.jfif",
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                        )
                      : Image.asset(
                          "assets/images/doctor.jfif",
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        favoriteCubit.addToFavorites(
                          doctor.id.toString(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to favorites')),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  doctor.name ?? "Unknown Doctor",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      double.tryParse(
                            doctor.rating?.toString() ?? "0",
                          )?.toStringAsFixed(1) ??
                          "0.0",
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              doctor.specialtyName ?? "Unknown Specialty",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InfoCard(
                  icon: Icons.people,
                  value: doctor.patientsCount?.toString() ?? "0",
                  label: "Patients",
                ),
                InfoCard(
                  icon: Icons.task_alt,
                  value: doctor.experienceYears?.toString() ?? "0",
                  label: "Years",
                ),
                InfoCard(
                  icon: Icons.star,
                  value:
                      double.tryParse(
                        doctor.rating?.toString() ?? "0",
                      )?.toStringAsFixed(1) ??
                      "0.0",
                  label: "Rating",
                ),
                GestureDetector(
                  child: InfoCard(
                    icon: Icons.message,
                    value: reviewsCount.toString(),
                    label: "Reviews",
                  ),
                  onTap: () async {
                    final refresh = await Navigator.push(
                      context,
                      MaterialPageRoute<Object>(
                        builder: (context) => ReviewView(
                          doctorId: doctor.id.toString(),
                        ),
                      ),
                    );

                    if (refresh == true) {
                      // ✅ هات الدكتور المحدث
                      if (!context.mounted) return;
                      final updatedDoctor = await context
                          .read<HomeCubit>()
                          .getDoctorById(doctor.id.toString());

                      if (updatedDoctor != null) {
                        setState(() {
                          doctor.rating = updatedDoctor.rating;
                        });
                      }

                      // ✅ هات عدد الريفيوهات الجديد
                      fetchReviewsCount();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // About me
            const Text(
              "About Me",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // نص الـ about me + read more
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(
                doctor.bio ?? "No bio available",
                maxLines: isExpanded ? null : 2,
                overflow: isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(isExpanded ? "Read Less" : "Read More"),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push<String>(
                    Routes.appointmentsRoute,
                    arguments: doctor.id.toString(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: AppColors.primaryColor,
                ),
                child: const Text(
                  "Book Appointment",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
