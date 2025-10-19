import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_service_app/core/theme/colors.dart';
import 'package:medical_service_app/core/utils/cubit/favorite_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/appointment_view.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/info_icons.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/review_view.dart';

class DoctorDetailsView extends StatefulWidget {
  const DoctorDetailsView({super.key, required this.doctor});

  final Map<String, dynamic> doctor;

  @override
  State<DoctorDetailsView> createState() => _DoctorDetailsViewState();
}

class _DoctorDetailsViewState extends State<DoctorDetailsView> {
  bool isExpanded = false;
  int reviewsCount = 0;

  @override
  void initState() {
    super.initState();
    fetchReviewsCount();
  }

  Future<void> fetchReviewsCount() async {
    final count = await context.read<HomeCubit>().getReviewsCount(
      widget.doctor['id'].toString(),
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
            Navigator.pop(context);
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
                      (widget.doctor['image_url'] != null &&
                          widget.doctor['image_url'].toString().isNotEmpty)
                      ? Image.network(
                          widget.doctor['image_url'],
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
                        context.read<FavoriteCubit>().addToFavorites(
                          widget.doctor['id'].toString(),
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
                  widget.doctor['name'] ?? "Unknown Doctor",
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
                            widget.doctor['rating']?.toString() ?? "0",
                          )?.toStringAsFixed(1) ??
                          "0.0",
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              widget.doctor['specialty_name'] ?? "Unknown Specialty",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InfoCard(
                  icon: Icons.people,
                  value: widget.doctor['patients_count']?.toString() ?? "0",
                  label: "Patients",
                ),
                InfoCard(
                  icon: Icons.task_alt,
                  value: widget.doctor['experience_years']?.toString() ?? "0",
                  label: "Years",
                ),
                InfoCard(
                  icon: Icons.star,
                  value:
                      double.tryParse(
                        widget.doctor['rating']?.toString() ?? "0",
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
                          doctorId: widget.doctor['id'].toString(),
                        ),
                      ),
                    );

                    if (refresh == true) {
                      // ✅ هات الدكتور المحدث
                      if (!context.mounted) return;
                      final updatedDoctor = await context
                          .read<HomeCubit>()
                          .getDoctorById(widget.doctor['id'].toString());

                      if (updatedDoctor != null) {
                        setState(() {
                          widget.doctor['rating'] = updatedDoctor['rating'];
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
                widget.doctor['bio'] ?? "No bio available",
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
                  Navigator.push(
                    context,
                    MaterialPageRoute<Object>(
                      builder: (context) => AppointmentView(
                        doctorId: widget.doctor['id'].toString(),
                      ),
                    ),
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
