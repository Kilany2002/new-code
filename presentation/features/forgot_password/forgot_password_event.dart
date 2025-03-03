part of 'forgot_password_bloc.dart';

abstract class ForgotPasswordEvent {}

class ForgotPasswordButtonPressed extends ForgotPasswordEvent {
  final String email;

  ForgotPasswordButtonPressed({required this.email});
}