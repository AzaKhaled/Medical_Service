import 'package:flutter/material.dart';

class ReviewItem extends StatelessWidget {
  final String userName;
  final String timeAgo;
  final double rating;
  final String comment;
  final String userImage;

  const ReviewItem({
    super.key,
    required this.userName,
    required this.timeAgo,
    required this.rating,
    required this.comment,
    required this.userImage,
  });

  bool _isValidNetworkImage(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = _isValidNetworkImage(userImage);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧑‍⚕️ صورة المستخدم أو الأيقونة الافتراضية
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            backgroundImage: isNetwork && userImage.isNotEmpty
                ? NetworkImage(userImage)
                : (userImage.isNotEmpty
                      ? AssetImage(userImage) as ImageProvider
                      : null),
            onBackgroundImageError: isNetwork
                ? (_, _) {
                    debugPrint('❌ Failed to load image: $userImage');
                  }
                : null,
            child: (userImage.isEmpty)
                ? const Icon(Icons.person, size: 30, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),

          // 📝 بيانات الريفيو
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الاسم + الوقت
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // ⭐️ التقييم
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border_outlined,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 8),

                // 💬 التعليق
                Text(
                  comment,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
