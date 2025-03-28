import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text_iot_screen/core/component/loading_animation.dart';
import 'package:speech_to_text_iot_screen/core/decorations/button_decorations.dart';
import 'package:speech_to_text_iot_screen/core/decorations/custom_input_decorations.dart';

import '../../core/decorations/fonts.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isHidePassword = true;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: TextFormField(
                controller: emailController,
                decoration: CustomInputDecorations.inputDecoration(
                  hintText: 'UserId',
                  prefixIcon: Icon(Icons.person_2_rounded,color: colorScheme.secondary),
                  context: context,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your userid';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: TextFormField(
                controller: passwordController,
                decoration: CustomInputDecorations.inputDecoration(
                    hintText: 'Password',
                    context: context,
                    prefixIcon: Icon(Icons.lock_rounded,color: colorScheme.secondary),
                    suffixIcon: IconButton(
                        onPressed: (){
                          setState((){
                            isHidePassword = !isHidePassword;
                          });
                        },
                        icon: Icon(isHidePassword?Icons.visibility:Icons.visibility_off,color: colorScheme.secondary,)
                    )
                ),
                obscureText: isHidePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      authProvider.login(emailController.text, passwordController.text);
                    }
                  },
                  style: ButtonDecorations.primaryButtonStyle(context: context),
                  child: authProvider.state == 'loading'
                      ? LoadingAnimation().circleLoadingAnimation(context,color: Colors.white,size: 30)
                      : Text('Login',style: Fonts().title.copyWith(fontWeight: FontWeight.w400),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
