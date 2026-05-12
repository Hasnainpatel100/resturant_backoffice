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
                      Text(
                        'BackOffice',
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
                _NavSection(title: 'MAIN'),
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  route: AppRoutes.home,
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.store_outlined,
                  activeIcon: Icons.store,
                  label: 'Brands',
                  route: AppRoutes.brandList,
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2,
                  label: 'Inventory',
                  route: '/inventory',
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.people_outlined,
                  activeIcon: Icons.people,
                  label: 'Users',
                  route: '/users',
                  currentLocation: currentLocation,
                ),

                SizedBox(height: AppSpacing.lg),
                _NavSection(title: 'MANAGEMENT'),
                _NavItem(
                  icon: Icons.table_restaurant_outlined,
                  activeIcon: Icons.table_restaurant,
                  label: 'Tables',
                  route: '/tables',
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.devices_outlined,
                  activeIcon: Icons.devices,
                  label: 'POS Devices',
                  route: '/all-pos-devices',
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book,
                  label: 'Menu',
                  route: '/menu',
                  currentLocation: currentLocation,
                ),

                _NavItem(
                  icon: Icons.layers_outlined,
                  activeIcon: Icons.layers,
                  label: 'Plans',
                  route: AppRoutes.planList,
                  currentLocation: currentLocation,
                ),

                SizedBox(height: AppSpacing.lg),
                _NavSection(title: 'SYSTEM'),
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Settings',
                  route: AppRoutes.settings,
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                  label: 'Notifications',
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
              label: 'Logout',
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
                  icon: Icons.table_restaurant,
                  label: 'Tables',
                  route: '/tables',
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
    final isSelected = currentLocation.startsWith(route);

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
    if (location == '/inventory') return 'Inventory';
    if (location == '/pos-devices' || location == '/all-pos-devices') return 'POS Devices';
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
            selected: currentLocation.startsWith('/brands'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.brandList);
            },
          ),
          ListTile(
            leading: Icon(Icons.table_restaurant),
            title: Text('Tables'),
            selected: currentLocation.startsWith('/tables'),
            onTap: () {
              Navigator.pop(context);
              context.go('/tables');
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
    this.isFooter = false,
    this.onLogout,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String currentLocation;
  final bool isFooter;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isSelected = currentLocation.startsWith(route);

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