import 'package:get_it/get_it.dart';
import 'package:medical_service_app/auth/data/repos/auth_repos_implement.dart';
import 'package:medical_service_app/auth/domain/repos/auth_repo.dart';
import 'package:medical_service_app/core/services/supabase_auth_service.dart';


final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<SupabaseAuthService>(() => SupabaseAuthService());
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(getIt()));
}
