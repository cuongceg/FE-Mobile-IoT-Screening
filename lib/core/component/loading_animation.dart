import 'package:flutter/material.dart';

class LoadingAnimation{
  Widget circleLoadingAnimation(BuildContext context, {double? size,Color? color}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SizedBox(
        height: size??50,
        width: size??50,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color??colorScheme.primary),
        ),
      ),
    );
  }
}