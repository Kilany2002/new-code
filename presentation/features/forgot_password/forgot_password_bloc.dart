import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e7gezly/domain/usecases/forgot_password_usecase.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordUseCase forgotPasswordUseCase;

  ForgotPasswordBloc({required this.forgotPasswordUseCase}) : super(ForgotPasswordInitial()) {
    on<ForgotPasswordButtonPressed>(_onForgotPasswordButtonPressed);
  }

  Future<void> _onForgotPasswordButtonPressed(
    ForgotPasswordButtonPressed event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    try {
      await forgotPasswordUseCase(event.email);
      emit(ForgotPasswordSuccess());
    } catch (e) {
      emit(ForgotPasswordFailure(error: e.toString()));
    }
  }
}