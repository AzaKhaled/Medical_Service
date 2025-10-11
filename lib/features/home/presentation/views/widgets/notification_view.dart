import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_state.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
      ),
      body: BlocBuilder<HomeCubit, HomeStates>(
        builder: (context, state) {
          final notifications = HomeCubit.get(context).notifications;

          if (notifications.isEmpty) {
            return const Center(child: Text('لا توجد إشعارات حالياً'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(notif['title'] ?? 'تنبيه'),
                subtitle: Text(notif['body'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
