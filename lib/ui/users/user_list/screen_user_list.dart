
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/user_repository_impl.dart';
import 'package:back_office/ui/users/user_list/cubit_user.dart';
import 'package:back_office/ui/users/user_list/state_user.dart';

class ScreenUserList extends StatelessWidget {
  final String brandId;

  const ScreenUserList({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CubitUser(repository: UserRepositoryImpl())..loadUsers(brandId),
      child: _UserListView(brandId: brandId),
    );
  }
}

class _UserListView extends StatelessWidget {
  final String brandId;

  const _UserListView({required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/brands/$brandId'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => context.go('/brands/$brandId/users/create'),
          ),
        ],
      ),
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
                  Text(state.errorMessage ?? 'Error loading users'),
                  SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => context.read<CubitUser>().loadUsers(brandId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 64, color: cs.outline),
                  SizedBox(height: AppSpacing.md),
                  Text('No users found', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: AppSpacing.sm),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/brands/$brandId/users/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add User'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CubitUser>().loadUsers(brandId);
            },
            child: ListView.separated(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: state.users.length,
              separatorBuilder: (context, index) => SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final user = state.users[index];
                return Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorders.md,
                    side: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      final uid = user.id;
                      if (uid.isEmpty) return;
                      context.go('/brands/$brandId/users/$uid/edit');
                    },
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: cs.primaryContainer,
                            foregroundColor: cs.onPrimaryContainer,
                            child: Text(
                              user.initials,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.fullName,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: user.isActive ? Colors.green.shade50 : Colors.red.shade50,
                                        borderRadius: AppBorders.xs,
                                        border: Border.all(
                                          color: user.isActive ? Colors.green.shade200 : Colors.red.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        user.isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: user.isActive ? Colors.green.shade700 : Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.outline),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.badge_outlined, size: 14, color: cs.primary),
                                    SizedBox(width: 4),
                                    Text(
                                      '${user.role} • ${user.userType}',
                                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.security_outlined, size: 14, color: cs.secondary),
                                    SizedBox(width: 4),
                                    Text(
                                      '${user.permissions.length} perms',
                                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Icon(Icons.chevron_right, color: cs.outline),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}