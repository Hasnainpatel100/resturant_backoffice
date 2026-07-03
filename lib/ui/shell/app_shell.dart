import '../../imports/imports.dart';
import '../auth/login/cubit_session.dart';

void showLogoutConfirmation(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            onConfirm();
          },
          child: const Text('Logout'),
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
            child: child,
            currentLocation: currentLocation,
            user: user,
          );
        }

        if (isTablet) {
          return _TabletShell(
            child: child,
            currentLocation: currentLocation,
            user: user,
          );
        }

        return _MobileShell(
          child: child,
          currentLocation: currentLocation,
          user: user,
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
    final billsRoute = brandId != null ? '/brands/$brandId/bills' : AppRoutes.brandList;
    final branchesRoute = brandId != null ? '/brands/$brandId/branches' : AppRoutes.brandList;
    final branchCreateRoute = brandId != null ? '/brands/$brandId/branches/create' : AppRoutes.brandList;

    final String userInitials;
    if (user?.name != null && user!.name!.isNotEmpty) {
      final parts = user!.name!.trim().split(RegExp(r'\s+'));
      if (parts.length > 1) {
        userInitials = '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
      } else {
        userInitials = parts[0][0].toUpperCase();
      }
    } else {
      userInitials = 'RK';
    }
    final String displayName = user?.name ?? 'Rohan Kale';
    final String displayEmail = user?.email ?? 'owner@rhpos.app';

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
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'R',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RH POS',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        'BACKOFFICE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant.withOpacity(0.6),
                          fontSize: 9,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
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
                const _NavSection(title: 'OVERVIEW'),
                _NavItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view,
                  label: 'Dashboard',
                  route: AppRoutes.home,
                  currentLocation: currentLocation,
                ),

                SizedBox(height: AppSpacing.md),
                const _NavSection(title: 'NETWORK'),
                _NavItem(
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront,
                  label: 'Restaurants',
                  route: AppRoutes.brandList,
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.add_circle_outline,
                  activeIcon: Icons.add_circle,
                  label: 'Add restaurant',
                  route: AppRoutes.brandCreate,
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.device_hub_outlined,
                  activeIcon: Icons.device_hub,
                  label: 'Branches',
                  route: branchesRoute,
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.add_circle_outline,
                  activeIcon: Icons.add_circle,
                  label: 'Add branch',
                  route: branchCreateRoute,
                  currentLocation: currentLocation,
                ),

                SizedBox(height: AppSpacing.md),
                const _NavSection(title: 'OPERATIONS'),
                _NavItem(
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment,
                  label: 'Orders',
                  route: billsRoute,
                  currentLocation: currentLocation,
                  badge: '12',
                ),
                _NavItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Staff',
                  route: usersRoute,
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Settings',
                  route: AppRoutes.settings,
                  currentLocation: currentLocation,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Footer Profile Card
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Builder(
              builder: (ctx) => PopupMenuButton<String>(
                offset: const Offset(0, -120),
                shape: RoundedRectangleBorder(borderRadius: AppBorders.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: cs.primary,
                      child: Text(
                        userInitials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          Text(
                            displayEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 20),
                        SizedBox(width: AppSpacing.sm),
                        const Text('Profile'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        const Icon(Icons.settings_outlined, size: 20),
                        SizedBox(width: AppSpacing.sm),
                        const Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, size: 20, color: Colors.red),
                        SizedBox(width: AppSpacing.sm),
                        const Text('Logout', style: TextStyle(color: Colors.red)),
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
                        ctx.read<CubitSession>().logout();
                        context.go(AppRoutes.login);
                      });
                      break;
                  }
                },
              ),
            ),
          ),
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

    return Container(
      width: 72,
      color: cs.surfaceContainerLow,
      child: Column(
        children: [
          SizedBox(height: AppSpacing.md),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: AppBorders.sm,
            ),
            child: const Text(
              'R',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _TabletNavItem(
                    icon: Icons.dashboard,
                    label: 'Home',
                    route: AppRoutes.home,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.store,
                    label: 'Brands',
                    route: AppRoutes.brandList,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.people,
                    label: 'Users',
                    route: usersRoute,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.table_restaurant,
                    label: 'Tables',
                    route: tablesRoute,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.hotel,
                    label: 'Room Types',
                    route: roomTypesRoute,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.devices,
                    label: 'POS Devices',
                    route: posDevicesRoute,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.menu_book,
                    label: 'Menu',
                    route: menuRoute,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.receipt_long,
                    label: 'Bills',
                    route: billsRoute,
                    currentLocation: currentLocation,
                  ),
                  _TabletNavItem(
                    icon: Icons.settings,
                    label: 'Settings',
                    route: AppRoutes.settings,
                    currentLocation: currentLocation,
                  ),
                ],
              ),
            ),
          ),
          _TabletNavItem(
            icon: Icons.logout,
            label: 'Logout',
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
              !currentLocation.contains('/branches'));
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
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.account_circle_outlined),
            onPressed: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
      drawer: _MobileDrawer(currentLocation: currentLocation, user: user),
      body: child,
    );
  }

  String _getPageTitle(String location) {
    if (location.startsWith('/brands')) return 'Brands';
    if (location.startsWith('/tables')) return 'Tables';
    if (location.startsWith('/menu')) return 'Menu';
    if (location == '/settings') return 'Settings';
    if (location == '/profile') return 'Profile';
    if (location == '/home') return 'Home';
    if (location == '/users') return 'Users';
    if (location == '/inventory' || location.contains('/inventory')) return 'Inventory';
    if (location == '/pos-devices' || location == '/all-pos-devices') return 'POS Devices';
    if (location.contains('/bills')) return 'Bills';
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
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            selected: currentLocation == AppRoutes.home,
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.home);
            },
          ),
          ListTile(
            leading: Icon(Icons.store),
            title: Text('Brands'),
            selected: currentLocation.startsWith('/brands') &&
                !currentLocation.contains('/users') &&
                !currentLocation.contains('/tables') &&
                !currentLocation.contains('/room-types') &&
                !currentLocation.contains('/pos-devices') &&
                !currentLocation.contains('/menu'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.brandList);
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Users'),
            selected: currentLocation.startsWith(usersRoute) && brandId != null,
            onTap: () {
              Navigator.pop(context);
              context.go(usersRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.table_restaurant),
            title: Text('Tables'),
            selected: currentLocation.startsWith(tablesRoute) && brandId != null,
            onTap: () {
              Navigator.pop(context);
              context.go(tablesRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.hotel),
            title: Text('Room Types'),
            selected: currentLocation.startsWith(roomTypesRoute) && brandId != null,
            onTap: () {
              Navigator.pop(context);
              context.go(roomTypesRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.devices),
            title: Text('POS Devices'),
            selected: currentLocation.startsWith(posDevicesRoute) && brandId != null,
            onTap: () {
              Navigator.pop(context);
              context.go(posDevicesRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.menu_book),
            title: Text('Menu'),
            selected: currentLocation.startsWith(menuRoute) && brandId != null,
            onTap: () {
              Navigator.pop(context);
              context.go(menuRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Bills'),
            selected: currentLocation.startsWith(billsRoute) && brandId != null,
            onTap: () {
              Navigator.pop(context);
              context.go(billsRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            selected: currentLocation == AppRoutes.settings || currentLocation == AppRoutes.profile,
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.settings);
            },
          ),
          Divider(),
          Builder(
            builder: (ctx) => ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
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
              constraints: BoxConstraints(maxWidth: 400),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
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
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {},
            tooltip: 'Help',
          ),
          SizedBox(width: AppSpacing.sm),

          // User Avatar
          PopupMenuButton<String>(
            offset: Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: AppBorders.md),
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
                Icon(Icons.arrow_drop_down),
              ],
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('Settings'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('Logout'),
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
    this.badge,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String currentLocation;
  final String? badge;

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
              !currentLocation.contains('/branches'));
    } else {
      isSelected = currentLocation.startsWith(route);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      child: Material(
        color: isSelected ? cs.primaryContainer : Colors.transparent,
        borderRadius: AppBorders.md,
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: AppBorders.md,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 20,
                  color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}