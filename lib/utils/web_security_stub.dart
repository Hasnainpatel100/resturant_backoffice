import 'package:flutter/foundation.dart';

/// Web security utilities to discourage casual inspection.
///
/// Note: These cannot fully secure a web app since all client-side code
/// is inspectable. Always validate and secure sensitive operations server-side.
class WebSecurity {
  WebSecurity._();

  /// Enable security measures for web release builds.
  /// This is a no-op on non-web platforms.
  static void enableInspectProtection() {
    // Platform-specific implementation loaded via conditional import
  }
}