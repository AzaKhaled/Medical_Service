import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_service_app/auth/domain/entites/user_entity.dart';
import 'package:medical_service_app/auth/domain/repos/auth_repo.dart';
import 'package:meta/meta.dart';

part 'signin_state.dart';

class SigninCubit extends Cubit<SigninState> {
  SigninCubit(this.authRepo) : super(SigninInitial());

  final AuthRepo authRepo;

  Future<void> signIn(String email, String password) async {
    print('🔐 SigninCubit: signIn called');
    print('📧 Email: $email');
    print('🔑 Password: $password');

    emit(SigninLoading());
    print('⏳ State: SigninLoading emitted');

    final result = await authRepo.signIn(email, password);
    print('📥 Response received from authRepo.signIn');

    result.fold(
      (failure) {
        print('❌ Sign in failed: ${failure.message}');
        emit(SigninFailure(message: failure.message));
      },
      (user) {
        print('✅ Sign in success: ${user.email}');
        emit(SigninSuccess(userEntity: user));
      },
    );
  }
}
