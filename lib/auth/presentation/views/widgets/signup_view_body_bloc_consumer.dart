import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_service_app/auth/presentation/cubits/signup/signup_cubit.dart';
import 'package:medical_service_app/futures/home/presentation/views/home_view.dart';
import 'package:medical_service_app/auth/presentation/views/widgets/signup_view_body.dart';
import 'package:medical_service_app/core/helper_functions/build_error_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';


class SignUpViewBodyBlocConsumer extends StatelessWidget {
  const SignUpViewBodyBlocConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return BlocConsumer<SignupCubit, SignupState>(
          listener: (context, state) {
            if (state is SignupSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Center(child: Text('Signup Success')),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeView()),
              );
            }
            if (state is SignupFailure) {
              buildErrorBar(context, state.message);
            }
          },
          builder: (context, state) {
            return ModalProgressHUD(
              inAsyncCall: state is SignupLoading ? true : false,
              child: const SignupViewBody(),
            );
          },
        );
      },
    );
  }
}
