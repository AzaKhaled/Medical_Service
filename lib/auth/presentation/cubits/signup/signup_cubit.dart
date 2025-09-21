import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_service_app/auth/domain/entites/user_entity.dart';
import 'package:medical_service_app/auth/domain/repos/auth_repo.dart';
import 'package:meta/meta.dart';


part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit(this.authRepo) : super(SignupInitial());

  final AuthRepo authRepo;

  Future<void> signUp(String email, String password, String name) async {
  print('🔐 SignupCubit: signup called');
  print('📧 Email: $email');
  print('🔑 Password: $password');

  emit(SignupLoading());
  print('📡 State: SignupLoading');

  final result = await authRepo.signUp(email, password, name); 
  result.fold(
    (failure) {
      print('❌ State: SignupFailure -> ${failure.message}');
      emit(SignupFailure(message: failure.message));
    },
    (user) {
      print('✅ State: SignupSuccess -> ${user.email}');
      emit(SignupSuccess(userEntity: user));
    },
  );
}
 
}

