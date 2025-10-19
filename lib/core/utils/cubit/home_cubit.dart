import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medical_service_app/core/utils/cubit/home_state.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/favorite_view.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/home_view_body.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/settting_view.dart';
import 'package:medical_service_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

HomeCubit get homeCubit => HomeCubit.get(navigatorKey.currentContext!);

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitialState());

  static HomeCubit get(BuildContext context) => BlocProvider.of(context);

  List<dynamic> categories = [];

  //form
  final signUpFormKey = GlobalKey<FormState>();
  final loginFormKey = GlobalKey<FormState>();
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final signUpNameController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();

  final supabase = Supabase.instance.client;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 🧭 قائمة الإشعارات (لو هتعرضها لاحقًا في صفحة Notifications)
  final List<Map<String, dynamic>> notifications = [];

  Future<void> login() async {
    emit(HomeLoginLoadingState());
    try {
      final response = await supabase.auth.signInWithPassword(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text.trim(),
      );
      if (response.user != null) {
        await updateFcmToken();
        loginEmailController.clear();
        loginPasswordController.clear();
        // debugPrint("Login successful: ${response.user}");
        emit(HomeLoginSuccessState(response.user!));
      } else {
        emit(HomeLoginErrorState("Login failed"));
      }
    } catch (e) {
      // debugPrint(" Error logging in: $e");
      emit(HomeLoginErrorState(e.toString()));
    }
  }

  Future<void> signup() async {
    emit(HomeSignupLoadingState());
    try {
      // debugPrint(
      //   "🚀 Starting signup with email: ${signUpEmailController.text.trim()}",
      // );

      final response = await supabase.auth.signUp(
        email: signUpEmailController.text.trim(),
        password: signUpPasswordController.text.trim(),
        data: {
          'name': signUpNameController.text
              .trim(), // 👈 الـ trigger هياخده من هنا
        },
      );

      // debugPrint("🔹 Signup response: $response");

      if (response.user != null) {
        // debugPrint("✅ Signup succeeded!");

        // ✅ شيل الـ saveUserToTable خالص - الـ trigger هيعملها

        signUpNameController.clear();
        signUpEmailController.clear();
        signUpPasswordController.clear();

        emit(HomeSignupSuccessState(response.user!));
      } else {
        // debugPrint("❌ Signup failed: response.user is null");
        emit(HomeSignupErrorState("Signup failed"));
      }
    } on AuthException catch (e) {
      // debugPrint("❌ Error signing up (AuthException): ${e.message}");

      if (e.message.contains('already registered') ||
          e.message.contains('already exists')) {
        emit(HomeSignupErrorState("هذا البريد مسجل بالفعل"));
      } else {
        emit(HomeSignupErrorState(e.message));
      }
    } catch (e) {
      // debugPrint("❌ Unexpected error during signup: $e");
      emit(HomeSignupErrorState(e.toString()));
    }
  }

  //bottomNav
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    emit(HomeBottomNavState());
  }

  final List<Widget> screens = [
    const HomeViewBody(),
    const FavoriteView(),
    const SettingsView(),
  ];

  // ================= Get Current User Data =================
  Map<String, dynamic>? currentUserData;

  Future<void> getCurrentUserData() async {
    emit(HomeGetUserLoadingState());

    try {
      final user = supabase.auth.currentUser!;
      final response = await supabase
          .from('users')
          .select()
          .eq('auth_id', user.id)
          .maybeSingle(); // مجرد صف واحد

      if (response != null) {
        currentUserData = response; // ✅ هنا نخزن البيانات
        // debugPrint("📥 Current user data: $response");
        emit(HomeGetUserSuccessState(response));
      } else {
        emit(HomeGetUserErrorState("User data not found"));
      }
    } catch (e) {
      // debugPrint("❌ Error fetching user data: $e");
      emit(HomeGetUserErrorState(e.toString()));
    }
  }

  // ✅ Get Categories
  Future<void> getCategories() async {
    emit(HomeGetCategoriesLoadingState());
    try {
      final response = await supabase.from('specialties').select();
      categories = response;
      // debugPrint("📥 specialties: $response");
      emit(HomeGetCategoriesSuccessState(response));
    } catch (e) {
      // debugPrint("❌ Error getting specialties: $e");
      emit(HomeGetCategoriesErrorState(e.toString()));
    }
  }

  // ✅ Get Doctors
  // Future<void> getDoctors() async {
  //   emit(HomeGetDoctorsLoadingState());
  //   try {
  //     final response = await supabase.from('doctors').select();
  //     // debugPrint("📥 Doctors: $response");
  //     emit(HomeGetDoctorsSuccessState(response));
  //   } catch (e) {
  //     // debugPrint("❌ Error getting doctors: $e");
  //     emit(HomeGetDoctorsErrorState(e.toString()));
  //   }
  // }
  List<dynamic> allDoctors = []; // الأصلية
  List<dynamic> filteredDoctors = []; // للعرض بعد البحث
  // List<dynamic> favorites = [];
  Future<void> getDoctors() async {
    emit(HomeGetDoctorsLoadingState());
    try {
      final response = await supabase.from('doctors').select();
      allDoctors = response;
      filteredDoctors = List.from(allDoctors); // مبدئيًا نفسهم
      emit(HomeGetDoctorsSuccessState(filteredDoctors));
    } catch (e) {
      emit(HomeGetDoctorsErrorState(e.toString()));
    }
  }

  /// 🧠 دالة البحث
  void searchDoctors(String query) {
    if (query.isEmpty) {
      filteredDoctors = List.from(allDoctors);
    } else {
      filteredDoctors = allDoctors.where((doctor) {
        final name = doctor['name'].toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    }
    debugPrint("🔍 Filtered doctors: $filteredDoctors");
    emit(HomeGetDoctorsSuccessState(filteredDoctors));
  }

  Future<void> getDoctorsByCategory(String categoryId) async {
    emit(HomeGetDoctorsLoadingState());
    try {
      final response = await Supabase.instance.client
          .from('doctors')
          .select()
          .eq('specialty_id', categoryId);

      emit(HomeGetDoctorsSuccessState(response));
    } catch (e) {
      emit(HomeGetDoctorsErrorState(e.toString())); // <<-- positional
    }
  }

  // ✅ Get Top Rated Doctors (واحد من كل تخصص)
  Future<void> getTopRatedDoctors() async {
    emit(HomeGetDoctorsLoadingState());
    try {
      final response = await supabase
          .from('doctors')
          .select()
          .order('rating', ascending: false);

      // نعمل Map علشان ناخد أول دكتور من كل تخصص (أعلى تقييم)
      final Map<String, dynamic> topDoctorsMap = {};
      for (var doc in response) {
        final specialty = doc['specialty_name'];
        if (!topDoctorsMap.containsKey(specialty)) {
          topDoctorsMap[specialty] = doc;
        }
      }

      final topDoctors = topDoctorsMap.values.toList();
      // debugPrint("📥 Top Rated Doctors: $topDoctors");

      emit(HomeGetTopRatedDoctorsSuccessState(topDoctors));
    } catch (e) {
      // debugPrint("❌ Error getting top rated doctors: $e");
      emit(HomeGetDoctorsErrorState(e.toString()));
    }
  }

  // ✅ Get Doctor By Id
  Future<Map<String, dynamic>?> getDoctorById(String doctorId) async {
    try {
      final response = await supabase
          .from('doctors')
          .select()
          .eq('id', doctorId)
          .maybeSingle();

      // debugPrint("📥 Doctor $doctorId details: $response");
      return response;
    } catch (e) {
      // debugPrint("❌ Error getting doctor by id: $e");
      return null;
    }
  }

  // ✅ Add Doctor to Favorites
  //   Future<void> addToFavorites(String doctorId) async {
  //     emit(HomeAddFavoriteLoadingState());
  //     try {
  //       final userId = supabase.auth.currentUser!.id;

  //       // 🛑 تأكد إن الدكتور مش مضاف من قبل
  //       final existing = await supabase
  //           .from('favorites')
  //           .select()
  //           .eq('user_id', userId)
  //           .eq('doctor_id', doctorId)
  //           .maybeSingle();

  //       if (existing != null) {
  //         emit(HomeAddFavoriteAlreadyExistsState());
  //         return;
  //       }

  //       // ✅ أضف الدكتور
  //       final response = await supabase.from('favorites').insert({
  //         'user_id': userId,
  //         'doctor_id': doctorId,
  //       }).select();

  //       // ✅ مباشرة بعد الإضافة، استدعِ getFavorites لتحديث القائمة
  //       await getFavorites();
  //       debugPrint("✅ Added to favorites: $response");
  //       favorites = response;
  //       emit(HomeAddFavoriteSuccessState(response));
  //     } catch (e) {
  //       emit(HomeAddFavoriteErrorState(e.toString()));
  //     }
  //   }

  //   // ✅ Remove Doctor from Favorites
  //   Future<void> removeFromFavorites(String doctorId) async {
  //     emit(HomeRemoveFavoriteLoadingState());
  //     try {
  //       final userId = supabase.auth.currentUser!.id;
  //       await supabase
  //           .from('favorites')
  //           .delete()
  //           .eq('user_id', userId)
  //           .eq('doctor_id', doctorId);

  //       // debugPrint("💔 Removed from favorites: $doctorId");

  //       // بعد الحذف أرجع هات الفيفورتس من جديد
  //       await getFavorites();
  //     } catch (e) {
  //       // debugPrint("❌ Error removing from favorites: $e");
  //       emit(HomeRemoveFavoriteErrorState(e.toString()));
  //     }
  //   }

  //   // ✅ Get All Favorites for Logged User
  //   Future<void> getFavorites() async {
  //   emit(HomeGetFavoritesLoadingState());
  //   try {
  //     final userId = supabase.auth.currentUser!.id;

  //     final response = await supabase
  //         .from('favorites')
  //         .select('doctor_id, doctors(*)')
  //         .eq('user_id', userId);

  //     debugPrint("📥 Favorites: $response");

  //     emit(HomeGetFavoritesSuccessState(response));
  //   } catch (e) {
  //     debugPrint("❌ Error getting favorites: $e");
  //     emit(HomeGetFavoritesErrorState(e.toString()));
  //   }
  // }

  // ✅ Add Review (تعليق جديد)
  Future<void> addReview({
    required String doctorId,
    required double rating,
    required String comment,
  }) async {
    emit(HomeAddReviewLoadingState());
    try {
      final user = supabase.auth.currentUser!;

      // ✅ هات اسم المستخدم من جدول users
      final userRecord = await supabase
          .from('users')
          .select('name')
          .eq('auth_id', user.id)
          .maybeSingle();

      final userName = userRecord?['name'] ?? 'Unknown';

      // ✅ تحقق إذا كان المستخدم كتب ريفيو قبل كده
      final existingReview = await supabase
          .from('reviews')
          .select('id')
          .eq('doctor_id', doctorId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingReview != null) {
        // ✏️ المستخدم كتب ريفيو قبل كده → نعمل update
        await supabase
            .from('reviews')
            .update({
              'rating': rating,
              'comment': comment,
              'created_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingReview['id']);
      } else {
        // 🆕 مفيش ريفيو قبل كده → نعمل insert
        await supabase.from('reviews').insert({
          'doctor_id': doctorId,
          'user_id': user.id,
          'user_name': userName,
          'rating': rating,
          'comment': comment,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // ✅ بعد الإضافة أو التعديل، نحسب المتوسط الجديد
      final reviews = await supabase
          .from('reviews')
          .select('rating')
          .eq('doctor_id', doctorId);

      double avgRating = 0;
      if (reviews.isNotEmpty) {
        final total = reviews.fold<double>(
          0,
          (sum, r) => sum + (r['rating'] as num).toDouble(),
        );
        avgRating = total / reviews.length;
      }

      await supabase
          .from('doctors')
          .update({'rating': avgRating})
          .eq('id', doctorId);

      // ✅ هات الريفيوهات تاني
      final newReviews = await supabase
          .from('reviews')
          .select('id, rating, comment, created_at, user_name, user_id')
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);

      emit(HomeGetReviewsSuccessState(newReviews));
    } catch (e) {
      // debugPrint("❌ Error adding/updating review: $e");
      emit(HomeAddReviewErrorState(e.toString()));
    }
  }

  // ✅ Get Reviews مع بيانات المستخدم من جدول users
  Future<void> getReviews(String doctorId) async {
    emit(HomeGetReviewsLoadingState());
    try {
      final newReviews = await supabase
          .from('reviews')
          .select('id, rating, comment, created_at, user_name, user_id')
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);

      if (newReviews.isNotEmpty) {
        final userIds = newReviews.map((r) => r['user_id'].toString()).toList();

        final usersData = await supabase
            .from('users')
            .select('auth_id, image_url')
            .inFilter('auth_id', userIds);
        debugPrint('🧪 usersData: $usersData');
        final Map<String, String?> userImages = {
          for (var u in usersData)
            u['auth_id'] as String: u['image_url'] as String?,
        };

        for (var r in newReviews) {
          r['user_image'] = userImages[r['user_id'].toString()] ?? '';
        }
      }

      emit(HomeGetReviewsSuccessState(newReviews));
      debugPrint("📥 Reviews for doctor $doctorId: $newReviews");

      emit(HomeGetReviewsSuccessState(newReviews));
    } catch (e) {
      emit(HomeGetReviewsErrorState(e.toString()));
      debugPrint("❌ Error getting reviews: $e");
    }
  }

  Future<int> getReviewsCount(String doctorId) async {
    try {
      final response = await supabase
          .from('reviews')
          .select('id') // هات الـ id بس لتقليل الداتا
          .eq('doctor_id', doctorId);

      final count = response.length; // 👈 نعدهم في الكلاينت
      // debugPrint("🧮 Reviews count for doctor $doctorId: $count");
      return count;
    } catch (e) {
      // debugPrint("❌ Error getting reviews count: $e");
      return 0;
    }
  }

  Future<void> bookAppointment({
    required String doctorId,
    required DateTime appointmentDate,
    required String appointmentTime,
  }) async {
    final supabase = Supabase.instance.client;

    try {
      final user = supabase.auth.currentUser!;
      final userId = user.id;
      // debugPrint("🔑 Booking for userId: $userId");

      final dateStr = appointmentDate.toIso8601String().split('T')[0];

      // تحقق إذا الموعد محجوز لنفس الدكتور
      final existing = await supabase
          .from('appointments')
          .select()
          .eq('doctor_id', doctorId)
          .eq('appointment_date', dateStr)
          .eq('appointment_time', appointmentTime)
          .maybeSingle();

      if (existing != null) {
        // debugPrint("❌ هذا الموعد محجوز بالفعل");
        throw Exception("هذا الموعد محجوز بالفعل");
      }

      // تحقق إذا المستخدم نفسه حجز نفس الموعد
      final userExisting = await supabase
          .from('appointments')
          .select()
          .eq('user_id', userId)
          .eq('appointment_date', dateStr)
          .eq('appointment_time', appointmentTime)
          .maybeSingle();

      if (userExisting != null) {
        // debugPrint("❌ أنت حجزت هذا الموعد بالفعل");
        throw Exception("You have already booked this appointment");
      }

      // إضافة الموعد
      try {
        // debugPrint("✅ تم حجز الموعد بنجاح: $response");
      } catch (e) {
        // لو الـ DB رمى duplicate key (23505)
        if (e is PostgrestException && e.code == '23505') {
          throw Exception(
            "This appointment is already booked for another user.",
          );
        } else {
          rethrow;
        }
      }
    } catch (e) {
      // debugPrint("❌ خطأ في الحجز: $e");
      rethrow;
    }
  }

  // ================= Upload Profile Image =================
  Future<void> uploadProfileImage(File imageFile) async {
    emit(HomeUploadProfileImageLoadingState());

    try {
      final user = supabase.auth.currentUser!;
      final fileName = '${user.id}.jpg';

      // رفع الصورة للستورج
      await supabase.storage
          .from('profile_images')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // جلب الرابط العام
      final publicUrl = supabase.storage
          .from('profile_images')
          .getPublicUrl(fileName);

      // تحديث جدول users
      await supabase
          .from('users')
          .update({'image_url': publicUrl})
          .eq('auth_id', user.id);

      emit(HomeUploadProfileImageSuccessState());
      debugPrint("✅ Profile image uploaded: $publicUrl");
    } catch (e) {
      debugPrint("❌ Error uploading profile image: $e");
      emit(HomeUploadProfileImageErrorState(e.toString()));
    }
  }

  Future<void> initNotifications() async {
    // ✅ تهيئة flutter_local_notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // ✅ جلب الإشعارات القديمة
    await fetchOldNotifications();

    // ✅ الاشتراك في التغييرات الجديدة
    _subscribeToNotifications();
  }

  Future<void> fetchOldNotifications() async {
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser == null) return;

    // 👇 الحصول على ID المستخدم من جدول users
    final userResponse = await Supabase.instance.client
        .from('users')
        .select('id')
        .eq('auth_id', authUser.id)
        .maybeSingle();

    if (userResponse == null) {
      // print('⚠️ لم يتم العثور على المستخدم في جدول users');
      return;
    }

    final userIdFromTable = userResponse['id'];
    // print('🆔 User ID from users table: $userIdFromTable');

    // 👇 جلب الإشعارات القديمة الخاصة بالمستخدم
    final notificationsResponse = await Supabase.instance.client
        .from('notifications')
        .select()
        .eq('user_id', userIdFromTable)
        .order('created_at', ascending: false);

    // print('📥 Old notifications for $userIdFromTable: $notificationsResponse');

    notifications
      ..clear()
      ..addAll(List<Map<String, dynamic>>.from(notificationsResponse));

    emit(HomeNotificationsLoadedState(notifications));
  }

  void _subscribeToNotifications() async {
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser == null) return;

    final userResponse = await Supabase.instance.client
        .from('users')
        .select('id')
        .eq('auth_id', authUser.id)
        .maybeSingle();

    if (userResponse == null) return;

    final userIdFromTable = userResponse['id'];

    Supabase.instance.client
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord['user_id'] != userIdFromTable) {
              return; // 👌 تجاهل الإشعارات اللي مش لليوزر ده
            }

            final title = newRecord['title'] ?? 'تنبيه جديد';
            final body = newRecord['body'] ?? '';

            showLocalNotification(title, body);

            notifications.insert(0, newRecord);
            emit(HomeNewNotificationState());
          },
        )
        .subscribe();
  }

  Future<void> showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'notif_channel',
          'Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // رقم مميز للإشعار
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> updateFcmToken() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await supabase
          .from('users')
          .update({'fcm_token': token})
          .eq('auth_id', user.id);

      // debugPrint('✅ FCM token updated: $token');
    } catch (e) {
      debugPrint('❌ Error updating FCM token: $e');
    }
  }

  void markNotificationAsRead(int index) {
    notifications[index]['isRead'] = true;
    emit(HomeNotificationsUpdatedState()); // اعملي State لتحديث الـ UI
  }
}
