import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medical_service_app/core/utils/cubit/favorite_state.dart';
import 'package:medical_service_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

FavoriteCubit get favoriteCubit =>
    FavoriteCubit.get(navigatorKey.currentContext!);

class FavoriteCubit extends Cubit<FavotieStates> {
  FavoriteCubit() : super(FavotieInitialState());

  static FavoriteCubit get(BuildContext context) => BlocProvider.of(context);

  final supabase = Supabase.instance.client;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<dynamic> favorites = [];

  // ✅ Add Doctor to Favorites
  Future<void> addToFavorites(String doctorId) async {
    emit(HomeAddFavoriteLoadingState());
    try {
      final userId = supabase.auth.currentUser!.id;

      final existing = await supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('doctor_id', doctorId)
          .maybeSingle();

      if (existing != null) {
        emit(HomeAddFavoriteAlreadyExistsState());
        return;
      }

      await supabase.from('favorites').insert({
        'user_id': userId,
        'doctor_id': doctorId,
      });

      // ✅ استدعاء getFavorites هيرسل HomeGetFavoritesSuccessState
      await getFavorites();

      debugPrint("✅ Added to favorites: $doctorId");
    } catch (e) {
      emit(HomeAddFavoriteErrorState(e.toString()));
    }
  }

  // ✅ Remove Doctor from Favorites
  Future<void> removeFromFavorites(String doctorId) async {
    emit(HomeRemoveFavoriteLoadingState());
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('doctor_id', doctorId);

      // debugPrint("💔 Removed from favorites: $doctorId");

      // بعد الحذف أرجع هات الفيفورتس من جديد
      await getFavorites();
    } catch (e) {
      // debugPrint("❌ Error removing from favorites: $e");
      emit(HomeRemoveFavoriteErrorState(e.toString()));
    }
  }

  // ✅ Get All Favorites for Logged User
  Future<void> getFavorites() async {
    emit(HomeGetFavoritesLoadingState());
    try {
      final userId = supabase.auth.currentUser!.id;

      final response = await supabase
          .from('favorites')
          .select('doctor_id, doctors(*)')
          .eq('user_id', userId);

      debugPrint("📥 Favorites: $response");

      emit(HomeGetFavoritesSuccessState(response));
    } catch (e) {
      debugPrint("❌ Error getting favorites: $e");
      emit(HomeGetFavoritesErrorState(e.toString()));
    }
  }
}
