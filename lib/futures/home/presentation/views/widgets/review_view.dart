import 'package:flutter/material.dart';
import 'package:medical_service_app/futures/home/presentation/views/widgets/custom_search.dart';
import 'package:medical_service_app/futures/home/presentation/views/widgets/review_item.dart';

class ReviewView extends StatelessWidget {
  ReviewView({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final Function(String) onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: const Text('Reviews')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ReviewItem(
                    userName: "Jane Doe",
                    timeAgo: "today",
                    rating: 4,
                    comment:
                        "Great experience! The doctor was very professional and caring.",
                    userImage: "assets/images/d.jfif",
                  ),
                  ReviewItem(
                    userName: "John Smith",
                    timeAgo: "yesterday",
                    rating: 5,
                    comment: "Excellent service and friendly staff!",
                    userImage: "assets/images/doctor.jfif",
                  ),
                  ReviewItem(
                    userName: "Jane Doe",
                    timeAgo: "today",
                    rating: 4,
                    comment:
                        "Great experience! The doctor was very professional and caring.",
                    userImage: "assets/images/d.jfif",
                  ),
                  ReviewItem(
                    userName: "John Smith",
                    timeAgo: "yesterday",
                    rating: 5,
                    comment: "Excellent service and friendly staff!",
                    userImage: "assets/images/doctor.jfif",
                  ),
                  ReviewItem(
                    userName: "Jane Doe",
                    timeAgo: "today",
                    rating: 4,
                    comment:
                        "Great experience! The doctor was very professional and caring.",
                    userImage: "assets/images/d.jfif",
                  ),
                  ReviewItem(
                    userName: "John Smith",
                    timeAgo: "yesterday",
                    rating: 5,
                    comment: "Excellent service and friendly staff!",
                    userImage: "assets/images/doctor.jfif",
                  ),
                  ReviewItem(
                    userName: "Jane Doe",
                    timeAgo: "today",
                    rating: 4,
                    comment:
                        "Great experience! The doctor was very professional and caring.",
                    userImage: "assets/images/d.jfif",
                  ),
                  ReviewItem(
                    userName: "John Smith",
                    timeAgo: "yesterday",
                    rating: 5,
                    comment: "Excellent service and friendly staff!",
                    userImage: "assets/images/doctor.jfif",
                  ),
                ],
              ),
            ),
          ),

          // Row ثابت أسفل الشاشة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    print("Send tapped");
                  },
                  child: const Icon(Icons.send, size: 30, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomSearch(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    hintText: 'Your Review',
                  ),
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("assets/images/d.jfif"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
