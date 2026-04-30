import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/imports/packages_imports.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;

  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 64,
              color: cs.outline,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              '$title coming soon',
              style: tt.headlineSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'This feature is under development',
              style: tt.bodyMedium?.copyWith(color: cs.outline),
            ),
            SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.brandList),
              child: const Text('Go to Brands'),
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'Inventory');
  }
}

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'Users');
  }
}

class TablesScreen extends StatelessWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'Tables');
  }
}

class PosDevicesScreen extends StatelessWidget {
  const PosDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'POS Devices');
  }
}

class StandalonePosDevicesScreen extends StatelessWidget {
  const StandalonePosDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'POS Devices');
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'Menu');
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'Notifications');
  }
}