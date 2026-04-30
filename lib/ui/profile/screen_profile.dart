import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/config/app_config.dart';
import 'package:back_office/routing/app_routes.dart';
import 'package:back_office/services/auth_service.dart';

class ScreenProfile extends StatelessWidget {
  const ScreenProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      AppConfig.userId.isNotEmpty ? AppConfig.userId[0].toUpperCase() : 'U',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'User ID: ${AppConfig.userId.isEmpty ? 'N/A' : AppConfig.userId.substring(0, AppConfig.userId.length > 8 ? 8 : AppConfig.userId.length)}...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text('Role: ${AppConfig.role.isEmpty ? 'N/A' : AppConfig.role}'),
                  Text('Type: ${AppConfig.userType.isEmpty ? 'N/A' : AppConfig.userType}'),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change PIN'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Card(
            child: ListTile(
              leading: Icon(Icons.logout, color: cs.error),
              title: Text('Logout', style: TextStyle(color: cs.error)),
              onTap: () async {
                await AuthService.instance.logout();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
