import '../../imports/imports.dart';
import '../auth/login/cubit_session.dart';

void showLogoutConfirmation(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('common.logout'.tr()),
      content: Text('common.are_you_sure_you_want_to_logou'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('common.cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            onConfirm();
          },
          child: Text('common.logout'.tr()),
        ),
      ],
    ),
  );
}

String? _getActiveBrandId(String currentLocation, AppUser? user) {
  try {
    final uri = Uri.tryParse(currentLocation);
    if (uri != null) {
      final segments = uri.pathSegments;
      final brandsIndex = segments.indexOf('brands');
      if (brandsIndex != -1 && brandsIndex + 1 < segments.length) {
        final candidate = segments[brandsIndex + 1];
        if (candidate.isNotEmpty && candidate != 'create') {
          return candidate;
        }
      }
    }
  } catch (_) {}

  if (user?.brandId != null && user!.brandId.isNotEmpty) {
    return user.brandId;
  }
  return null;
}

/// Main application shell with responsive sidebar navigation.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.currentLocation,
    this.user,
  });

  final Widget child;
  final String currentLocation;
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1024;
        final isTablet = constraints.maxWidth > 768 && constraints.maxWidth <= 1024;

        if (isDesktop) {
          return _DesktopShell(
            currentLocation: currentLocation,
            user: user,
            child: child,
          );
        }

        if (isTablet) {
          return _TabletShell(
            currentLocation: currentLocation,
            user: user,
            child: child,
          );
        }

        return _MobileShell(
          currentLocation: currentLocation,
          user: user,
          child: child,
        );
      },
    );
  }
}

// ============================================================
// Desktop Layout
// ============================================================

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.child,
    required this.currentLocation,
    this.user,
  });

  final Widget child;
  final String currentLocation;
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          _DesktopSidebar(
            currentLocation: currentLocation,
            user: user,
          ),
          Container(width: 1, color: cs.outlineVariant),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TopBar(user: user),
                Container(height: 1, color: cs.outlineVariant),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({required this.currentLocation, this.user});

  final String currentLocation;
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brandId = _getActiveBrandId(currentLocation, user);

    final usersRoute = brandId != null ? '/brands/$brandId/users' : AppRoutes.brandList;
    final tablesRoute = brandId != null ? '/brands/$brandId/tables' : AppRoutes.brandList;
    final roomTypesRoute = brandId != null ? '/brands/$brandId/room-types' : AppRoutes.brandList;
    final menuRoute = brandId != null ? '/brands/$brandId/menu' : AppRoutes.brandList;
    final posDevicesRoute = brandId != null ? '/brands/$brandId/pos-devices' : AppRoutes.brandList;
    final billsRoute = brandId != null ? '/brands/$brandId/bills' : AppRoutes.brandList;


    return Container(
      width: 260,
      color: cs.surfaceContainerLow,
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: AppBorders.md,
                  ),
                  child: Icon(Icons.restaurant, color: cs.onPrimaryContainer, size: 24),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('common.backoffice'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?.role ?? 'Admin',
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              children: [
                const _NavSection(title: 'MAIN'),
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'common.dashboard'.tr(),
                  route: AppRoutes.home,
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.store_outlined,
                  activeIcon: Icons.store,
                  label: 'common.brands'.tr(),
                  route: AppRoutes.brandList,
                  currentLocation: currentLocation,
                ),
                _InventoryNavGroup(
                  currentLocation: currentLocation,
                  user: user,
                ),
                _NavItem(
                  icon: Icons.people_outlined,
                  activeIcon: Icons.people,
                  label: 'common.users'.tr(),
                  route: usersRoute,
                  currentLocation: currentLocation,
                ),

                SizedBox(height: AppSpacing.lg),
                const _NavSection(title: 'MANAGEMENT'),
                _NavItem(
                  icon: Icons.table_restaurant_outlined,
                  activeIcon: Icons.table_restaurant,
                  label: 'common.tables'.tr(),
                  route: tablesRoute,
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: 'common.bills'.tr(),
                  route: billsRoute,
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.hotel_outlined,
                  activeIcon: Icons.hotel,
                  label: 'common.room_types'.tr(),
                  route: roomTypesRoute,
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.devices_outlined,
                  activeIcon: Icons.devices,
                  label: 'common.pos_devices'.tr(),
                  route: posDevicesRoute,
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book,
                  label: 'common.menu'.tr(),
                  route: menuRoute,
                  currentLocation: currentLocation,
                ),
                _FeedbackNavGroup(
                  currentLocation: currentLocation,
                ),

                SizedBox(height: AppSpacing.lg),
                const _NavSection(title: 'SYSTEM'),
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'common.settings'.tr(),
                  route: AppRoutes.settings,
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                  label: 'common.notifications'.tr(),
                  route: '/notifications',
                  currentLocation: currentLocation,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Footer
          Builder(
            builder: (ctx) => _NavItem(
              icon: Icons.logout_outlined,
              activeIcon: Icons.logout,
              label: 'common.logout'.tr(),
              route: AppRoutes.login,
              currentLocation: currentLocation,
              isFooter: true,
              onLogout: () => showLogoutConfirmation(context, () {
                    ctx.read<CubitSession>().logout();
                    context.go(AppRoutes.login);
                  }),
            ),
          ),
          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ============================================================
// Tablet Layout
// ============================================================

class _TabletShell extends StatelessWidget {
  const _TabletShell({
    required this.child,
    required this.currentLocation,
    this.user,
  });

  final Widget child;
  final String currentLocation;
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          _TabletSidebar(currentLocation: currentLocation, user: user),
          Container(width: 1, color: cs.outlineVariant),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TopBar(user: user),
                Container(height: 1, color: cs.outlineVariant),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabletSidebar extends StatelessWidget {
  const _TabletSidebar({required this.currentLocation, this.user});

  final String currentLocation;
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brandId = _getActiveBrandId(currentLocation, user);

    final usersRoute = brandId != null ? '/brands/$brandId/users' : AppRoutes.brandList;
    final tablesRoute = brandId != null ? '/brands/$brandId/tables' : AppRoutes.brandList;
    final roomTypesRoute = brandId != null ? '/brands/$brandId/room-types' : AppRoutes.brandList;
    final menuRoute = brandId != null ? '/brands/$brandId/menu' : AppRoutes.brandList;
    final posDevicesRoute = brandId != null ? '/brands/$brandId/pos-devices' : AppRoutes.brandList;
    final billsRoute = brandId != null ? '/brands/$brandId/bills' : AppRoutes.brandList;
    final inventoryRoute = brandId != null ? '/brands/$brandId/inventory' : AppRoutes.brandList;

    return Container(
      width: 72,
      color: cs.surfaceContainerLow,
      child: Column(
        children: [
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: AppBorders.sm,
            ),
            child: Icon(Icons.restaurant, color: cs.onPrimaryContainer, size: 24),
          ),
          SizedBox(height: AppSpacing.lg),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _TabletNavItem(
                    icon: Icons.dashboard,
                    label: 'common.home'.tr(),
                    route: AppRoutes.home,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.store,
                    label: 'common.brands'.tr(),
                    route: AppRoutes.brandList,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.inventory_2,
                    label: 'common.inventory'.tr(),
                    route: inventoryRoute,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.people,
                    label: 'common.users'.tr(),
                    route: usersRoute,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.table_restaurant,
                    label: 'common.tables'.tr(),
                    route: tablesRoute,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.hotel,
                    label: 'common.room_types'.tr(),
                    route: roomTypesRoute,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.devices,
                    label: 'common.pos_devices'.tr(),
                    route: posDevicesRoute,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.menu_book,
                    label: 'common.menu'.tr(),
                    route: menuRoute,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.description,
                    label: 'Feedback Configuration',
                    route: AppRoutes.feedbackList,
                    currentLocation: currentLocation,
                  ),

                  _TabletNavItem(
                    icon: Icons.rate_review,
                    label: 'Customer Responses',
                    route: AppRoutes.customerResponses,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.receipt_long,
                    label: 'common.bills'.tr(),
                    route: billsRoute,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.settings,
                    label: 'common.settings'.tr(),
                    route: AppRoutes.settings,
                    currentLocation: currentLocation,
                  ),
                ],
              ),
            ),
          ),
          _TabletNavItem(
            icon: Icons.logout,
            label: 'common.logout'.tr(),
            route: AppRoutes.login,
            currentLocation: currentLocation,
          ),
          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _TabletNavItem extends StatelessWidget {
  const _TabletNavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentLocation,
  });

  final IconData icon;
  final String label;
  final String route;
  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isSelected;
    if (route == AppRoutes.brandList) {
      isSelected = currentLocation == AppRoutes.brandList ||
          currentLocation.startsWith('${AppRoutes.brandList}/create') ||
          (currentLocation.startsWith('/brands/') &&
              !currentLocation.contains('/users') &&
              !currentLocation.contains('/tables') &&
              !currentLocation.contains('/room-types') &&
              !currentLocation.contains('/pos-devices') &&
              !currentLocation.contains('/menu') &&
              !currentLocation.contains('/branches') &&
              !currentLocation.contains('/inventory'));
    } else {
      isSelected = currentLocation.startsWith(route);
    }

    return Tooltip(
      message: label,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: AppSpacing.sm),
        child: Material(
          color: isSelected ? cs.primaryContainer : Colors.transparent,
          borderRadius: AppBorders.md,
          child: InkWell(
            onTap: () => context.go(route),
            borderRadius: AppBorders.md,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Mobile Layout
// ============================================================

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.child,
    required this.currentLocation,
    this.user,
  });

  final Widget child;
  final String currentLocation;
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(currentLocation)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
      drawer: _MobileDrawer(currentLocation: currentLocation, user: user),
      body: child,
    );
  }

  String _getPageTitle(String location) {
    if (location.contains('/inventory')) return 'Inventory';
    if (location.startsWith('/brands')) return 'Brands';
    if (location.startsWith('/tables')) return 'Tables';
    if (location.startsWith('/menu')) return 'Menu';
    if (location == '/settings') return 'Settings';
    if (location == '/profile') return 'Profile';
    if (location == '/home') return 'Home';
    if (location == '/users') return 'Users';
    if (location == '/pos-devices' || location == '/all-pos-devices') return 'POS Devices';
    if (location.contains('/bills')) return 'Bills';
    if (location.startsWith('/feedback')) return 'Feedback';
    if (location == '/notifications') return 'Notifications';
    return 'Dashboard';
  }
}

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer({required this.currentLocation, this.user});

  final String currentLocation;
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brandId = _getActiveBrandId(currentLocation, user);

    final usersRoute = brandId != null ? '/brands/$brandId/users' : AppRoutes.brandList;
    final tablesRoute = brandId != null ? '/brands/$brandId/tables' : AppRoutes.brandList;
    final roomTypesRoute = brandId != null ? '/brands/$brandId/room-types' : AppRoutes.brandList;
    final menuRoute = brandId != null ? '/brands/$brandId/menu' : AppRoutes.brandList;
    final posDevicesRoute = brandId != null ? '/brands/$brandId/pos-devices' : AppRoutes.brandList;
    final billsRoute = brandId != null ? '/brands/$brandId/bills' : AppRoutes.brandList;
    final inventoryRoute = brandId != null ? '/brands/$brandId/inventory' : AppRoutes.brandList;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: cs.primaryContainer),
            accountName: Text(user?.name ?? 'User'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: cs.primary,
              child: Text(
                (user?.name ?? 'U')[0].toUpperCase(),
                style: TextStyle(color: cs.onPrimary, fontSize: 24),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: Text('common.dashboard'.tr()),
            selected: currentLocation == AppRoutes.home,
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.home);
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: Text('common.brands'.tr()),
            selected: currentLocation.startsWith('/brands') &&
                !currentLocation.contains('/users') &&
                !currentLocation.contains('/tables') &&
                !currentLocation.contains('/room-types') &&
                !currentLocation.contains('/pos-devices') &&
                !currentLocation.contains('/menu') &&
                !currentLocation.contains('/inventory'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.brandList);
            },
          ),
          if (brandId != null)
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: currentLocation.startsWith(inventoryRoute),
                leading: Icon(
                  currentLocation.startsWith(inventoryRoute)
                      ? Icons.inventory_2
                      : Icons.inventory_2_outlined,
                  color: currentLocation.startsWith(inventoryRoute)
                      ? cs.primary
                      : cs.onSurfaceVariant,
                ),
                title: Text(
                  'common.inventory'.tr(),
                  style: TextStyle(
                    color: currentLocation.startsWith(inventoryRoute)
                        ? cs.primary
                        : cs.onSurface,
                    fontWeight: currentLocation.startsWith(inventoryRoute)
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                childrenPadding: const EdgeInsets.only(left: 16),
                children: [
                  ListTile(
                    leading: const Icon(Icons.dashboard_outlined),
                    title: const Text('Dashboard'),
                    selected: currentLocation == inventoryRoute,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(inventoryRoute);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: const Text('Items'),
                    selected: currentLocation.startsWith('$inventoryRoute/items'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('$inventoryRoute/items');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.straighten_outlined),
                    title: const Text('Units'),
                    selected: currentLocation.startsWith('$inventoryRoute/units'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('$inventoryRoute/units');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.warehouse_outlined),
                    title: const Text('Warehouses'),
                    selected: currentLocation.startsWith('$inventoryRoute/warehouses'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('$inventoryRoute/warehouses');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people_outline),
                    title: const Text('Suppliers'),
                    selected: currentLocation.startsWith('$inventoryRoute/suppliers'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('$inventoryRoute/suppliers');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.compare_arrows_outlined),
                    title: const Text('Transfers'),
                    selected: currentLocation.startsWith('$inventoryRoute/transfers'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('$inventoryRoute/transfers');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.analytics_outlined),
                    title: const Text('Reports'),
                    selected: currentLocation.startsWith('$inventoryRoute/reports'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('$inventoryRoute/reports');
                    },
                  ),
                ],
              ),
            )
          else
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text('common.inventory'.tr()),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.brandList);
              },
            ),
          ListTile(
            leading: const Icon(Icons.people),
            title: Text('common.users'.tr()),
            selected: currentLocation.startsWith(usersRoute) && brandId != null,
            onTap: () {
              Navigator.pop(context);
              context.go(usersRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_restaurant),
            title: Text('common.tables'.tr()),
            selected: currentLocation.startsWith(tablesRoute) && brandId != null,
            onTap: () {
              Navigator.pop(context);
              context.go(tablesRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.hotel),
            title: Text('common.room_types'.tr()),
            selected: currentLocation.startsWith(roomTypesRoute) && brandId != null,
            onTap: () {
              Navigator.pop(context);
              context.go(roomTypesRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.devices),
            title: Text('common.pos_devices'.tr()),
            selected: currentLocation.startsWith(posDevicesRoute) && brandId != null,
            onTap: () {
              Navigator.pop(context);
              context.go(posDevicesRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text('common.menu'.tr()),
            selected: currentLocation.startsWith(menuRoute) && brandId != null,
            onTap: () {
              Navigator.pop(context);
              context.go(menuRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Feedback Configuration'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.feedbackList);
            },
          ),

          ListTile(
            leading: const Icon(Icons.rate_review),
            title: const Text('Customer Responses'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.customerResponses);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text('common.bills'.tr()),
            selected: currentLocation.startsWith(billsRoute) && brandId != null,
            onTap: () {
              Navigator.pop(context);
              context.go(billsRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text('common.settings'.tr()),
            selected: currentLocation == AppRoutes.settings || currentLocation == AppRoutes.profile,
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.settings);
            },
          ),
          const Divider(),
          Builder(
            builder: (ctx) => ListTile(
              leading: const Icon(Icons.logout),
              title: Text('common.logout'.tr()),
              onTap: () {
                Navigator.pop(context);
                showLogoutConfirmation(context, () {
                  ctx.read<CubitSession>().logout();
                  context.go(AppRoutes.login);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Top Bar
// ============================================================

class _TopBar extends StatelessWidget {
  const _TopBar({this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      color: cs.surface,
      child: Row(
        children: [
          // Search
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'common.search'.tr(),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: const OutlineInputBorder(
                    borderRadius: AppBorders.md,
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                ),
              ),
            ),
          ),

          SizedBox(width: AppSpacing.lg),

          // Actions
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
            tooltip: 'Help',
          ),
          SizedBox(width: AppSpacing.sm),

          // User Avatar
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            shape: const RoundedRectangleBorder(borderRadius: AppBorders.md),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    (user?.name ?? 'U')[0].toUpperCase(),
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(user?.name ?? 'User', style: theme.textTheme.bodyMedium),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('common.profile'.tr()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('common.settings'.tr()),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('common.logout'.tr()),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.go(AppRoutes.profile);
                  break;
                case 'settings':
                  context.go(AppRoutes.settings);
                  break;
                case 'logout':
                  showLogoutConfirmation(context, () {
                    context.read<CubitSession>().logout();
                    context.go(AppRoutes.login);
                  });
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Navigation Helpers
// ============================================================

class _NavSection extends StatelessWidget {
  const _NavSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.currentLocation,
    this.isFooter = false,
    this.onLogout,
    this.exactMatch = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String currentLocation;
  final bool isFooter;
  final VoidCallback? onLogout;
  final bool exactMatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bool isSelected;
    if (route == AppRoutes.brandList) {
      isSelected = currentLocation == AppRoutes.brandList ||
          currentLocation.startsWith('${AppRoutes.brandList}/create') ||
          (currentLocation.startsWith('/brands/') &&
              !currentLocation.contains('/users') &&
              !currentLocation.contains('/tables') &&
              !currentLocation.contains('/room-types') &&
              !currentLocation.contains('/pos-devices') &&
              !currentLocation.contains('/menu') &&
              !currentLocation.contains('/branches') &&
              !currentLocation.contains('/inventory'));
    } else if (exactMatch) {
      isSelected = currentLocation == route;
    } else {
      isSelected = currentLocation.startsWith(route);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      child: Material(
        color: isSelected ? cs.primaryContainer : Colors.transparent,
        borderRadius: AppBorders.md,
        child: InkWell(
          onTap: isFooter && onLogout != null
              ? () {
                  onLogout!();
                  context.go(route);
                }
              : () => context.go(route),
          borderRadius: AppBorders.md,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 20,
                  color: isSelected ? cs.onPrimaryContainer : (isFooter ? cs.error : cs.onSurfaceVariant),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? cs.onPrimaryContainer : (isFooter ? cs.error : cs.onSurface),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _FeedbackNavGroup extends StatelessWidget {
  const _FeedbackNavGroup({
    required this.currentLocation,
  });

  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final expanded =
    currentLocation.startsWith('/feedback');

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        initiallyExpanded: expanded,
        leading: Icon(
          Icons.feedback_outlined,
          color: cs.onSurfaceVariant,
        ),
        title: const Text(
          'Feedback',
        ),
        childrenPadding: const EdgeInsets.only(left: 28),
        children: [
          _NavItem(
            icon: Icons.description_outlined,
            activeIcon: Icons.description,
            label: 'Feedback Configuration',
            route: AppRoutes.feedbackList,
            currentLocation: currentLocation,
          ),
          _NavItem(
            icon: Icons.rate_review_outlined,
            activeIcon: Icons.rate_review,
            label: 'Customer Responses',
            route: AppRoutes.customerResponses,
            currentLocation: currentLocation,
          ),
        ],
      ),
    );
  }
}

class _InventoryNavGroup extends StatelessWidget {
  const _InventoryNavGroup({
    required this.currentLocation,
    this.user,
  });

  final String currentLocation;
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brandId = _getActiveBrandId(currentLocation, user);

    if (brandId == null) {
      return _NavItem(
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2,
        label: 'common.inventory'.tr(),
        route: AppRoutes.brandList,
        currentLocation: currentLocation,
      );
    }

    final inventoryRoute = '/brands/$brandId/inventory';
    final expanded = currentLocation.startsWith(inventoryRoute);

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        initiallyExpanded: expanded,
        leading: Icon(
          expanded ? Icons.inventory_2 : Icons.inventory_2_outlined,
          color: expanded ? cs.primary : cs.onSurfaceVariant,
        ),
        title: Text(
          'common.inventory'.tr(),
          style: TextStyle(
            color: expanded ? cs.primary : cs.onSurface,
            fontWeight: expanded ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        childrenPadding: const EdgeInsets.only(left: 28),
        children: [
          _NavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
            route: inventoryRoute,
            currentLocation: currentLocation,
            exactMatch: true,
          ),
          _NavItem(
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2,
            label: 'Items',
            route: '$inventoryRoute/items',
            currentLocation: currentLocation,
          ),
          _NavItem(
            icon: Icons.straighten_outlined,
            activeIcon: Icons.straighten,
            label: 'Units',
            route: '$inventoryRoute/units',
            currentLocation: currentLocation,
          ),
          _NavItem(
            icon: Icons.warehouse_outlined,
            activeIcon: Icons.warehouse,
            label: 'Warehouses',
            route: '$inventoryRoute/warehouses',
            currentLocation: currentLocation,
          ),
          _NavItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Suppliers',
            route: '$inventoryRoute/suppliers',
            currentLocation: currentLocation,
          ),
          _NavItem(
            icon: Icons.compare_arrows_outlined,
            activeIcon: Icons.compare_arrows,
            label: 'Transfers',
            route: '$inventoryRoute/transfers',
            currentLocation: currentLocation,
          ),
          _NavItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics,
            label: 'Reports',
            route: '$inventoryRoute/reports',
            currentLocation: currentLocation,
          ),
        ],
      ),
    );
  }
}