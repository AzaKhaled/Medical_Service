import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_service_app/auth/domain/repos/auth_repo.dart';
import 'package:medical_service_app/auth/presentation/cubits/signup/signup_cubit.dart';
import 'package:medical_service_app/auth/presentation/views/widgets/signup_view_body_bloc_consumer.dart';
import 'package:medical_service_app/core/services/serv_locator.dart';


class SingUpView extends StatelessWidget {
  const SingUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupCubit(getIt<AuthRepo>()),
      child: const Scaffold(
       
        body: SignUpViewBodyBlocConsumer(),
      ),
    );
  }
}
