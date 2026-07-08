import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/inventory/stock_adjustment_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/warehouse_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/item_repository_mock_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_adjustment.dart';
import 'state_adjustment.dart';
import 'package:intl/intl.dart';

class ScreenAdjustmentList extends StatelessWidget {
  final String brandId;
  const ScreenAdjustmentList({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitAdjustment(
        adjustmentRepository: StockAdjustmentRepositoryMockImpl(),
        warehouseRepository: WarehouseRepositoryMockImpl(),
        itemRepository: ItemRepositoryMockImpl(),
      )..loadAdjustments(brandId),
      child: _AdjustmentListView(brandId: brandId),
    );
  }
}

class _AdjustmentListView extends StatelessWidget {
  final String brandId;
  const _AdjustmentListView({required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Adjustments / Audits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CubitAdjustment>().loadAdjustments(brandId),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push('/brands/$brandId/inventory/adjustments/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Adjustment'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocConsumer<CubitAdjustment, StateAdjustment>(
        listener: (context, state) {
          if (state.status == AdjustmentStatus.success) {
            context.read<CubitAdjustment>().loadAdjustments(brandId);
          }
          if (state.status == AdjustmentStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == AdjustmentStatus.loading && state.adjustments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AdjustmentStatus.error) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title: 'Failed to load adjustments',
              subtitle: state.errorMessage,
              actionLabel: 'Retry',
              onAction: () => context.read<CubitAdjustment>().loadAdjustments(brandId),
            );
          }

          if (state.adjustments.isEmpty) {
            return AppEmptyState(
              icon: Icons.edit_note_outlined,
              title: 'No adjustments recorded',
              subtitle: 'Manually adjust inventory for damage, loss, or audits here.',
              actionLabel: 'Create Adjustment',
              onAction: () => context.push('/brands/$brandId/inventory/adjustments/create'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => context.read<CubitAdjustment>().loadAdjustments(brandId),
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: state.adjustments.length,
              itemBuilder: (context, index) {
                final adj = state.adjustments[index];
                final dateStr = DateFormat('dd MMM yyyy').format(
                  DateTime.fromMillisecondsSinceEpoch(adj.adjustmentDate),
                );

                return Card(
                  margin: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cs.secondaryContainer,
                          child: Icon(Icons.edit_note, color: cs.onSecondaryContainer),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                adj.referenceNo,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              dateStr,
                              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Warehouse: ${adj.warehouseName}'),
                              if (adj.notes != null)
                                Text(
                                  'Notes: ${adj.notes}',
                                  style: const TextStyle(fontStyle: FontStyle.italic),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Expand items in list directly
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          children: adj.items.map((item) {
                            final isAdd = item.quantity > 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  Icon(
                                    isAdd ? Icons.add_circle_outline : Icons.remove_circle_outline,
                                    size: 16,
                                    color: isAdd ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(item.itemName)),
                                  Text(
                                    '${item.quantity > 0 ? "+" : ""}${item.quantity.toStringAsFixed(1)} ${item.unitCode ?? ""}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isAdd ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: cs.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.reason,
                                      style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
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
