import 'package:e7gezly/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e7gezly/core/widgets/custom_scaffold.dart';
import 'package:e7gezly/core/widgets/custom_app_bar.dart';
import 'package:e7gezly/core/widgets/custom_text_field.dart';
import 'package:e7gezly/core/widgets/custom_button.dart';
import 'package:e7gezly/presentation/features/login/login_bloc.dart';
import 'package:e7gezly/data/repositories/auth_repository_impl.dart';
import 'package:e7gezly/domain/usecases/login_usecase.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: tr('user_login'), 
          ),
          Expanded(
            child: BlocProvider(
              create: (context) => LoginBloc(
                loginUseCase: LoginUseCase(
                  authRepository: AuthRepositoryImpl(), // Inject the repository
                ),
              ),
              child: BlocConsumer<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state is LoginSuccess) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else if (state is LoginFailure) {
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
                          hintText: 'email',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'password',
                          prefixIcon: Icons.lock,
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'login',
                          onPressed: () {
                            context.read<LoginBloc>().add(
                                  LoginButtonPressed(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  ),
                                );
                          },
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot_password');
                          },
                          child: Text(
                            tr('forgot_password'), // Localized text
                            style: const TextStyle(
                                color: AppColors.whColor, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            tr('no_account_register_now'), // Localized text
                            style: const TextStyle(
                                color: AppColors.whColor, fontSize: 16),
                          ),
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
