import 'package:dartz/dartz.dart';
import 'package:medical_service_app/core/errors/failures.dart';
import '../entites/user_entity.dart';

abstract class AuthRepo {
  Future<Either<Failure, UserEntity>> signUp(String email, String password, String name);
  Future<Either<Failure, UserEntity>> signIn(String email, String password);
  Future<void> signOut();
}
