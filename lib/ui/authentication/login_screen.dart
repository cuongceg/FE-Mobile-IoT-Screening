import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text_iot_screen/core/component/loading_animation.dart';
import 'package:speech_to_text_iot_screen/core/decorations/button_decorations.dart';
import 'package:speech_to_text_iot_screen/core/decorations/custom_input_decorations.dart';
import 'package:speech_to_text_iot_screen/core/ultis/show_notify.dart';

import '../../core/decorations/fonts.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                textInputAction: TextInputAction.next,
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
                textInputAction: TextInputAction.done,
                decoration: CustomInputDecorations.inputDecoration(
                    hintText: 'Password',
                    context: context,
                    prefixIcon: Icon(Icons.lock_rounded,color: colorScheme.secondary),
                    suffixIcon: IconButton(
                        onPressed: (){
                          authProvider.togglePasswordVisibility();
                        },
                        icon: Icon(authProvider.isHidePassword?Icons.visibility:Icons.visibility_off,color: colorScheme.secondary,)
                    )
                ),
                obscureText: authProvider.isHidePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: (){
                      showForgotPasswordDialog(context);
                    },
                    child: Text('Forgot Password?',style: Fonts().body1.copyWith(color: colorScheme.primary,fontWeight: FontWeight.w500),)
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await authProvider.login(emailController.text, passwordController.text);
                    }
                    if(authProvider.state == 'error'){
                      ShowNotify.showSnackBar(context, authProvider.error!);
                    }
                  },
                  style: ButtonDecorations.primaryButtonStyle(context: context),
                  child: authProvider.state == 'loading'
                      ? LoadingAnimation().circleLoadingAnimation(context,color: Colors.white,size: 30)
                      : Text('Login',style: Fonts().title2.copyWith(color: Colors.white),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showForgotPasswordDialog(BuildContext context) async{
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<AuthProvider>(
          builder: (context,authProvider,child){
            return AlertDialog(
              title: Center(child: Text('Forgot Password',style: Fonts().title1)),
              content: TextField(
                controller: passwordController,
                decoration: CustomInputDecorations.inputDecoration(
                  hintText: 'Enter your username',
                  context: context,
                  prefixIcon: Icon(Icons.person,color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: ()async{
                      await authProvider.forgotPassword(passwordController.text);
                      if(authProvider.state == 'error'){
                        ShowNotify.showSnackBar(context, authProvider.error!);
                      }else if(authProvider.state == 'initial'){
                        Navigator.pop(context);
                        ShowNotify.showToastBar("Your reset link has been sent to your email");
                      }
                    },
                    style: ButtonDecorations.primaryButtonStyle(context: context),
                    child: authProvider.state == 'loading'
                        ? LoadingAnimation().circleLoadingAnimation(context,color: Colors.white,size: 30)
                        : Text('Send reset token',style: Fonts().body1.copyWith(color: Colors.white),),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
