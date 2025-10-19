import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medical_service_app/core/theme/colors.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_state.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/service_shimme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

final Map<String, dynamic> serviceIcons = {
  "Cardiology": FontAwesomeIcons.heartPulse,
  "Dentistry": FontAwesomeIcons.tooth,
  "Neurology": FontAwesomeIcons.brain,
  "Orthopedics": FontAwesomeIcons.bone,
  "Pediatrics": FontAwesomeIcons.baby,
  "Dermatology": FontAwesomeIcons.userDoctor,
  "Ophthalmology": FontAwesomeIcons.eye,
  "Psychiatry": FontAwesomeIcons.headSideVirus,
  "Radiology": FontAwesomeIcons.xRay,
  "Oncology": FontAwesomeIcons.ribbon,
  "Surgery": FontAwesomeIcons.syringe,
  "ENT": FontAwesomeIcons.earListen,
  "Urology": FontAwesomeIcons.water,
  "Gynecology": FontAwesomeIcons.venus,
  "Emergency99": FontAwesomeIcons.truckMedical,
};

class ServicesView extends StatefulWidget {
  const ServicesView({super.key});

  @override
  State<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends State<ServicesView> {
  @override
  void initState() {
    super.initState();
    homeCubit.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      buildWhen: (previous, current) =>
          current is HomeGetCategoriesSuccessState ||
          current is HomeGetCategoriesErrorState ||
          current is HomeGetCategoriesLoadingState,
      builder: (context, state) {
        final categories = homeCubit.categories;
        final controller = PageController();
        final pages = categories.isNotEmpty
            ? List<Widget>.generate((categories.length / 4).ceil(), (
                pageIndex,
              ) {
                final start = pageIndex * 3;
                final end = (start + 3).clamp(0, categories.length);
                final visibleItems = categories.sublist(start, end);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: visibleItems.map<Widget>((cat) {
                    final catName = cat['name'] ?? "Unknown";
                    final icon = serviceIcons[catName] ?? Icons.local_hospital;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          homeCubit.getDoctorsByCategory(cat['id'].toString());
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 30, color: Colors.white),
                              const SizedBox(height: 8),
                              Text(
                                catName,
                                style: const TextStyle(color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              })
            : <Widget>[];
        return Padding(
          padding: const EdgeInsets.only(left: 14.0, right: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Services",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.h),
              SizedBox(
                height: 100,
                child: categories.isNotEmpty
                    ? PageView(controller: controller, children: pages)
                    : homeCubit.state is HomeGetCategoriesLoadingState
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ServiceItemShimmer(),
                          ServiceItemShimmer(),
                          ServiceItemShimmer(),
                          ServiceItemShimmer(),
                        ],
                      )
                    : homeCubit.state is HomeGetCategoriesErrorState
                    ? const Center(child: Text("Error loading categories"))
                    : const Center(child: Text("No categories available")),
              ),
              if (pages.isNotEmpty) SizedBox(height: 8.h),
              if (pages.isNotEmpty)
                Center(
                  child: SmoothPageIndicator(
                    controller: controller,
                    count: pages.length,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: AppColors.primaryColor,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
