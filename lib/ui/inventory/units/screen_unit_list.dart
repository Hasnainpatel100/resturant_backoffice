import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/models/inventory/unit_model.dart';
import 'package:back_office/data/repositories/inventory/unit_repository_mock_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_unit.dart';
import 'state_unit.dart';

class ScreenUnitList extends StatelessWidget {
  final String brandId;
  const ScreenUnitList({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CubitUnit(repository: UnitRepositoryMockImpl())..loadUnits(brandId),
      child: _UnitListView(brandId: brandId),
    );
  }
}

class _UnitListView extends StatelessWidget {
  final String brandId;
  const _UnitListView({required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Units of Measurement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<CubitUnit>().loadUnits(brandId),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () =>
                context.push('/brands/$brandId/inventory/units/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Unit'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocConsumer<CubitUnit, StateUnit>(
        listener: (context, state) {
          if (state.status == UnitStatus.success) {
            context.read<CubitUnit>().loadUnits(brandId);
          }
          if (state.status == UnitStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == UnitStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == UnitStatus.error) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title: 'Failed to load units',
              subtitle: state.errorMessage,
              actionLabel: 'Retry',
              onAction: () => context.read<CubitUnit>().loadUnits(brandId),
            );
          }

          if (state.units.isEmpty) {
            return AppEmptyState(
              icon: Icons.straighten_outlined,
              title: 'No units yet',
              subtitle:
                  'Add units of measurement like kg, litre, piece, etc.',
              actionLabel: 'Add Unit',
              onAction: () =>
                  context.push('/brands/$brandId/inventory/units/create'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<CubitUnit>().loadUnits(brandId),
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: state.units.length,
              itemBuilder: (context, index) {
                final unit = state.units[index];
                return _UnitCard(
                  unit: unit,
                  onEdit: () => context.push(
                    '/brands/$brandId/inventory/units/${unit.id}/edit',
                  ),
                  onDelete: () => _confirmDelete(context, unit),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, UnitModel unit) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Unit?'),
        content: Text(
          'Are you sure you want to delete "${unit.displayLabel}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<CubitUnit>().deleteUnit(brandId, unit.id);
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _UnitCard extends StatelessWidget {
  final UnitModel unit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UnitCard({
    required this.unit,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isActive = unit.isActive;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(height: 3, color: isActive ? Colors.green : Colors.grey),
          ListTile(
            leading: Container(
              width: 52,
              height: 44,
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  unit.code,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: cs.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            title: Text(
              unit.name,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Code: ${unit.code}',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusBadge(isActive: isActive),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: cs.outline),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: cs.error),
                        title: Text('Delete',
                            style: TextStyle(color: cs.error)),
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
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
