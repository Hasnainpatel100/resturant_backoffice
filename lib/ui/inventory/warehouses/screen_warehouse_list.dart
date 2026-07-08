import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/models/inventory/warehouse_model.dart';
import 'package:back_office/data/repositories/inventory/warehouse_repository_mock_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_warehouse.dart';
import 'state_warehouse.dart';

class ScreenWarehouseList extends StatelessWidget {
  final String brandId;
  const ScreenWarehouseList({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CubitWarehouse(repository: WarehouseRepositoryMockImpl())
            ..loadWarehouses(brandId),
      child: _WarehouseListView(brandId: brandId),
    );
  }
}

class _WarehouseListView extends StatelessWidget {
  final String brandId;
  const _WarehouseListView({required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<CubitWarehouse>().loadWarehouses(brandId),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () =>
                context.push('/brands/$brandId/inventory/warehouses/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Warehouse'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocConsumer<CubitWarehouse, StateWarehouse>(
        listener: (context, state) {
          if (state.status == WarehouseStatus.success) {
            context.read<CubitWarehouse>().loadWarehouses(brandId);
          }
          if (state.status == WarehouseStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == WarehouseStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == WarehouseStatus.error) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title: 'Failed to load warehouses',
              subtitle: state.errorMessage,
              actionLabel: 'Retry',
              onAction: () =>
                  context.read<CubitWarehouse>().loadWarehouses(brandId),
            );
          }

          if (state.warehouses.isEmpty) {
            return AppEmptyState(
              icon: Icons.warehouse_outlined,
              title: 'No warehouses yet',
              subtitle: 'Add storage locations like kitchen store, cold room, etc.',
              actionLabel: 'Add Warehouse',
              onAction: () =>
                  context.push('/brands/$brandId/inventory/warehouses/create'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<CubitWarehouse>().loadWarehouses(brandId),
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: state.warehouses.length,
              itemBuilder: (context, index) {
                final wh = state.warehouses[index];
                return _WarehouseCard(
                  warehouse: wh,
                  onEdit: () => context.push(
                    '/brands/$brandId/inventory/warehouses/${wh.id}/edit',
                  ),
                  onDelete: () => _confirmDelete(context, wh),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WarehouseModel wh) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Warehouse?'),
        content: Text(
          'Are you sure you want to delete "${wh.name}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<CubitWarehouse>().deleteWarehouse(brandId, wh.id);
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

class _WarehouseCard extends StatelessWidget {
  final WarehouseModel warehouse;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WarehouseCard({
    required this.warehouse,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isActive = warehouse.isActive;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(height: 3, color: isActive ? Colors.green : Colors.grey),
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warehouse_outlined,
                color: cs.onTertiaryContainer,
                size: 22,
              ),
            ),
            title: Text(
              warehouse.name,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: warehouse.address != null
                ? Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          warehouse.address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  )
                : null,
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
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
