import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_service_app/core/theme/colors.dart';
import 'package:medical_service_app/core/utils/constants/routes.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_state.dart';
import 'package:medical_service_app/core/utils/extensions/context_extension.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/custom_search.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/header_shimmer.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({super.key});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  final TextEditingController _searchController = TextEditingController();

  bool _isValidImageUrl(String? url) {
    return url != null &&
        url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'));
  }

  @override
  void initState() {
    super.initState();
    homeCubit.getCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      buildWhen: (previous, current) =>
          current is HomeGetUserLoadingState ||
          current is HomeGetUserSuccessState ||
          current is HomeGetUserErrorState,
      builder: (context, state) {
        final userData = homeCubit.currentUserData;
        // 🟡 لو البيانات لم تُحمّل بعد
        if (state is HomeGetUserLoadingState || userData == null) {
          return const UserHeaderShimmer();
        }

        // 🟥 لو حصل خطأ
        if (state is HomeGetUserErrorState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Error loading user data 😔\n${state.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    backgroundImage: _isValidImageUrl(userData.imageUrl)
                        ? NetworkImage(userData.imageUrl!)
                        : null,
                    onBackgroundImageError: _isValidImageUrl(userData.imageUrl)
                        ? (_, _) {
                            debugPrint(
                              'Error loading image: ${userData.imageUrl}',
                            );
                          }
                        : null,
                    child: !_isValidImageUrl(userData.imageUrl)
                        ? const Icon(
                            Icons.person,
                            color: AppColors.primaryColor,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      context.push<Widget>(Routes.notificationsRoute);

                      // Navigator.pushNamed(
                      //   context,
                      //   '/notifications',
                      // ); // نعمل Route للصفحة الجديدة
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                userData.name != null ? 'Hello ${userData.name}' : 'Hello...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomSearch(
                      controller: _searchController,
                      onChanged: (value) {
                        homeCubit.searchDoctors(value);
                      },
                      hintText: 'Search',
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.tune, color: Colors.black),
                  // Icon(Icons.filt, color: Colors.black),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
