import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/models/inventory/inventory_category_model.dart';
import 'package:back_office/data/repositories/inventory/category_repository_mock_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_category.dart';
import 'state_category.dart';

class ScreenCategoryList extends StatelessWidget {
  final String brandId;
  const ScreenCategoryList({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CubitCategory(repository: CategoryRepositoryMockImpl())
            ..loadCategories(brandId),
      child: _CategoryListView(brandId: brandId),
    );
  }
}

class _CategoryListView extends StatelessWidget {
  final String brandId;
  const _CategoryListView({required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<CubitCategory>().loadCategories(brandId),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push(
              '/brands/$brandId/inventory/categories/create',
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Category'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocConsumer<CubitCategory, StateCategory>(
        listener: (context, state) {
          if (state.status == CategoryStatus.success) {
            context.read<CubitCategory>().loadCategories(brandId);
          }
          if (state.status == CategoryStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CategoryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CategoryStatus.error) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title: 'Failed to load categories',
              subtitle: state.errorMessage,
              actionLabel: 'Retry',
              onAction: () =>
                  context.read<CubitCategory>().loadCategories(brandId),
            );
          }

          if (state.categories.isEmpty) {
            return AppEmptyState(
              icon: Icons.category_outlined,
              title: 'No categories yet',
              subtitle: 'Create your first item category to get started.',
              actionLabel: 'Add Category',
              onAction: () => context.push(
                '/brands/$brandId/inventory/categories/create',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<CubitCategory>().loadCategories(brandId),
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final cat = state.categories[index];
                return _CategoryCard(
                  category: cat,
                  onEdit: () => context.push(
                    '/brands/$brandId/inventory/categories/${cat.id}/edit',
                  ),
                  onDelete: () => _confirmDelete(context, brandId, cat),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String brandId,
    InventoryCategoryModel cat,
  ) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Category?'),
        content: Text(
          'Are you sure you want to delete "${cat.name}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<CubitCategory>().deleteCategory(brandId, cat.id);
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

class _CategoryCard extends StatelessWidget {
  final InventoryCategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isActive = category.isActive;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Status accent strip
          Container(
            height: 3,
            color: isActive ? Colors.green : Colors.grey,
          ),
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.category_outlined,
                color: cs.onPrimaryContainer,
                size: 22,
              ),
            ),
            title: Text(
              category.name,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: category.description != null
                ? Text(
                    category.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: cs.onSurfaceVariant),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusBadge(isActive: isActive),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: cs.outline),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
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
                        leading: Icon(Icons.delete_outline,
                            color: cs.error),
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
    final label = isActive ? 'Active' : 'Inactive';
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
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
