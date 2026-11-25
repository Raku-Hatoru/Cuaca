import 'package:flutter/material.dart';

/// Menampilkan SnackBar mengambang di atas tab bar notch agar tidak menutupi navigasi.
void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 108),
        duration: const Duration(seconds: 2),
      ),
    );
}
