import 'package:back_office/config/app_config.dart';

class AuthGuard {
  static bool isAuthenticated() {
    return AppConfig.accessToken.isNotEmpty;
  }

  static bool isPlatformAdmin() {
    return AppConfig.userType == 'PLATFORM' &&
        (AppConfig.role == 'ADMIN' || AppConfig.role == 'SUPER_ADMIN');
  }

  static bool isSupportTeam() {
    return AppConfig.role == 'SUPPORT_TEAM';
  }

  static bool isOwner() {
    return AppConfig.role == 'OWNER';
  }

  static bool canManageBrand(String brandId) {
    if (isPlatformAdmin()) return true;
    if (isSupportTeam()) return true;
    if (isOwner() && AppConfig.brandId == brandId) return true;
    return false;
  }
}
