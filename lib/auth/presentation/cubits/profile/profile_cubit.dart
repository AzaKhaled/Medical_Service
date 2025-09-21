// import 'dart:io';
// import 'package:bloc/bloc.dart';
// import 'package:meta/meta.dart';
// import 'package:sweet_pal/core/services/storage_service.dart';
// import 'package:sweet_pal/core/services/supabase_auth_service.dart';

// part 'profile_state.dart';

// class ProfileCubit extends Cubit<ProfileState> {
//   final SupabaseAuthService authService;
//   final StorageService storageService;

//   ProfileCubit(this.authService, this.storageService) : super(ProfileInitial());

//   Future<String> uploadImage(File imageFile) async {
//     emit(ProfileLoading());
//     try {
//       print('Starting image upload process...');
//       final imageUrl = await storageService.uploadProfileImage(imageFile);
//       print('Image uploaded to storage. URL: $imageUrl');
      
//       print('Updating database with new avatar URL...');
//       await authService.updateProfileImage(imageUrl);
//       print('Database updated successfully');
      
//       emit(ProfileSuccess('updated successfully!'));
//       return imageUrl;
//     } catch (e) {
//       print('Error in uploadImage: $e');
//       emit(ProfileError(e.toString()));
//       rethrow;
//     }
//   }

//   Future<void> changePassword(String newPassword) async {
//     emit(ProfileLoading());
//     try {
//       await authService.changePassword(newPassword);
//       emit(ProfileSuccess('Password changed successfully!'));
//     } catch (e) {
//       // print(e.toString());
//       emit(ProfileError(e.toString()));
//     }
//   }
// }
