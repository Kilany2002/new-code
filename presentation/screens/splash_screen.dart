import 'package:e7gezly/core/widgets/custom_scaffold.dart';
import 'package:e7gezly/presentation/features/splash/splash_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc()..add(SplashStart()),
      child: CustomScaffold(
        body: BlocListener<SplashBloc, SplashState>(
          listener: (context, state) {
            if (state is SplashComplete) {
              Navigator.of(context).pushReplacementNamed('/authCheck');
            }
          },
          child: Center(
            child: Image.asset(
              'assets/images/Ehgezly logo.png',
              width: 150,
              height: 150,
            ),
          ),
        ),
      ),
    );
  }
}