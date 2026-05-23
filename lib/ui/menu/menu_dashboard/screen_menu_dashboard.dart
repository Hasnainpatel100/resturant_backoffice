import 'package:back_office/ui/menu/menu_dashboard/screen_category_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/menu_repository_impl.dart';
import 'package:back_office/data/repositories/branch_repository_impl.dart';
import 'package:back_office/ui/menu/menu_dashboard/cubit_menu.dart';
import 'package:back_office/ui/menu/menu_dashboard/state_menu.dart';
import 'package:back_office/ui/branch/branch_list/cubit_branch.dart';
import 'package:back_office/ui/branch/branch_list/state_branch.dart';

import '../../../data/models/menu_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Root widget – owns branch-selection state
// ─────────────────────────────────────────────────────────────────────────────

class ScreenMenuDashboard extends StatefulWidget {
  final String brandId;

  const ScreenMenuDashboard({super.key, required this.brandId});

  @override
  State<ScreenMenuDashboard> createState() => _ScreenMenuDashboardState();
}

class _ScreenMenuDashboardState extends State<ScreenMenuDashboard> {
  String? _selectedBranchId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CubitMenu(repository: MenuRepositoryImpl()),
        ),
        BlocProvider(
          create: (_) =>
          CubitBranch(repository: BranchRepositoryImpl())
            ..loadBranches(widget.brandId),
        ),
      ],
      child: _MenuDashboardView(
        brandId: widget.brandId,
        selectedBranchId: _selectedBranchId,
        onBranchSelected: (id) => setState(() => _selectedBranchId = id),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main view
// ─────────────────────────────────────────────────────────────────────────────

class _MenuDashboardView extends StatelessWidget {
  final String brandId;
  final String? selectedBranchId;
  final ValueChanged<String> onBranchSelected;

  const _MenuDashboardView({
    required this.brandId,
    this.selectedBranchId,
    required this.onBranchSelected,
  });

  // ── Snackbar helpers ──────────────────────────────────────────────────────

  void _showSuccessSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _showErrorSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/brands/$brandId'),
        ),
        actions: [
          if (selectedBranchId != null)
            BlocBuilder<CubitMenu, StateMenu>(
              builder: (context, state) {
                if (state.status == MenuStatus.loading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                }

                return IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: () {
                    context.read<CubitMenu>().loadCategories(
                      brandId,
                      selectedBranchId!,
                    );
                  },
                );
              },
            ),
        ],
      ),

      body: BlocListener<CubitMenu, StateMenu>(
        listenWhen: (prev, curr) =>
        curr.status != prev.status ||
            curr.categoryOperation != prev.categoryOperation,

        listener: (context, state) {
          if (state.status == MenuStatus.error) {
            _showErrorSnack(
              context,
              state.errorMessage ?? 'An error occurred',
            );
            return;
          }

          if (state.status == MenuStatus.loaded) {
            switch (state.categoryOperation) {
              case CategoryOperation.created:
                _showSuccessSnack(
                  context,
                  'Category created successfully',
                );
                break;

              case CategoryOperation.updated:
                _showSuccessSnack(
                  context,
                  'Category updated successfully',
                );
                break;

              case CategoryOperation.deleted:
                _showSuccessSnack(
                  context,
                  'Category deleted successfully',
                );
                break;

              case CategoryOperation.none:
                break;
            }
          }
        },

        child: Column(
          children: [
            if (selectedBranchId == null)
              _BranchSelector(
                brandId: brandId,
                onBranchSelected: (branchId) {
                  onBranchSelected(branchId);

                  context.read<CubitMenu>().loadCategories(
                    brandId,
                    branchId,
                  );
                },
              )
            else
              Expanded(
                child: BlocBuilder<CubitMenu, StateMenu>(
                  builder: (context, state) {
                    if (state.status == MenuStatus.loading &&
                        state.categories.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state.status == MenuStatus.error &&
                        state.categories.isEmpty) {
                      return _ErrorView(
                        message:
                        state.errorMessage ??
                            'Error loading menu',

                        onRetry: () {
                          context.read<CubitMenu>().loadCategories(
                            brandId,
                            selectedBranchId!,
                          );
                        },
                      );
                    }

                    return _buildMenuContent(context, state);
                  },
                ),
              ),
          ],
        ),
      ),

      floatingActionButton: selectedBranchId != null
          ? FloatingActionButton.extended(
        onPressed: () {
          _showCategoryDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      )
          : null,
    );
  }
  // ── Category grid ─────────────────────────────────────────────────────────

  Widget _buildMenuContent(BuildContext context, StateMenu state) {
    final cs = Theme.of(context).colorScheme;
    final sortedCategories = [
      ...state.categories,
    ]

      ..sort(
            (a, b) =>
            a.displayOrder.compareTo(
              b.displayOrder,
            ),
      );

    return RefreshIndicator(
      onRefresh: () => context
          .read<CubitMenu>()
          .loadCategories(brandId, selectedBranchId!),
      child: state.categories.isEmpty
          ? _EmptyCategoriesView(
        onAdd: () => _showCategoryDialog(context),
      )
          : GridView.builder(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          // Extra bottom padding so FAB doesn't overlap last card
          AppSpacing.md + 80,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.4,
        ),
        itemCount: sortedCategories.length,
        itemBuilder: (context, index) {
          final category = sortedCategories[index];
          return _CategoryCard(
            category: category,
            isUpdating: state.status == MenuStatus.loading &&
                state.lastMutatedCategoryId == category.id,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ScreenCategoryItems(
                      brandId: brandId,
                      branchId: selectedBranchId!,
                      categoryId: category.id,
                      categoryName: category.name,
                    ),
                  ),

                );
              },
            onEdit: () => _showEditCategoryDialog(context, category),
            onDelete: () =>
                _showDeleteConfirmation(context, category.id, category.name),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dialogs
  // ─────────────────────────────────────────────────────────────────────────

  /// CREATE category dialog
  void _showCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _CategoryFormDialog(
        title: 'Add Category',
        submitLabel: 'Create',
        onSubmit: (name, displayOrder, imageUrl) {
          context.read<CubitMenu>().createCategories(brandId, [
            {
              'name': name,
              'branchId': selectedBranchId,
              if (displayOrder != null) 'displayOrder': displayOrder,
              if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
            }
          ]);
        },
      ),
    );
  }


  /// UPDATE category dialog – pre-filled with existing values
  void _showEditCategoryDialog(
      BuildContext context,
      CategoryModel category,
      ) {
    showDialog(
      context: context,
      builder: (_) => _CategoryFormDialog(
        title: 'Edit Category',
        submitLabel: 'Update',

        initialName: category.name,
        initialDisplayOrder: category.displayOrder,
        initialImageUrl: category.imageUrl,

        onSubmit: (name, displayOrder, imageUrl) {

          context.read<CubitMenu>().updateCategory(
            brandId,
            category.id,
            {
              'name': name,

              if (displayOrder != null)
                'displayOrder': displayOrder,

              if (imageUrl != null)
                'imageUrl': imageUrl,
            },
          );
        },
      ),
    );
  }

  /// DELETE confirmation dialog
  void _showDeleteConfirmation(
      BuildContext context,
      String categoryId,
      String categoryName,
      ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        title: const Text('Delete Category'),
        content: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: '"$categoryName"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text: '?\n\nThis action cannot be undone.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<CubitMenu>().deleteCategory(brandId,categoryId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable: Category card with edit / delete menu
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isUpdating;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.isUpdating,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isUpdating ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Background image (if available)
            if (category.imageUrl.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  category.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),

            // Content overlay
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          color: cs.onPrimaryContainer,
                          size: 18,
                        ),
                      ),
                      const Spacer(),
                      // ── Action menu ──
                      if (!isUpdating)
                        _CategoryActionMenu(
                          onEdit: onEdit,
                          onDelete: onDelete,
                        )
                      else
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    category.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (category.displayOrder != null)
                    Text(
                      'Order: ${category.displayOrder}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.outline,
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Reusable: three-dot popup menu on category card
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryActionMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryActionMenu({
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_CategoryAction>(
      icon: const Icon(Icons.more_vert, size: 18),
      padding: EdgeInsets.zero,
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: _CategoryAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _CategoryAction.delete,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 18,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        ),
      ],
      onSelected: (action) {
        switch (action) {
          case _CategoryAction.edit:
            onEdit();
            break;
          case _CategoryAction.delete:
            onDelete();
            break;
        }
      },
    );
  }
}

enum _CategoryAction { edit, delete }

// ─────────────────────────────────────────────────────────────────────────────
// Reusable: Create / Edit category form dialog
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryFormDialog extends StatefulWidget {
  final String title;
  final String submitLabel;
  final String? initialName;
  final int? initialDisplayOrder;
  final String? initialImageUrl;
  final void Function(String name, int? displayOrder, String? imageUrl)
  onSubmit;

  const _CategoryFormDialog({
    required this.title,
    required this.submitLabel,
    this.initialName,
    this.initialDisplayOrder,
    this.initialImageUrl,
    required this.onSubmit,
  });

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _orderCtrl;
  late final TextEditingController _imageUrlCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _orderCtrl = TextEditingController(
      text: widget.initialDisplayOrder?.toString() ?? '',
    );
    _imageUrlCtrl = TextEditingController(text: widget.initialImageUrl ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _orderCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameCtrl.text.trim();
    final orderText = _orderCtrl.text.trim();
    final imageUrl = _imageUrlCtrl.text.trim();

    widget.onSubmit(
      name,
      orderText.isNotEmpty ? int.tryParse(orderText) : null,
      imageUrl.isNotEmpty ? imageUrl : null,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 320),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name (required)
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Category Name *',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: AppSpacing.md),

              // Display order (optional)
              TextFormField(
                controller: _orderCtrl,
                decoration: const InputDecoration(
                  labelText: 'Display Order',
                  prefixIcon: Icon(Icons.sort),
                  hintText: 'e.g. 1',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: AppSpacing.md),

              // Image URL (optional)
              TextFormField(
                controller: _imageUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  prefixIcon: Icon(Icons.image_outlined),
                  hintText: 'https://example.com/image.jpg',
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final uri = Uri.tryParse(v.trim());
                  if (uri == null || !uri.hasAbsolutePath) {
                    return 'Enter a valid URL';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BranchSelector extends StatelessWidget {
  final String brandId;
  final ValueChanged<String> onBranchSelected;

  const _BranchSelector({
    required this.brandId,
    required this.onBranchSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.store_outlined, size: 48, color: cs.outline),
              SizedBox(height: AppSpacing.md),
              Text(
                'Select a branch to manage its menu',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              BlocBuilder<CubitBranch, StateBranch>(
                builder: (context, branchState) {
                  if (branchState.status == BranchStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (branchState.branches.isEmpty) {
                    return Text(
                      'No branches found',
                      style: TextStyle(color: cs.outline),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    decoration:
                    const InputDecoration(labelText: 'Branch'),
                    hint: const Text('Select branch'),
                    items: branchState.branches
                        .map(
                          (b) => DropdownMenuItem(
                        value: b.id,
                        child: Text(b.displayName),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onBranchSelected(value);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCategoriesView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyCategoriesView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.category_outlined, size: 64, color: cs.outlineVariant),
          SizedBox(height: AppSpacing.md),
          Text(
            'No categories yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Add a category to start building your menu.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: cs.outline),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_outlined, size: 48, color: cs.error),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.error),
            ),
            SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

