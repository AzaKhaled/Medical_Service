import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_service_app/core/utils/constants/my_bloc_observer.dart';
import 'package:medical_service_app/core/utils/constants/routes.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 🧭 مفتاح الـ Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 🔔 متغير الإشعارات المحلية
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 1) تهيئة Supabase
  await Supabase.initialize(
    url: 'https://brubbjtkjdzpbeekrdcx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJydWJianRramR6cGJlZWtyZGN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzNjk3MDQsImV4cCI6MjA3Mzk0NTcwNH0.KLgMHO0icafJXcJKftmZxOJPqDaS1B5tvLWaRivxPB4',
  );

  // ✅ 2) تهيئة الإشعارات المحلية
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // 🧪 تجربة إشعار عند التشغيل
  await showLocalNotification('مرحبًا 👋', 'الإشعارات المحلية تعمل بنجاح ✅');

  // ✅ 3) Bloc Observer
  Bloc.observer = MyBlocObserver();

  // ✅ 4) الاستماع لتحديثات جدول notifications من Supabase Realtime
  Supabase.instance.client
      .channel('public:notifications')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'notifications',
        callback: (payload) {
          final newRecord = payload.newRecord;
          final title = newRecord['title'] ?? 'تنبيه جديد';
          final body = newRecord['body'] ?? '';
          showLocalNotification(title, body);
        },
      )
      .subscribe();

  runApp(const MyApp());
}

// 🛠️ دالة عرض الإشعار المحلي
Future<void> showLocalNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'notif_channel', // معرف القناة
    'Notifications', // اسم القناة
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    notificationDetails,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: BlocBuilder<HomeCubit, HomeStates>(
        builder: (context, state) {
          return ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                routes: Routes.routes,
                initialRoute: Routes.loginRoute,
              );
            },
          );
        },
      ),
    );
  }
}
