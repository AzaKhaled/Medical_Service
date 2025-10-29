import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medical_service_app/core/models/appointment_model.dart';
import 'package:medical_service_app/core/models/category_model.dart';
import 'package:medical_service_app/core/models/doctor_model.dart';
import 'package:medical_service_app/core/models/user_model.dart';
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

  List<CategoryModel> categories = [];
  List<DoctorModel> topDoctors = [];
  List<DoctorModel> allDoctors = [];
  List<DoctorModel> filteredDoctors = [];
  //form
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
      emit(HomeLoginErrorState("Login failed"));
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
        emit(HomeSignupErrorState("Email already registered"));
      } else {
        // debugPrint("❌ Error signing up (AuthException): ${e.message}");
        emit(HomeSignupErrorState("signup failed"));
      }
    } catch (e) {
      // debugPrint("❌ Unexpected error during signup: $e");
      emit(HomeSignupErrorState("Signup failed"));
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
  UserModel? currentUserData;

  Future<void> getCurrentUserData() async {
    emit(HomeGetUserLoadingState());

    try {
      final user = supabase.auth.currentUser;

      // 🔹 تحقق أولاً أن المستخدم مسجّل دخول
      if (user == null) {
        emit(HomeGetUserErrorState("No user logged in."));
        return;
      }

      // 🔹 جلب بيانات المستخدم من جدول users
      final response = await supabase
          .from('users')
          .select()
          .eq('auth_id', user.id)
          .maybeSingle(); // يرجع null إذا مفيش صف

      if (response == null) {
        emit(HomeGetUserErrorState("User data not found in database."));
        return;
      }

      // 🔹 تحويل البيانات إلى موديل
      currentUserData = UserModel.fromJson(response);

      debugPrint("✅ Current user data loaded: ${currentUserData!.name}");
      emit(HomeGetUserSuccessState());
    } catch (e, stackTrace) {
      debugPrint("❌ Error fetching user data: $e");
      debugPrintStack(stackTrace: stackTrace);
      emit(HomeGetUserErrorState(e.toString()));
    }
  }

  // ✅ Get Categories
  Future<void> getCategories() async {
    emit(HomeGetCategoriesLoadingState());
    try {
      final response = await supabase.from('specialties').select();
      categories = (response as List)
          .map((item) => CategoryModel.fromJson(item))
          .toList();

      emit(HomeGetCategoriesSuccessState(categories));
    } catch (e) {
      emit(HomeGetCategoriesErrorState(e.toString()));
    }
  }

  Future<void> getDoctors() async {
    emit(HomeGetDoctorsLoadingState());
    try {
      final response = await supabase.from('doctors').select();

      allDoctors = (response as List)
          .map((item) => DoctorModel.fromJson(item))
          .toList();
      filteredDoctors = List.from(allDoctors);

      emit(HomeGetDoctorsSuccessState());
    } catch (e) {
      emit(HomeGetDoctorsErrorState(e.toString()));
    }
  }

  /// 🧠 دالة البحث
  void searchDoctors(String query) {
    if (query.isEmpty) {
      filteredDoctors = List.from(allDoctors);
    } else {
      filteredDoctors = allDoctors
          .where(
            (doctor) =>
                doctor.name!.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    emit(HomeGetDoctorsSuccessState());
  }

  Future<void> getDoctorsByCategory(String categoryId) async {
    emit(HomeGetDoctorsLoadingState());
    try {
      final response = await supabase
          .from('doctors')
          .select()
          .eq('specialty_id', categoryId);

      filteredDoctors = (response as List)
          .map((e) => DoctorModel.fromJson(e))
          .toList();

      emit(HomeGetDoctorsSuccessState());
    } catch (e) {
      emit(HomeGetDoctorsErrorState(e.toString()));
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

      final doctors = (response as List)
          .map((e) => DoctorModel.fromJson(e))
          .toList();

      // ناخد أعلى دكتور من كل تخصص
      final Map<String, DoctorModel> topMap = {};
      for (var doc in doctors) {
        if (!topMap.containsKey(doc.specialtyName)) {
          topMap[doc.specialtyName!] = doc;
        }
      }

      topDoctors = topMap.values.toList();
      emit(HomeGetTopRatedDoctorsSuccessState(topDoctors));
    } catch (e) {
      emit(HomeGetDoctorsErrorState(e.toString()));
    }
  }

  // ✅ Get Doctor By Id
  Future<DoctorModel?> getDoctorById(String doctorId) async {
    try {
      final response = await supabase
          .from('doctors')
          .select()
          .eq('id', doctorId)
          .maybeSingle();

      if (response == null) return null;
      return DoctorModel.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error getting doctor: $e");
      return null;
    }
  }

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
      getDoctorById(doctorId);
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

  String? lastCreatedAppointmentId;

  Future<String> bookAppointment({
    required String doctorId,
    required DateTime appointmentDate,
    required String appointmentTime,
  }) async {
    final supabase = Supabase.instance.client;

    try {
      final user = supabase.auth.currentUser!;
      final userId = user.id;
      debugPrint("🔑 Booking for userId: $userId");

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
        throw Exception(" You have already booked this appointment.   ");
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
        throw Exception("You have already booked this appointment.");
      }

      // 🟢 إضافة الموعد
      final response = await supabase
          .from('appointments')
          .insert({
            'doctor_id': doctorId,
            'user_id': userId,
            'appointment_date': dateStr,
            'appointment_time': appointmentTime,
            'status': 'pending',
          })
          .select('id') // ✅ هنا هنرجع الـ ID بس
          .single();
      // 🧮 تحديث عدد المرضى في جدول doctors

      final appointmentId = response['id'] as String;
      lastCreatedAppointmentId = appointmentId;

      debugPrint("✅ تم حجز الموعد بنجاح: ID = $appointmentId");

      return appointmentId;
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception("This appointment is already booked for another user.");
      } else {
        rethrow;
      }
    } catch (e) {
      debugPrint("❌ خطأ في الحجز: $e");
      rethrow;
    }
  }

  Future<List<AppointmentModel>> getAppointmentsByDoctorId(
    String doctorId,
  ) async {
    emit(HomeGetAppointmentsLoadingState());
    try {
      final response = await supabase
          .from('appointments')
          .select()
          .eq('doctor_id', doctorId);

      final List data = response as List;
      final appointments = data
          .map((e) => AppointmentModel.fromJson(e as Map<String, Object?>))
          .toList();

      emit(HomeGetAppointmentsSuccessState(appointments));
      return appointments;
    } catch (e) {
      emit(HomeGetAppointmentsErrorState('Failed to fetch appointments'));
      debugPrint("❌ Error fetching appointments: $e");
      return [];
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
    subscribeToNotifications();
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

  void subscribeToNotifications() async {
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

  // Future<String> generatePayMobPaymentKey({
  //   required int amount,
  //   required String doctorId,
  //   required DateTime appointmentDate,
  //   required String appointmentTime,
  // }) async {
  //   try {
  //     const String apiKey =
  //         "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRBMk9EVTNNQ3dpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS43d3k2UW5xUXRZT3p4b1JiZWhPVVdldkNPNHI4N21ELUhUNjNuNTRCczhmT1NXMjFMVDFVeFgyTkdYVG94eW9FWnZBTGJ0blJkaGVEeFVlMHZhQW51dw==";
  //     const int integrationId = 5370772; // Integration ID الجديد

  //     // 1️⃣ احصلي على Auth Token
  //     final authResp = await http.post(
  //       Uri.parse("https://accept.paymob.com/api/auth/tokens"),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({"api_key": apiKey}),
  //     );
  //     final authData = jsonDecode(authResp.body);
  //     final authToken = authData["token"];
  //     if (authToken == null) {
  //       throw Exception("Auth token not received. Check your API key!");
  //     }

  //     // 2️⃣ جلب بيانات المستخدم من Supabase
  //     final user = supabase.auth.currentUser!;
  //     final userData = await supabase
  //         .from('users')
  //         .select()
  //         .eq('auth_id', user.id)
  //         .maybeSingle();

  //     final firstName = userData?['name']?.split(' ').first ?? "Customer";
  //     final lastName = userData?['name']?.split(' ').last ?? "";
  //     final email = userData?['email'] ?? user.email ?? "customer@example.com";
  //     final phone = userData?['phone'] ?? "+201234567890";
  //     final city = userData?['city'] ?? "Cairo";
  //     final country = userData?['country'] ?? "EG";

  //     // 3️⃣ إنشاء Order
  //     final orderResp = await http.post(
  //       Uri.parse("https://accept.paymob.com/api/ecommerce/orders"),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $authToken",
  //       },
  //       body: jsonEncode({
  //         "amount_cents": amount,
  //         "currency": "EGP",
  //         "items": [
  //           {"name": "Appointment Fee", "amount_cents": amount, "quantity": 1},
  //         ],
  //       }),
  //     );
  //     final orderData = jsonDecode(orderResp.body);
  //     final orderId = orderData["id"];
  //     if (orderId == null) {
  //       throw Exception("Order ID not received!");
  //     }

  //     // 4️⃣ توليد Payment Key باستخدام بيانات المستخدم الحقيقية
  //     final paymentKeyResp = await http.post(
  //       Uri.parse("https://accept.paymob.com/api/acceptance/payment_keys"),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({
  //         "amount_cents": amount,
  //         "currency": "EGP",
  //         "order_id": orderId,
  //         "billing_data": {
  //           "apartment": "NA",
  //           "email": email,
  //           "first_name": firstName,
  //           "last_name": lastName,
  //           "street": "NA",
  //           "city": city,
  //           "country": country,
  //           "phone_number": phone,
  //         },
  //         "integration_id": integrationId,
  //       }),
  //     );

  //     final paymentKeyData = jsonDecode(paymentKeyResp.body);
  //     final paymentToken = paymentKeyData["token"];
  //     if (paymentToken == null) {
  //       throw Exception(
  //         "Payment Key not received. Check integrationId and authToken!",
  //       );
  //     }

  //     debugPrint("✅ Payment Key generated successfully: $paymentToken");
  //     return paymentToken;
  //   } catch (e, stackTrace) {
  //     debugPrint("❌ Error generating PayMob Payment Key: $e");
  //     print(stackTrace);
  //     rethrow;
  //   }
  // }

  Future<void> signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut().then((value) {
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      currentIndex = 0;
    });
  }
}
