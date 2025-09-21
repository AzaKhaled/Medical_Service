import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_service_app/auth/domain/repos/auth_repo.dart';
import 'package:medical_service_app/auth/presentation/cubits/signin/signin_cubit.dart';
import 'package:medical_service_app/auth/presentation/views/widgets/signin_view_body_bloc_consumer.dart';
import 'package:medical_service_app/core/services/serv_locator.dart';


class SiginView extends StatelessWidget {
  const SiginView({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BlocProvider(
        create: (context) => SigninCubit(getIt<AuthRepo>()),
        child: const Scaffold(body: SignInViewBodyBlocConsumer()),
      ),
    );
  }
}
