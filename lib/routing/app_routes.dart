/// Centralized route path constants for GoRouter.
abstract final class AppRoutes {
  AppRoutes._();

  // Auth routes
  static const String splash = '/splash';
  static const String home = '/home';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  
  static const String forgotPassword = '/forgot-password';

  // Brand routes (Admin/Support)
  static const String brandList = '/brands';
  static const String brandDetail = '/brands/:brandId';
  static const String brandCreate = '/brands/create';
  static const String brandEdit = '/brands/:brandId/edit';

  // Branch routes
  static const String branchList = '/brands/:brandId/branches';
  static const String branchDetail = '/brands/:brandId/branches/:branchId';
  static const String branchCreate = '/brands/:brandId/branches/create';
  static const String branchEdit = '/brands/:brandId/branches/:branchId/edit';

  // User routes
  static const String userList = '/brands/:brandId/users';
  static const String userDetail = '/brands/:brandId/users/:userId';
  static const String userCreate = '/brands/:brandId/users/create';
  static const String userEdit = '/brands/:brandId/users/:userId/edit';

  // Menu routes
  static const String menuDashboard = '/brands/:brandId/menu';
  static const String menuCategories = '/brands/:brandId/menu/categories';
  static const String categoryCreate =
      '/brands/:brandId/menu/categories/create';
  static const String categoryEdit =
      '/brands/:brandId/menu/categories/:categoryId/edit';
  static const String menuItems = '/brands/:brandId/menu/items';
  static const String menuItemCreate = '/brands/:brandId/menu/items/create';
  static const String menuItemEdit = '/brands/:brandId/menu/items/:itemId/edit';

  // Table routes
  static const String tableLayout = '/brands/:brandId/tables';
  static const String tableCreate = '/brands/:brandId/tables/create';
  static const String tableEdit = '/brands/:brandId/tables/:tableId/edit';
  static const String roomTypes = '/brands/:brandId/room-types';

  // POS Device routes
  static const String posDevices = '/brands/:brandId/pos-devices';
  static const String deviceRegistration =
      '/brands/:brandId/pos-devices/register';

  // Branch Plan routes
  static const String branchPlanHistory =
      '/brands/:brandId/branches/:branchId/plan-history';
  static const String branchPlanForm =
      '/brands/:brandId/branches/:branchId/plan';

  // Settings
  static const String settings = '/settings';
  static const String profile = '/profile';
}
