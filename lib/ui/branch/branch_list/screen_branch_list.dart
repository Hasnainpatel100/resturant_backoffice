import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/branch_repository_impl.dart';
import 'package:back_office/ui/branch/branch_list/cubit_branch.dart';
import 'package:back_office/ui/branch/branch_list/state_branch.dart';
import 'package:back_office/data/models/branch_model.dart';
import 'package:back_office/shared/shared.dart';

class ScreenBranchList extends StatelessWidget {
  final String brandId;

  const ScreenBranchList({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CubitBranch(repository: BranchRepositoryImpl())..loadBranches(brandId),
      child: _BranchListView(brandId: brandId),
    );
  }
}

class _BranchListView extends StatelessWidget {
  final String brandId;

  const _BranchListView({required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branches'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/brands/$brandId'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CubitBranch>().loadBranches(brandId),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.go('/brands/$brandId/branches/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Branch'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocConsumer<CubitBranch, StateBranch>(
        listener: (context, state) {
          if (state.status == BranchStatus.success) {
            showToast(context, message: 'Branch deleted', status: 'success');
            context.read<CubitBranch>().loadBranches(brandId);
          }
          if (state.status == BranchStatus.error) {
            showToast(context, message: state.errorMessage ?? 'Error', status: 'error');
          }
        },
        builder: (context, state) {
          if (state.status == BranchStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BranchStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 56, color: cs.error),
                  SizedBox(height: AppSpacing.md),
                  Text(state.errorMessage ?? 'Error loading branches',
                      style: TextStyle(color: cs.error)),
                  SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: () => context.read<CubitBranch>().loadBranches(brandId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.branches.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_city_outlined, size: 64, color: cs.primary),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text('No branches yet',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  SizedBox(height: AppSpacing.sm),
                  Text('Add your first branch to this brand',
                      style: TextStyle(color: cs.outline)),
                  SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: () => context.go('/brands/$brandId/branches/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Branch'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                ],
              ),
            );
          }

          // Summary bar
          final activeCount = state.branches.where((b) => b.isActive).length;
          final inactiveCount = state.branches.length - activeCount;

          return Column(
            children: [
              // ── Summary strip ──
              Container(
                color: cs.surfaceContainerHighest,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _SummaryChip(
                      icon: Icons.check_circle,
                      color: Colors.green,
                      label: '$activeCount Active',
                    ),
                    const SizedBox(width: 16),
                    _SummaryChip(
                      icon: Icons.cancel,
                      color: Colors.grey,
                      label: '$inactiveCount Inactive',
                    ),
                    const Spacer(),
                    Text(
                      '${state.branches.length} total',
                      style: TextStyle(color: cs.outline, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // ── Branch list ──
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<CubitBranch>().loadBranches(brandId);
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(AppSpacing.md),
                    itemCount: state.branches.length,
                    itemBuilder: (context, index) {
                      final branch = state.branches[index];
                      return _BranchCard(
                        branch: branch,
                        onTap: () => context.go('/brands/$brandId/branches/${branch.id}'),
                        onEdit: () =>
                            context.go('/brands/$brandId/branches/${branch.id}/edit'),
                        onDelete: () => _confirmDelete(context, branch),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, BranchBasicModel branch) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Branch?'),
        content: Text(
          'Are you sure you want to delete "${branch.displayName}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CubitBranch>().deleteBranch(branch.id);
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _BranchCard extends StatelessWidget {
  final BranchBasicModel branch;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BranchCard({
    required this.branch,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = branch.isActive ? Colors.green : Colors.grey;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(height: 3, color: statusColor),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.store, color: statusColor, size: 22),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 13, color: cs.outline),
                            const SizedBox(width: 2),
                            Text(
                              branch.city.isEmpty ? 'No city' : branch.city,
                              style: TextStyle(color: cs.outline, fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                branch.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: cs.outline),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: cs.error),
                          title: Text('Delete', style: TextStyle(color: cs.error)),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _SummaryChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}