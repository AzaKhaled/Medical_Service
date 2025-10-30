import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_service_app/core/models/doctor_model.dart';
import 'package:medical_service_app/core/theme/colors.dart';
import 'package:medical_service_app/core/utils/constants/routes.dart';
import 'package:medical_service_app/core/utils/cubit/favorite_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/extensions/context_extension.dart';
import 'package:medical_service_app/features/doctors/view/widgets/info_icons.dart';

class DoctorDetailsView extends StatefulWidget {
  const DoctorDetailsView({super.key});

  @override
  State<DoctorDetailsView> createState() => _DoctorDetailsViewState();
}

class _DoctorDetailsViewState extends State<DoctorDetailsView> {
  bool isExpanded = false;
  bool isGlowing = false; // 👈 حالة الوميض
  int reviewsCount = 0;
  late DoctorModel doctor;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();

    // 👇 وميض كل ثانية
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        isGlowing = !isGlowing;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    doctor = context.getArg() as DoctorModel;
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
                  child: (doctor.imageUrl != null &&
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
            SizedBox(height: 16.h),

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
            SizedBox(height: 8.h),

            Text(
              doctor.specialtyName ?? "Unknown Specialty",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16.h),

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
                  value: double.tryParse(
                            doctor.rating?.toString() ?? "0",
                          )?.toStringAsFixed(1) ??
                      "0.0",
                  label: "Rating",
                ),

                // 🔥 الأيقونة اللي بتنور وتطفي
                GestureDetector(
                  onTap: () async {
                    context.push(
                      Routes.reviewRoute,
                      arguments: doctor.id.toString(),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          Icons.message,
                          key: ValueKey(isGlowing),
                          color: isGlowing
                              ? AppColors.primaryColor // 💡 بينور
                              : Colors.grey, // 💡 بيطفي
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reviewsCount.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Reviews",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            const Text(
              "About Me",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),

            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(
                doctor.bio ?? "No bio available",
                maxLines: isExpanded ? null : 2,
                overflow:
                    isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
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
                child: Text(
                  isExpanded ? "Read Less" : "Read More",
                  style: const TextStyle(color: AppColors.primaryColor),
                ),
              ),
            ),
            SizedBox(height: 24.h),

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
