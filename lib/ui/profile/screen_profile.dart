import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/config/app_config.dart';
import 'package:back_office/routing/app_routes.dart';
import 'package:back_office/services/auth_service.dart';
import 'package:back_office/data/repositories/user_repository_impl.dart';
import 'package:back_office/ui/users/user_list/cubit_user.dart';
import 'package:back_office/ui/users/user_list/state_user.dart';

class ScreenProfile extends StatelessWidget {
  const ScreenProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final userId = AppConfig.userId;
        return CubitUser(repository: UserRepositoryImpl())..loadUser(userId);
      },
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: BlocBuilder<CubitUser, StateUser>(
        builder: (context, state) {
          if (state.status == UserStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == UserStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Failed to load profile', style: TextStyle(color: cs.error)),
                  SizedBox(height: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: () => context.read<CubitUser>().loadUser(AppConfig.userId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final userProfile = state.user;
          if (userProfile == null) {
            return const Center(child: Text('Profile not found'));
          }

          final user = userProfile.user;
          final details = userProfile.userDetails;

          return ListView(
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
                          user.initials,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                      if (user.phoneNumber.isNotEmpty)
                        Text(user.phoneNumber, style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(user.role),
                            backgroundColor: cs.secondaryContainer,
                            labelStyle: TextStyle(color: cs.onSecondaryContainer),
                          ),
                          if (details?.designation != null && details!.designation!.isNotEmpty)
                            Chip(
                              label: Text(details.designation!),
                              backgroundColor: cs.tertiaryContainer,
                              labelStyle: TextStyle(color: cs.onTertiaryContainer),
                            ),
                        ],
                      ),
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
                      onTap: () {
                        // TODO: Implement Edit Profile for logged in user.
                        // We could navigate to userEdit, but need brandId.
                        if (user.brandId.isNotEmpty) {
                          context.go('/brands/${user.brandId}/users/${user.id}/edit');
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Change PIN'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Implement Change PIN
                      },
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
          );
        },
      ),
    );
  }
}
