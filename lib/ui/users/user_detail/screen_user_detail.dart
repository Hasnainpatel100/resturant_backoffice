
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/user_repository_impl.dart';
import 'package:back_office/ui/users/user_list/cubit_user.dart';
import 'package:back_office/ui/users/user_list/state_user.dart';

class ScreenUserDetail extends StatelessWidget {
  final String brandId;
  final String userId;

  const ScreenUserDetail({
    super.key,
    required this.brandId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CubitUser(repository: UserRepositoryImpl())..loadUser(userId),
      child: _UserDetailView(brandId: brandId),
    );
  }
}

class _UserDetailView extends StatelessWidget {
  final String brandId;

  const _UserDetailView({required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/brands/$brandId/users'),
        ),
        actions: [
          BlocBuilder<CubitUser, StateUser>(
            builder: (context, state) {
              if (state.status == UserStatus.loaded && state.user != null) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.go('/brands/$brandId/users/${state.user!.user.id}/edit'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CubitUser, StateUser>(
        builder: (context, state) {
          if (state.status == UserStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == UserStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Failed to load user'));
          }

          final userProfile = state.user;
          if (userProfile == null) {
            return const Center(child: Text('User not found'));
          }

          final user = userProfile.user;

          return ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              // User profile card
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
                      SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(user.role),
                            backgroundColor: cs.secondaryContainer,
                            labelStyle: TextStyle(color: cs.onSecondaryContainer),
                          ),
                          Chip(
                            label: Text(user.userType),
                            backgroundColor: cs.tertiaryContainer,
                            labelStyle: TextStyle(color: cs.onTertiaryContainer),
                          ),
                          Chip(
                            label: Text(user.isActive ? 'Active' : 'Inactive'),
                            backgroundColor: user.isActive ? Colors.green.shade100 : Colors.red.shade100,
                            labelStyle: TextStyle(color: user.isActive ? Colors.green.shade800 : Colors.red.shade800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),

              // Basic Info card
              _buildSection(
                context,
                title: 'Basic Information',
                icon: Icons.person_outline,
                children: [
                  _buildInfoRow('Username', user.username),
                  _buildInfoRow('User Type', user.userType),
                  _buildInfoRow('Role', user.role),
                  _buildInfoRow('Brand ID', user.brandId),
                  _buildInfoRow('Branch ID', user.branchId),
                ],
              ),
              SizedBox(height: AppSpacing.md),

              // Permissions card
              _buildPermissionsSection(context, user.permissions),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPermissionsSection(BuildContext context, List<String> permissions) {
    final cs = Theme.of(context).colorScheme;

    if (permissions.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.security_outlined, size: 20, color: cs.primary),
                  SizedBox(width: AppSpacing.sm),
                  Text('Permissions', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const Divider(),
              Text('No permissions assigned', style: TextStyle(color: cs.outline)),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security_outlined, size: 20, color: cs.primary),
                SizedBox(width: AppSpacing.sm),
                Text('Permissions', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(
                  '${permissions.length} assigned',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.outline),
                ),
              ],
            ),
            const Divider(),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: permissions.map((perm) {
                final displayName = perm.replaceAll('_', ' ');
                return Chip(
                  label: Text(
                    displayName,
                    style: TextStyle(fontSize: 11, color: cs.onSecondaryContainer),
                  ),
                  backgroundColor: cs.secondaryContainer,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    final validChildren = children.where((child) => child is! SizedBox).toList();
    if (validChildren.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                SizedBox(width: AppSpacing.sm),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(),
            ...validChildren,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
