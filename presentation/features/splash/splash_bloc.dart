import 'dart:async';
import 'package:bloc/bloc.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStart>(_onSplashStart);
  }

  Future<void> _onSplashStart(SplashStart event, Emitter<SplashState> emit) async {
    await Future.delayed(const Duration(seconds: 3));
    emit(SplashComplete());
  }
}