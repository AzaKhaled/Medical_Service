import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_service_app/core/utils/constants/my_bloc_observer.dart';
import 'package:medical_service_app/core/utils/constants/routes.dart';
import 'package:medical_service_app/core/utils/cubit/favorite_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 🔔 متغير الإشعارات المحلية
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

/// 🧠 دالة يتم استدعاؤها لما توصلك إشعارات والتطبيق في الخلفية أو مقفول
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return;

  final userResponse = await Supabase.instance.client
      .from('users')
      .select('id')
      .eq('auth_id', user.id)
      .maybeSingle();

  if (userResponse == null) return;
  final userIdFromTable = userResponse['id'];

  final title = message.notification?.title ?? 'تنبيه جديد';
  final body = message.notification?.body ?? '';

  await Supabase.instance.client.from('notifications').insert({
    'user_id': userIdFromTable,
    'title': title,
    'body': body,
  });

  debugPrint('📩 إشعار وصل في الخلفية: $title');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 1) تهيئة Firebase
  await Firebase.initializeApp();

  // ✅ 2) إعداد FCM
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 🔐 طلب الإذن من المستخدم (مهم لـ iOS)
  await messaging.requestPermission();

  // 🧠 استقبال رسائل في الخلفية
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🧠 استقبال رسائل أثناء فتح التطبيق (Foreground)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('📨 إشعار Foreground: ${message.notification?.title}');

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await HomeCubit().updateFcmToken();
    }
    if (user == null) return;

    // 🆔 هات الـ id من جدول users
    final userResponse = await Supabase.instance.client
        .from('users')
        .select('id')
        .eq('auth_id', user.id)
        .maybeSingle();

    if (userResponse == null) return;

    final userIdFromTable = userResponse['id'];
    final title = message.notification?.title ?? 'تنبيه جديد';
    final body = message.notification?.body ?? '';

    await Supabase.instance.client.from('notifications').insert({
      'user_id': userIdFromTable,
      'title': title,
      'body': body,
    });

    debugPrint('📩 إشعار Foreground: $title');
  });

  // ✅ 3) طباعة الـ Token علشان تبعتي إشعارات للموبايل ده
  final String? token = await messaging.getToken();
  debugPrint('🔑 FCM Token: $token');

  // ✅ 4) Supabase initialization
  await Supabase.initialize(
    url: 'https://brubbjtkjdzpbeekrdcx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJydWJianRramR6cGJlZWtyZGN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzNjk3MDQsImV4cCI6MjA3Mzk0NTcwNH0.KLgMHO0icafJXcJKftmZxOJPqDaS1B5tvLWaRivxPB4',
  );

  Bloc.observer = MyBlocObserver();

  runApp(const MedicalService());
}

class MedicalService extends StatelessWidget {
  const MedicalService({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeCubit()..initNotifications()),
        BlocProvider(
          create: (context) => FavoriteCubit()..getFavorites(),
        ), // 🟢 أضفها هنا
      ],
      child: BlocBuilder<HomeCubit, HomeStates>(
        builder: (context, state) {
          return ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                routes: Routes.routes,
                initialRoute: Routes.loginRoute,
                navigatorKey: navigatorKey,
              );
            },
          );
        },
      ),
    );
  }
}
