import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/models/inventory/item_model.dart';
import 'package:back_office/data/repositories/inventory/item_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/category_repository_mock_impl.dart';
import 'package:back_office/data/repositories/inventory/unit_repository_mock_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_item.dart';
import 'state_item.dart';

class ScreenItemList extends StatelessWidget {
  final String brandId;
  const ScreenItemList({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitItem(
        itemRepository: ItemRepositoryMockImpl(),
        categoryRepository: CategoryRepositoryMockImpl(),
        unitRepository: UnitRepositoryMockImpl(),
      )..loadAll(brandId),
      child: _ItemListView(brandId: brandId),
    );
  }
}

class _ItemListView extends StatefulWidget {
  final String brandId;
  const _ItemListView({required this.brandId});

  @override
  State<_ItemListView> createState() => _ItemListViewState();
}

class _ItemListViewState extends State<_ItemListView> {
  final _searchController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    context.read<CubitItem>().loadAll(
          widget.brandId,
          search: query,
          categoryId: _selectedCategoryId,
        );
  }

  void _filterByCategory(String? catId) {
    setState(() => _selectedCategoryId = catId);
    context.read<CubitItem>().loadAll(
          widget.brandId,
          search: _searchController.text,
          categoryId: catId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Items / Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CubitItem>().loadAll(widget.brandId),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () =>
                context.push('/brands/${widget.brandId}/inventory/items/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Item'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocConsumer<CubitItem, StateItem>(
        listener: (context, state) {
          if (state.status == ItemStatus.success) {
            context.read<CubitItem>().loadAll(widget.brandId);
          }
          if (state.status == ItemStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ItemStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // ── Search + filter bar
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  0,
                ),
                child: Column(
                  children: [
                    AppSearchField(
                      controller: _searchController,
                      hint: 'Search items by name or SKU...',
                      onChanged: _search,
                    ),
                    if (state.categories.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _FilterChip(
                              label: 'All',
                              isSelected: _selectedCategoryId == null,
                              onTap: () => _filterByCategory(null),
                            ),
                            ...state.categories.map(
                              (cat) => _FilterChip(
                                label: cat.name,
                                isSelected:
                                    _selectedCategoryId == cat.id,
                                onTap: () => _filterByCategory(cat.id),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── List or empty state
              Expanded(
                child: state.status == ItemStatus.error
                    ? AppEmptyState(
                        icon: Icons.error_outline,
                        title: 'Failed to load items',
                        subtitle: state.errorMessage,
                        actionLabel: 'Retry',
                        onAction: () =>
                            context.read<CubitItem>().loadAll(widget.brandId),
                      )
                    : state.items.isEmpty
                        ? AppEmptyState(
                            icon: Icons.inventory_2_outlined,
                            title: 'No items found',
                            subtitle: _searchController.text.isNotEmpty
                                ? 'No results for "${_searchController.text}"'
                                : 'Add your first inventory item.',
                            actionLabel: _searchController.text.isEmpty
                                ? 'Add Item'
                                : null,
                            onAction: _searchController.text.isEmpty
                                ? () => context.push(
                                      '/brands/${widget.brandId}/inventory/items/create',
                                    )
                                : null,
                          )
                        : RefreshIndicator(
                            onRefresh: () async => context
                                .read<CubitItem>()
                                .loadAll(widget.brandId),
                            child: ListView.builder(
                              padding: EdgeInsets.all(AppSpacing.md),
                              itemCount: state.items.length,
                              itemBuilder: (context, index) {
                                final item = state.items[index];
                                return _ItemCard(
                                  item: item,
                                  onTap: () => context.push(
                                    '/brands/${widget.brandId}/inventory/items/${item.id}',
                                  ),
                                  onEdit: () => context.push(
                                    '/brands/${widget.brandId}/inventory/items/${item.id}/edit',
                                  ),
                                  onDelete: () =>
                                      _confirmDelete(context, item),
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

  void _confirmDelete(BuildContext context, ItemModel item) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Item?'),
        content: Text(
          'Are you sure you want to delete "${item.name}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<CubitItem>().deleteItem(widget.brandId, item.id);
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

class _ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ItemCard({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLow = item.isLowStock;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            // Status strip — red if low stock, green if active, grey if inactive
            Container(
              height: 3,
              color: !item.isActive
                  ? Colors.grey
                  : isLow
                      ? Colors.orange
                      : Colors.green,
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Item avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: cs.onPrimaryContainer,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.categoryName ?? '—',
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _InfoChip(
                              label:
                                  'Stock: ${item.currentStock.toStringAsFixed(1)} ${item.unitCode ?? ''}',
                              color: isLow ? Colors.orange : cs.primary,
                            ),
                            const SizedBox(width: 6),
                            _InfoChip(
                              label:
                                  '₹${item.sellingPrice.toStringAsFixed(0)}',
                              color: cs.secondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: cs.outline),
                    onSelected: (v) {
                      if (v == 'view') onTap();
                      if (v == 'edit') onEdit();
                      if (v == 'delete') onDelete();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility_outlined),
                          title: Text('View'),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
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
                          leading:
                              Icon(Icons.delete_outline, color: cs.error),
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
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        visualDensity: VisualDensity.compact,
        backgroundColor: cs.surfaceContainerHighest,
        selectedColor: cs.primaryContainer,
        labelStyle: TextStyle(
          fontSize: 12,
          color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
          fontWeight:
              isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
