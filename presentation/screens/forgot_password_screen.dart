import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e7gezly/core/widgets/custom_scaffold.dart';
import 'package:e7gezly/core/widgets/custom_app_bar.dart';
import 'package:e7gezly/core/widgets/custom_text_field.dart';
import 'package:e7gezly/core/widgets/custom_button.dart';
import 'package:e7gezly/presentation/features/forgot_password/forgot_password_bloc.dart';
import 'package:e7gezly/data/repositories/forgot_password_repository_impl.dart';
import 'package:e7gezly/domain/usecases/forgot_password_usecase.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: tr('forgot_password'), // Localized screen name
            showBackButton: true, // Show back button
          ),
          Expanded(
            child: BlocProvider(
              create: (context) => ForgotPasswordBloc(
                forgotPasswordUseCase: ForgotPasswordUseCase(
                  forgotPasswordRepository:
                      ForgotPasswordRepositoryImpl(), // Inject the repository
                ),
              ),
              child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
                listener: (context, state) {
                  if (state is ForgotPasswordSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Password reset email sent!')),
                    );
                    Navigator.pop(context); // Go back to the previous screen
                  } else if (state is ForgotPasswordFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error)),
                    );
                  }
                },
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'email',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'reset_password',
                          onPressed: () {
                            context.read<ForgotPasswordBloc>().add(
                                  ForgotPasswordButtonPressed(
                                    email: _emailController.text.trim(),
                                  ),
                                );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
