import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_state.dart';
import 'package:medical_service_app/core/utils/extensions/context_extension.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = HomeCubit.get(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // إلغاء زر الرجوع التلقائي
        title: const Text('notifications'),
        leading: GestureDetector(
          onTap: () {
            context.pop;
          },
          child: const Icon(Icons.arrow_back_ios, size: 18),
        ),
      ),

      body: BlocBuilder<HomeCubit, HomeStates>(
        builder: (context, state) {
          final notifications = cubit.notifications;

          if (state is HomeNotificationsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await cubit.fetchOldNotifications();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];

                // تحويل التاريخ إلى DateTime
                final DateTime createdAt =
                    DateTime.tryParse(notif['created_at'] ?? '') ??
                    DateTime.now();

                // نص الوقت النسبي (مثلاً: منذ دقيقة)
                final timeAgoText = timeago.format(createdAt, locale: 'ar');

                // حالة القراءة (لو مش موجودة تعتبر false)
                final isRead = notif['isRead'] ?? false;

                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    color: isRead
                        ? Colors.white
                        : Colors.grey[200], // اللون حسب الحالة
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      leading: ClipOval(
                        child: Image.asset(
                          'assets/images/d.jfif',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        notif['title'] ?? 'تنبيه',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            notif['body'] ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            timeAgoText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // عند الضغط: نغير حالة الإشعار لمقروء
                        cubit.markNotificationAsRead(index);

                        // ممكن تفتحي تفاصيل الإشعار هنا لو عايزة
                        // Navigator.push(...);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
