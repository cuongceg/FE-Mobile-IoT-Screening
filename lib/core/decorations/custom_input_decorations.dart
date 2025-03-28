import 'package:flutter/material.dart';

import 'fonts.dart';

class CustomInputDecorations{
  static InputDecoration inputDecoration({required String hintText,required BuildContext context,double? borderRadius,Widget? prefixIcon,Widget? suffixIcon}){
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      counterText: '',
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      hintStyle: Fonts().title.copyWith(color: colorScheme.onSecondary,fontSize: 16),
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.secondary),
      ),
      enabledBorder:  OutlineInputBorder(
        borderSide:   BorderSide(color: colorScheme.secondary),
        borderRadius: BorderRadius.circular(borderRadius??12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide:  BorderSide(color: colorScheme.primary),
        borderRadius: BorderRadius.circular(borderRadius??12),
      ),
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
    );
  }
}
