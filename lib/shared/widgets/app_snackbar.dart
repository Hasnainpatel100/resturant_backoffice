import 'package:flutter/material.dart';

/// A static snackbar utility compatible with BLoC / any state management.
/// Uses [ScaffoldMessenger] — no GetX or context-specific dependencies.
///
/// Usage anywhere in the app:
///   AppSnackbar.error(context, 'Room type already exists');
///   AppSnackbar.success(context, 'Room type created!');
///   AppSnackbar.info(context, 'Loading data...');
///   AppSnackbar.warning(context, 'This action cannot be undone.');
class AppSnackbar {
  AppSnackbar._(); // Prevent instantiation

  static const Duration _defaultDuration = Duration(seconds: 3);

  /// Shows a red error snackbar.
  static void error(
      BuildContext context,
      String message, {
        Duration duration = _defaultDuration,
        String? actionLabel,
        VoidCallback? onAction,
      }) {
    _show(
      context,
      message: message,
      backgroundColor: const Color(0xFFD32F2F),
      icon: Icons.error_outline_rounded,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Shows a green success snackbar.
  static void success(
      BuildContext context,
      String message, {
        Duration duration = _defaultDuration,
        String? actionLabel,
        VoidCallback? onAction,
      }) {
    _show(
      context,
      message: message,
      backgroundColor: const Color(0xFF2E7D32),
      icon: Icons.check_circle_outline_rounded,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Shows a blue info snackbar.
  static void info(
      BuildContext context,
      String message, {
        Duration duration = _defaultDuration,
        String? actionLabel,
        VoidCallback? onAction,
      }) {
    _show(
      context,
      message: message,
      backgroundColor: const Color(0xFF1565C0),
      icon: Icons.info_outline_rounded,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Shows an amber warning snackbar.
  static void warning(
      BuildContext context,
      String message, {
        Duration duration = _defaultDuration,
        String? actionLabel,
        VoidCallback? onAction,
      }) {
    _show(
      context,
      message: message,
      backgroundColor: const Color(0xFFF57F17),
      icon: Icons.warning_amber_rounded,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void _show(
      BuildContext context, {
        required String message,
        required Color backgroundColor,
        required IconData icon,
        required Duration duration,
        String? actionLabel,
        VoidCallback? onAction,
      }) {
    // Dismiss any existing snackbar before showing a new one.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: onAction,
        )
            : null,
      ),
    );
  }
}
