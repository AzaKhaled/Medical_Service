import 'package:dartz/dartz.dart';
import 'package:medical_service_app/auth/domain/entites/user_entity.dart';
import 'package:medical_service_app/auth/domain/repos/auth_repo.dart';
import 'package:medical_service_app/core/errors/exceptions.dart';
import 'package:medical_service_app/core/errors/failures.dart';
import 'package:medical_service_app/core/services/supabase_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepoImpl extends AuthRepo {
  final SupabaseAuthService supabaseAuthService;

  AuthRepoImpl(this.supabaseAuthService);

  @override
  Future<Either<Failure, UserEntity>> signUp(
    String email,
    String password,
    String name,
  ) async {
    print(" AuthRepoImpl.signUp called with email=$email, name=$name");
    try {
      final user = await supabaseAuthService.signUp(email, password, name);
      print(" signUp success → userId=${user.id}, email=${user.email}");
      return right(UserEntity(id: user.id, email: user.email ?? ''));
    } on CustomException catch (e) {
      print(" signUp failed → ${e.message}");
      return left(Failure(message: e.message));
    } catch (e, st) {
      print(" Unexpected error in signUp: $e");
      print(st);
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signIn(
    String email,
    String password,
  ) async {
    print(" AuthRepoImpl.signIn called with email=$email");
    try {
      final user = await supabaseAuthService.signIn(email, password);
      print(" signIn success → userId=${user.id}, email=${user.email}");
      return right(UserEntity(id: user.id, email: user.email ?? ''));
    } on CustomException catch (e) {
      print(" signIn failed → ${e.message}");
      return left(Failure(message: e.message));
    } catch (e, st) {
      print(" Unexpected error in signIn: $e");
      print(st);
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    print(" AuthRepoImpl.signOut called");
    try {
      await Supabase.instance.client.auth.signOut();
      print("signOut success");
    } catch (e, st) {
      print("signOut failed: $e");
      print(st);
    }
  }
}
