import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text_iot_screen/core/decorations/button_decorations.dart';
import 'package:speech_to_text_iot_screen/core/decorations/custom_input_decorations.dart';
import 'package:speech_to_text_iot_screen/core/decorations/fonts.dart';
import 'package:speech_to_text_iot_screen/core/ultis/show_notify.dart';

import '../../core/component/loading_animation.dart';
import '../../providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final resetTokenController = TextEditingController();

  @override
  Widget build(BuildContext context){
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Enter your reset token from gmail and new password:',
                style: Fonts().body1,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: resetTokenController,
                textInputAction: TextInputAction.next,
                decoration: CustomInputDecorations.inputDecoration(
                  prefixIcon: Icon(Icons.lock_reset, color: Theme.of(context).colorScheme.secondary),
                  hintText: 'Reset Token',
                  context: context,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the reset token';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                textInputAction: TextInputAction.next,
                obscureText: authProvider.isHidePassword,
                decoration: CustomInputDecorations.inputDecoration(
                  prefixIcon: Icon(Icons.password, color: Theme.of(context).colorScheme.secondary),
                  hintText: 'New Password',
                  context: context,
                    suffixIcon: IconButton(
                        onPressed: (){
                          authProvider.togglePasswordVisibility();
                        },
                        icon: Icon(authProvider.isHidePassword?Icons.visibility:Icons.visibility_off,color: colorScheme.secondary,)
                    )
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                textInputAction: TextInputAction.done,
                obscureText: authProvider.isHidePassword,
                decoration: CustomInputDecorations.inputDecoration(
                  prefixIcon: Icon(Icons.password, color: Theme.of(context).colorScheme.secondary),
                  hintText: 'Confirm Password',
                  context: context,
                    suffixIcon: IconButton(
                        onPressed: (){
                          authProvider.togglePasswordVisibility();
                        },
                        icon: Icon(authProvider.isHidePassword?Icons.visibility:Icons.visibility_off,color: colorScheme.secondary,)
                    )
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // await authProvider.resetPassword(
                        //   newPassword: newPasswordController.text,
                        //   resetToken: resetTokenController.text,
                        // );
                        if(authProvider.state == 'error'){
                          ShowNotify.showSnackBar(context, authProvider.error!);
                        }else if(authProvider.state == 'initial'){
                          ShowNotify.showSnackBar(context, 'Password reset successfully');
                          Navigator.pushNamedAndRemoveUntil(context,
                            '/', (Route<dynamic> route) => false,
                          );
                        }
                      }
                    },
                    style: ButtonDecorations.primaryButtonStyle(context: context),
                    child: authProvider.state == 'loading'
                        ? LoadingAnimation().circleLoadingAnimation(context,color: Colors.white,size: 30)
                        : Text('Send reset token',style: Fonts().body1.copyWith(color: Colors.white),),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

