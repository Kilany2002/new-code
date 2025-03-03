import 'package:e7gezly/core/constants/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e7gezly/core/widgets/custom_scaffold.dart';
import 'package:e7gezly/core/widgets/custom_app_bar.dart';
import 'package:e7gezly/core/widgets/custom_text_field.dart';
import 'package:e7gezly/core/widgets/custom_button.dart';
import 'package:e7gezly/presentation/features/register/register_bloc.dart';
import 'package:e7gezly/data/repositories/register_repository_impl.dart';
import 'package:e7gezly/domain/usecases/register_usecase.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  bool _policyAccepted = false;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: tr('user_registration'),
          ),
          Expanded(
            child: BlocProvider(
              create: (context) => RegisterBloc(
                registerUseCase: RegisterUseCase(
                  registerRepository: RegisterRepositoryImpl(),
                ),
              ),
              child: BlocConsumer<RegisterBloc, RegisterState>(
                listener: (context, state) {
                  if (state is RegisterSuccess) {
                    Navigator.pushReplacementNamed(context, '/login');
                  } else if (state is RegisterFailure) {
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
                          controller: _firstNameController,
                          hintText: 'first_name',
                          prefixIcon: Icons.person,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _lastNameController,
                          hintText: 'last_name',
                          prefixIcon: Icons.person,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _phoneNumberController,
                          hintText: 'phone_number',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
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
                        CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: 'confirm_password',
                          prefixIcon: Icons.lock,
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Checkbox(
                              value: _policyAccepted,
                              onChanged: (bool? value) {
                                setState(() {
                                  _policyAccepted = value ?? false;
                                });
                              },
                              activeColor: AppColors.prColor,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // Navigate to the privacy policy screen
                                  Navigator.pushNamed(
                                      context, '/privacy_policy');
                                },
                                child: Text(
                                  tr('i_accept_the_privacy_policy'),
                                  style: const TextStyle(
                                    color: AppColors.whColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'register',
                          onPressed: () {
                            if (!_policyAccepted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(tr('please_accept_policy'))),
                              );
                              return;
                            }

                            if (_passwordController.text !=
                                _confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(tr('password_mismatch'))),
                              );
                              return;
                            }

                            context.read<RegisterBloc>().add(
                                  RegisterButtonPressed(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                    firstName: _firstNameController.text.trim(),
                                    lastName: _lastNameController.text.trim(),
                                    phoneNumber:
                                        _phoneNumberController.text.trim(),
                                  ),
                                );
                          },
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text(
                            tr('already_have_account'),
                            style: const TextStyle(
                              color: AppColors.whColor,
                              fontSize: 16,
                            ),
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
