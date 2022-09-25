// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/profile/profile_repository.dart';
import 'package:boorusama/core/application/api/api.dart';
import 'package:boorusama/core/utils.dart';

class LoginBox extends HookWidget {
  const LoginBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tickerProvider = useSingleTickerProvider();
    final animationController = useAnimationController(
        vsync: tickerProvider, duration: const Duration(milliseconds: 150));
    final formKey = useState(GlobalKey<FormState>());
    final isValidUsernameAndPassword = useState(true);

    final usernameTextController = useTextEditingController();
    final passwordTextController = useTextEditingController();
    final showPassword = useState(false);
    final usernameHasText = useState(false);

    usernameTextController.addListener(() {
      if (usernameTextController.text.isNotEmpty) {
        animationController.forward();
        usernameHasText.value = usernameTextController.text.isNotEmpty;
      } else {
        animationController.reverse();
      }
    });

    void onTextChanged() {
      isValidUsernameAndPassword.value = true;
    }

    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is Authenticated) {
          isValidUsernameAndPassword.value = true;
          Navigator.of(context).pop();
        } else if (state is AuthenticationError &&
            state.exception is InvalidUsernameOrPassword) {
          isValidUsernameAndPassword.value = false;
          formKey.value.currentState!.validate();
        } else if (state is AuthenticationError) {
          const snackbar = SnackBar(
            behavior: SnackBarBehavior.floating,
            elevation: 6,
            content: Text(
              'Something went wrong, please try again later',
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
      },
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              autovalidateMode: AutovalidateMode.disabled,
              key: formKey.value,
              child: Container(
                margin: const EdgeInsets.only(
                  top: 40,
                  left: 30,
                  right: 30,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoginField(
                      labelText: 'login.form.username'.tr(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'login.errors.missingUsername'.tr();
                        }

                        if (!isValidUsernameAndPassword.value) {
                          return 'login.errors.invalidUsernameOrPassword'.tr();
                        }
                        return null;
                      },
                      onChanged: (text) => onTextChanged(),
                      controller: usernameTextController,
                      suffixIcon: usernameHasText.value
                          ? ScaleTransition(
                              scale: CurvedAnimation(
                                parent: animationController,
                                curve: const Interval(0, 1),
                              ),
                              child: IconButton(
                                  splashColor: Colors.transparent,
                                  icon: const FaIcon(
                                      FontAwesomeIcons.solidCircleXmark),
                                  onPressed: usernameTextController.clear),
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),
                    LoginField(
                      labelText: 'login.form.password'.tr(),
                      obscureText: !showPassword.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'login.errors.missingPassword'.tr();
                        }
                        if (!isValidUsernameAndPassword.value) {
                          return 'login.errors.invalidUsernameOrPassword'.tr();
                        }
                        return null;
                      },
                      onChanged: (text) => onTextChanged(),
                      controller: passwordTextController,
                      suffixIcon: IconButton(
                          splashColor: Colors.transparent,
                          icon: showPassword.value
                              ? const FaIcon(FontAwesomeIcons.solidEyeSlash)
                              : const FaIcon(FontAwesomeIcons.solidEye),
                          onPressed: () =>
                              showPassword.value = !showPassword.value),
                    ),
                  ],
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('API key?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('login.form.cancel').tr(),
                        ),
                        BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
                          builder: (context, state) => TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              launchExternalUrl(Uri.parse(state.booru.url));
                            },
                            child:
                                const Text('login.form.open_web_browser').tr(),
                          ),
                        ),
                      ],
                      content:
                          const Text('login.form.api_key_instruction').tr(),
                    );
                  }),
              icon: const FaIcon(FontAwesomeIcons.solidCircleQuestion),
              label: const Text('API key?'),
            ),
            const SizedBox(height: 20),
            BlocBuilder<AuthenticationCubit, AuthenticationState>(
              builder: (context, state) => state is AuthenticationInProgress
                  ? const CircularProgressIndicator()
                  : _buildLoginButton(
                      context,
                      formKey,
                      usernameTextController,
                      passwordTextController,
                      isValidUsernameAndPassword,
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(
      BuildContext context,
      ValueNotifier<GlobalKey<FormState>> formKey,
      TextEditingController usernameTextController,
      TextEditingController passwordTextController,
      ValueNotifier<bool> isValidUsernameAndPassword) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(onPrimary: Colors.white),
      child: Text('login.form.login'.tr()),
      onPressed: () {
        if (formKey.value.currentState!.validate()) {
          ReadContext(context)
              .read<AuthenticationCubit>()
              .logIn(usernameTextController.text, passwordTextController.text);
          FocusScope.of(context).unfocus();
        } else {
          isValidUsernameAndPassword.value = true;
        }
      },
    );
  }
}

class LoginField extends StatelessWidget {
  const LoginField({
    Key? key,
    required this.validator,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
  }) : super(key: key);

  final TextEditingController controller;
  final String? Function(String?) validator;
  final Widget? suffixIcon;
  final String labelText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      obscureText: obscureText,
      validator: validator,
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(12),
        labelText: labelText,
      ),
    );
  }
}