import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:medical_service_app/features/login/presentation/widget/password_reset.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

import 'package:medical_service_app/core/utils/constants/my_bloc_observer.dart';
import 'package:medical_service_app/core/utils/constants/routes.dart';
import 'package:medical_service_app/core/utils/cubit/favorite_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/home_state.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 🧠 دالة لمعالجة الإشعارات لما التطبيق في الخلفية أو مقفول
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

  await messaging.requestPermission(); // إذن الإشعارات
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🧠 استقبال إشعارات أثناء فتح التطبيق
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('📨 إشعار Foreground: ${message.notification?.title}');

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await HomeCubit().updateFcmToken();
    }
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

class MedicalService extends StatefulWidget {
  const MedicalService({super.key});

  @override
  State<MedicalService> createState() => _MedicalServiceState();
}

class _MedicalServiceState extends State<MedicalService> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // 🎯 لو التطبيق شغال وجاله لينك
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.host == 'reset-password') {
        Future.delayed(const Duration(milliseconds: 300), () {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => const ResetPasswordView()),
          );
        });
      }
    });

    // 🎯 لو التطبيق اتفتح من لينك وهو مقفول
    final initialUri = await _appLinks.getInitialLink();

    if (initialUri != null && initialUri.host == 'reset-password') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.microtask(() {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => const ResetPasswordView()),
          );
        });
      });
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeCubit()..initNotifications()),
        BlocProvider(create: (context) => FavoriteCubit()..getFavorites()),
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
