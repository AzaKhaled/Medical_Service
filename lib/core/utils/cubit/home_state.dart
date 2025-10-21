import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HomeStates {}

class HomeInitialState extends HomeStates {}

class HomeLoginLoadingState extends HomeStates {}

class HomeLoginSuccessState extends HomeStates {
  final User? user;

  HomeLoginSuccessState(this.user);
}

class HomeInitLoadingState extends HomeStates {}

class HomeInitSuccessState extends HomeStates {}

class HomeLoginErrorState extends HomeStates {
  final String message;

  HomeLoginErrorState(this.message);
}

class HomeSignupLoadingState extends HomeStates {}

class HomeSignupSuccessState extends HomeStates {
  final User? user;

  HomeSignupSuccessState(this.user);
}

class HomeSignupErrorState extends HomeStates {
  final String message;

  HomeSignupErrorState(this.message);
}

//bottomNav
class HomeBottomNavState extends HomeStates {}

// States related to user data
class HomeGetUserLoadingState extends HomeStates {}

class HomeGetUserSuccessState extends HomeStates {}

class HomeGetUserErrorState extends HomeStates {
  final String error;

  HomeGetUserErrorState(this.error);
}

// ============== Categories ==============
class HomeGetCategoriesLoadingState extends HomeStates {}

class HomeGetCategoriesSuccessState extends HomeStates {
  final List<dynamic> categories;

  HomeGetCategoriesSuccessState(this.categories);
}

class HomeGetCategoriesErrorState extends HomeStates {
  final String error;

  HomeGetCategoriesErrorState(this.error);
}

// ============== Doctors ==============
class HomeGetDoctorsLoadingState extends HomeStates {}

class HomeGetDoctorsSuccessState extends HomeStates {}

class HomeGetTopRatedDoctorsErrorState {}

class HomeGetTopRatedDoctorsLoadingState {}

class HomeGetDoctorsErrorState extends HomeStates {
  final String error;

  HomeGetDoctorsErrorState(this.error);
}

class HomeGetTopRatedDoctorsSuccessState extends HomeStates {
  final List<dynamic> doctors;

  HomeGetTopRatedDoctorsSuccessState(this.doctors);
}

class HomeAddFavoriteLoadingState extends HomeStates {}

class HomeAddFavoriteSuccessState extends HomeStates {
  final dynamic favorite;

  HomeAddFavoriteSuccessState(this.favorite);
}

class HomeAddFavoriteErrorState extends HomeStates {
  final String error;

  HomeAddFavoriteErrorState(this.error);
}

class HomeAddFavoriteAlreadyExistsState extends HomeStates {}

class HomeRemoveFavoriteLoadingState extends HomeStates {}

class HomeRemoveFavoriteSuccessState extends HomeStates {
  final String doctorId;

  HomeRemoveFavoriteSuccessState(this.doctorId);
}

class HomeRemoveFavoriteErrorState extends HomeStates {
  final String error;

  HomeRemoveFavoriteErrorState(this.error);
}

class HomeGetFavoritesLoadingState extends HomeStates {}

class HomeGetFavoritesSuccessState extends HomeStates {
  final List<dynamic> favorites;

  HomeGetFavoritesSuccessState(this.favorites);
}

class HomeGetFavoritesErrorState extends HomeStates {
  final String error;

  HomeGetFavoritesErrorState(this.error);
}
// ===================== Reviews =====================

// Add Review
class HomeAddReviewLoadingState extends HomeStates {}

class HomeAddReviewSuccessState extends HomeStates {
  final dynamic review; // أو ممكن List<Map<String, dynamic>> لو حابة
  HomeAddReviewSuccessState(this.review);
}

class HomeAddReviewErrorState extends HomeStates {
  final String error;

  HomeAddReviewErrorState(this.error);
}

// Get Reviews
class HomeGetReviewsLoadingState extends HomeStates {}

class HomeGetReviewsSuccessState extends HomeStates {
  final List<dynamic> reviews;

  HomeGetReviewsSuccessState(this.reviews);
}

class HomeGetReviewsErrorState extends HomeStates {
  final String error;

  HomeGetReviewsErrorState(this.error);
}

class HomeUploadProfileImageLoadingState extends HomeStates {}

class HomeUploadProfileImageSuccessState extends HomeStates {}

class HomeUploadProfileImageErrorState extends HomeStates {
  final String error;

  HomeUploadProfileImageErrorState(this.error);
}

class HomeNewNotificationState extends HomeStates {}
// core/utils/cubit/home_state.dart

// --- حالات عامة (ممكن تضيفي عليهم حقول لو محتاجة) ---
class HomeLoadingState extends HomeStates {}

class HomeErrorState extends HomeStates {
  final String error;

  HomeErrorState(this.error);
}

// --- حالات الاشعارات اللي إحنا محتاجينها ---
class HomeNotificationsLoadedState extends HomeStates {
  HomeNotificationsLoadedState(List<Map<String, dynamic>> notifications);
}

class HomeNotificationsLoadingState {}

class HomeNotificationsUpdatedState extends HomeStates {}
