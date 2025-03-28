import 'package:flutter/material.dart';

class ButtonDecorations{
  static ButtonStyle primaryButtonStyle({required BuildContext context,double? borderRadius}) {
    return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary, // Uses theme color
      foregroundColor: Theme.of(context).colorScheme.onPrimary, // Text color
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius??12), // Rounded corners
      ),
      elevation: 4, // Shadow effect
    );
  }

  static ButtonStyle secondaryButtonStyle({double? borderRadius,double? elevation}) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black54,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius??12),
      ),
      side: const BorderSide(color: Colors.black54),
      elevation: elevation??0,
    );
  }
}