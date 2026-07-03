import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/repositories/inventory/item_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/category_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/unit_repository_mock_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_item.dart';
import 'state_item.dart';

class ScreenItemDetail extends StatelessWidget {
  final String brandId;
  final String itemId;

  const ScreenItemDetail({
    super.key,
    required this.brandId,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitItem(
        itemRepository: ItemRepositoryMockImpl(),
        categoryRepository: CategoryRepositoryMockImpl(),
        unitRepository: UnitRepositoryMockImpl(),
      )..loadItem(brandId, itemId),
      child: _ItemDetailView(brandId: brandId, itemId: itemId),
    );
  }
}

class _ItemDetailView extends StatelessWidget {
  final String brandId;
  final String itemId;

  const _ItemDetailView({required this.brandId, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Item',
            onPressed: () =>
                context.push('/brands/$brandId/inventory/items/$itemId/edit'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<CubitItem, StateItem>(
        builder: (context, state) {
          if (state.status == ItemStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.selected == null) {
            return AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Item not found',
              actionLabel: 'Go Back',
              onAction: () => context.pop(),
            );
          }

          final item = state.selected!;
          final isLow = item.isLowStock;

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header card ──────────────────────────────────────────────
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        color: !item.isActive
                            ? Colors.grey
                            : isLow
                                ? Colors.orange
                                : Colors.green,
                      ),
                      Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: cs.onPrimaryContainer,
                                size: 32,
                              ),
                            ),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name,
                                      style: tt.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold)),
                                  if (item.sku != null) ...[
                                    const SizedBox(height: 4),
                                    Text('SKU: ${item.sku}',
                                        style: tt.bodyMedium?.copyWith(
                                            color: cs.onSurfaceVariant)),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _Badge(
                                        label: item.isActive
                                            ? 'Active'
                                            : 'Inactive',
                                        color: item.isActive
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      if (isLow) ...[
                                        const SizedBox(width: 6),
                                        _Badge(
                                            label: '⚠ Low Stock',
                                            color: Colors.orange),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // ── Stock & Price ─────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.inventory_outlined,
                        label: 'Current Stock',
                        value:
                            '${item.currentStock.toStringAsFixed(1)} ${item.unitCode ?? ''}',
                        color: isLow ? Colors.orange : Colors.green,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.warning_amber_outlined,
                        label: 'Alert Qty',
                        value:
                            '${item.alertQty.toStringAsFixed(1)} ${item.unitCode ?? ''}',
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.shopping_cart_outlined,
                        label: 'Cost Price',
                        value: '₹${item.costPrice.toStringAsFixed(2)}',
                        color: cs.secondary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.sell_outlined,
                        label: 'Selling Price',
                        value: '₹${item.sellingPrice.toStringAsFixed(2)}',
                        color: cs.tertiary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),

                // ── Details ───────────────────────────────────────────────────
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Details',
                            style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: cs.primary)),
                        const Divider(),
                        _DetailRow(label: 'Category',
                            value: item.categoryName ?? '—'),
                        _DetailRow(label: 'Unit',
                            value: item.unitName != null
                                ? '${item.unitName} (${item.unitCode})'
                                : '—'),
                        _DetailRow(label: 'Barcode',
                            value: item.barcode ?? '—'),
                        _DetailRow(
                          label: 'Profit Margin',
                          value:
                              '${item.profitMarginPercent.toStringAsFixed(1)}%',
                        ),
                        if (item.description != null)
                          _DetailRow(label: 'Description',
                              value: item.description!),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // ── Edit button ───────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push(
                        '/brands/$brandId/inventory/items/$itemId/edit'),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Item'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
