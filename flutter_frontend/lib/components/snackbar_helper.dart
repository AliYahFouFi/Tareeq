import 'package:flutter/material.dart';

class CustomSnackBar {
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle,
      duration: duration,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error_outline,
      duration: duration,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: Colors.blue.shade600,
      icon: Icons.info_outline,
      duration: duration,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: Colors.orange.shade600,
      icon: Icons.warning_amber_outlined,
      duration: duration,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
