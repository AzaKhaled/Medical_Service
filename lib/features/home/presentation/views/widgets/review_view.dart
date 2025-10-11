import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_state.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/custom_search.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/review_item.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewView extends StatefulWidget {
  const ReviewView({super.key, required this.doctorId});

  final String doctorId;

  @override
  State<ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<ReviewView> {
  final TextEditingController commentController = TextEditingController();
  double selectedRating = 0;

  @override
  void initState() {
    super.initState();
    HomeCubit.get(context).getReviews(widget.doctorId);
  }

  @override
  Widget build(BuildContext context) {
    final homeCubit = HomeCubit.get(context);
    final currentUser = homeCubit.currentUserData;
    final userImageUrl = currentUser?['image_url'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: Column(
        children: [
          // ✅ عرض التعليقات
          Expanded(
            child: BlocBuilder<HomeCubit, HomeStates>(
              builder: (context, state) {
                if (state is HomeGetReviewsLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is HomeGetReviewsSuccessState) {
                  final reviews = state.reviews;

                  if (reviews.isEmpty) {
                    return const Center(child: Text("No reviews yet."));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];

                      final userName = review['user_name'] ?? "Unknown";

                      final createdAt = DateTime.tryParse(
                        review['created_at'] ?? "",
                      );
                      final timeAgoText = createdAt != null
                          ? timeago.format(createdAt, locale: 'en')
                          : "";

                      final imageUrl = review['user_image'] ?? "";

                      return ReviewItem(
                        userName: userName,
                        timeAgo: timeAgoText,
                        rating: review['rating'] ?? 0,
                        comment: review['comment'] ?? "",
                        userImage: imageUrl,
                      );
                    },
                  );
                } else if (state is HomeGetReviewsErrorState) {
                  return Center(child: Text("Error: ${state.error}"));
                }
                return const SizedBox();
              },
            ),
          ),

          // ✅ الريتنج + إدخال تعليق جديد
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // ⭐️ ويدجت اختيار النجوم
                RatingBar.builder(
                  initialRating: selectedRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    setState(() {
                      selectedRating = rating;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // 📝 خانة الكومنت + زر الإرسال + صورة المستخدم
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (commentController.text.trim().isNotEmpty &&
                            selectedRating > 0) {
                          homeCubit.addReview(
                            doctorId: widget.doctorId,
                            rating: selectedRating,
                            comment: commentController.text.trim(),
                          );
                          commentController.clear();
                          setState(() {
                            selectedRating = 0;
                          });
                        }
                      },
                      child: const Icon(
                        Icons.send,
                        size: 30,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomSearch(
                        controller: commentController,
                        onChanged: (v) {},
                        hintText: 'Write your review...',
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          (userImageUrl != null &&
                              userImageUrl.toString().isNotEmpty)
                          ? NetworkImage(userImageUrl)
                          : null,
                      child:
                          (userImageUrl == null ||
                              userImageUrl.toString().isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 24,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
