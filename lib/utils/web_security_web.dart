import 'package:flutter/foundation.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Web security utilities to discourage casual inspection.
///
/// Note: These cannot fully secure a web app since all client-side code
/// is inspectable. Always validate and secure sensitive operations server-side.
class WebSecurity {
  WebSecurity._();

  /// Enable security measures for web release builds.
  static void enableInspectProtection() {
    if (!kIsWeb) return;

    // Disable right-click context menu
    web.document.body?.addEventListener('contextmenu', ((web.Event event) {
      event.preventDefault();
    }).toJS);

    // Block common DevTools keyboard shortcuts
    web.window.addEventListener('keydown', ((web.Event event) {
      final keyEvent = event as web.KeyboardEvent;

      // F12
      if (keyEvent.keyCode == 123) {
        event.preventDefault();
      } else if (keyEvent.ctrlKey && keyEvent.shiftKey && keyEvent.key == 'I') {
        // Ctrl+Shift+I (DevTools)
        event.preventDefault();
      } else if (keyEvent.ctrlKey && keyEvent.shiftKey && keyEvent.key == 'J') {
        // Ctrl+Shift+J (Console)
        event.preventDefault();
      } else if (keyEvent.ctrlKey && keyEvent.key == 'u') {
        // Ctrl+U (View source)
        event.preventDefault();
      }
    }).toJS);
  }
}