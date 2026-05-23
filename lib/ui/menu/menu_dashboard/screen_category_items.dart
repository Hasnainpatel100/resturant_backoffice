import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/repositories/menu_repository_impl.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/ui/menu/menu_dashboard/cubit_menu.dart';
import 'package:back_office/ui/menu/menu_dashboard/state_menu.dart';
import 'package:back_office/data/models/menu_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen entry point – owns its own CubitMenu lifecycle
// ─────────────────────────────────────────────────────────────────────────────

class ScreenCategoryItems extends StatefulWidget {
  final String brandId;
  final String branchId;
  final String categoryId;
  final String categoryName;

  const ScreenCategoryItems({
    super.key,
    required this.brandId,
    required this.branchId,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ScreenCategoryItems> createState() => _ScreenCategoryItemsState();
}

class _ScreenCategoryItemsState extends State<ScreenCategoryItems> {
  late final CubitMenu _cubit;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _cubit = CubitMenu(repository: MenuRepositoryImpl());
    _loadItems();
  }

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  void _loadItems() {
    _cubit.loadMenuItems(
      widget.brandId,
      widget.branchId,
      categoryId: widget.categoryId,
    );
  }

  List<MenuItemResponse> _filteredItems(List<MenuItemResponse> items) {
    if (_searchQuery.trim().isEmpty) return items;
    final q = _searchQuery.toLowerCase();
    return items
        .where((i) =>
    i.name.toLowerCase().contains(q) ||
        (i.description?.toLowerCase().contains(q) ?? false) ||
        i.foodType.toLowerCase().contains(q))
        .toList();
  }

  // ── Snackbars ──────────────────────────────────────────────────────────────

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(msg),
        ]),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }

  // ── Sheet / dialog helpers ─────────────────────────────────────────────────

  void _openAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: _MenuItemFormSheet(
          brandId: widget.brandId,
          branchId: widget.branchId,
          categoryId: widget.categoryId,
          onSuccess: () => _showSuccess('Item added successfully'),
          onError: _showErrorSnack,
        ),
      ),
    );
  }

  void _openEditItemSheet(MenuItemResponse item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: _MenuItemFormSheet(
          brandId: widget.brandId,
          branchId: widget.branchId,
          categoryId: widget.categoryId,
          existingItem: item,
          onSuccess: () => _showSuccess('Item updated successfully'),
          onError: _showErrorSnack,
        ),
      ),
    );
  }

  void _confirmDelete(MenuItemResponse item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        title: const Text('Delete Item'),
        content: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: '"${item.name}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?\n\nThis action cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _cubit.deleteMenuItem(item.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<CubitMenu, StateMenu>(
        listener: (context, state) {
          if (state.status == MenuStatus.error) {
            _showErrorSnack(state.errorMessage ?? 'An error occurred');
          }
        },
        child: Scaffold(
          backgroundColor: cs.surfaceContainerLow,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            title: BlocBuilder<CubitMenu, StateMenu>(
              builder: (_, state) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.categoryName,
                    style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: state.menuItems.isNotEmpty
                        ? Text(
                      '${state.menuItems.length} item${state.menuItems.length == 1 ? '' : 's'}',
                      key: ValueKey(state.menuItems.length),
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              BlocBuilder<CubitMenu, StateMenu>(
                builder: (_, state) {
                  final isLoading = state.status == MenuStatus.loading;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _showSearch
                              ? Icons.search_off_rounded
                              : Icons.search_rounded,
                        ),
                        tooltip: _showSearch ? 'Close Search' : 'Search',
                        onPressed: () {
                          setState(() {
                            _showSearch = !_showSearch;
                            if (!_showSearch) {
                              _searchController.clear();
                              _searchQuery = '';
                            }
                          });
                        },
                      ),
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child:
                            CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          tooltip: 'Refresh',
                          onPressed: _loadItems,
                        ),
                      const SizedBox(width: 4),
                    ],
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Animated search bar ──────────────────────────────────────
              AnimatedCrossFade(
                firstChild: const SizedBox(height: 0, width: double.infinity),
                secondChild: _SearchBar(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                crossFadeState: _showSearch
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 220),
                sizeCurve: Curves.easeOut,
              ),

              // ── Main content ─────────────────────────────────────────────
              Expanded(
                child: BlocBuilder<CubitMenu, StateMenu>(
                  builder: (context, state) {
                    // Full-screen loading skeleton
                    if (state.status == MenuStatus.loading &&
                        state.menuItems.isEmpty) {
                      return const _LoadingGrid();
                    }

                    // Full-screen error
                    if (state.status == MenuStatus.error &&
                        state.menuItems.isEmpty) {
                      return _ErrorView(
                        message: state.errorMessage ?? 'Failed to load items',
                        onRetry: _loadItems,
                      );
                    }

                    final filtered = _filteredItems(state.menuItems);

                    if (filtered.isEmpty) {
                      return _EmptyItemsView(
                        isFiltered: _searchQuery.isNotEmpty,
                        onAdd: _searchQuery.isNotEmpty
                            ? null
                            : _openAddItemSheet,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _loadItems(),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.maxWidth;
                          final cols = w >= 1200
                              ? 3
                              : w >= 720
                              ? 2
                              : 1;

                          return GridView.builder(
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.md,
                              AppSpacing.md,
                              AppSpacing.md,
                              AppSpacing.md + 80, // FAB clearance
                            ),
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              mainAxisSpacing: AppSpacing.sm,
                              crossAxisSpacing: AppSpacing.sm,
                              // Taller cards in single-column mode to fit description
                              childAspectRatio: cols == 1 ? 3.8 : 2.6,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (_, index) {
                              final item = filtered[index];
                              return _ItemCard(
                                item: item,
                                onEdit: () => _openEditItemSheet(item),
                                onDelete: () => _confirmDelete(item),
                                onToggle: (val) {
                                  _cubit.toggleMenuItemAvailability(
                                    item.id,
                                    {
                                      'isAvailable': val,
                                      'brandId': widget.brandId,
                                      'branchId': widget.branchId,
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAddItemSheet,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Item'),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor ?? cs.surface,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search items by name or description…',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              controller.clear();
              onChanged('');
            },
          )
              : null,
          filled: true,
          fillColor: cs.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          isDense: true,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item Card
// ─────────────────────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final MenuItemResponse item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const _ItemCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  /// Derive veg/non-veg from the foodType field returned by the API.
  bool get _isVeg {
    final t = item.foodType.toUpperCase();
    if (t.isEmpty) return true; // default to veg if not specified
    if (t.contains('NON')) return false;
    return t.contains('VEG');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final vegColor =
    _isVeg ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final vegBg =
    _isVeg ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final availColor =
    item.isAvailable ? Colors.green.shade700 : Colors.red.shade700;
    final availBg = item.isAvailable
        ? Colors.green.shade50
        : Colors.red.shade50;
    final availBorder = item.isAvailable
        ? Colors.green.shade200
        : Colors.red.shade200;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      color: cs.surface,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Left veg/non-veg stripe ───────────────────────────────────
            Container(width: 5, color: vegColor),

            // ── Card content ─────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Row 1: Veg badge + Name + Price + Menu ────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Veg / Non-veg icon (FSSAI style box)
                        Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            border: Border.all(color: vegColor, width: 1.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: vegColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Item name
                        Expanded(
                          child: Text(
                            item.name,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Price chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '₹${item.basePrice % 1 == 0 ? item.basePrice.toStringAsFixed(0) : item.basePrice.toStringAsFixed(2)}',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),

                        // Three-dot context menu
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: PopupMenuButton<_ItemAction>(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.more_vert,
                                size: 18, color: cs.onSurfaceVariant),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: _ItemAction.edit,
                                height: 40,
                                child: Row(children: [
                                  Icon(Icons.edit_outlined,
                                      size: 16, color: cs.onSurface),
                                  const SizedBox(width: 10),
                                  const Text('Edit'),
                                ]),
                              ),
                              PopupMenuItem(
                                value: _ItemAction.delete,
                                height: 40,
                                child: Row(children: [
                                  Icon(Icons.delete_outline,
                                      size: 16, color: cs.error),
                                  const SizedBox(width: 10),
                                  Text('Delete',
                                      style: TextStyle(color: cs.error)),
                                ]),
                              ),
                            ],
                            onSelected: (a) {
                              if (a == _ItemAction.edit) onEdit();
                              if (a == _ItemAction.delete) onDelete();
                            },
                          ),
                        ),
                      ],
                    ),

                    // ── Row 2: Description ────────────────────────────────
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 26),
                        child: Text(
                          item.description!,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant, height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],

                    const Spacer(),

                    // ── Row 3: Status badge + Toggle ──────────────────────
                    Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: Row(
                        children: [
                          // Availability pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: availBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: availBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: availColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  item.isAvailable ? 'Available' : 'Unavailable',
                                  style: tt.labelSmall?.copyWith(
                                    color: availColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Veg label badge
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: vegBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: vegColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              _isVeg ? 'Veg' : 'Non-Veg',
                              style: tt.labelSmall?.copyWith(
                                color: vegColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Availability toggle
                          Transform.scale(
                            scale: 0.75,
                            alignment: Alignment.centerRight,
                            child: Switch(
                              value: item.isAvailable,
                              onChanged: onToggle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ItemAction { edit, delete }

// ─────────────────────────────────────────────────────────────────────────────
// Loading shimmer grid placeholder
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 1200
            ? 3
            : constraints.maxWidth >= 720
            ? 2
            : 1;
        return GridView.builder(
          padding: EdgeInsets.all(AppSpacing.md),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: cols == 1 ? 3.8 : 2.6,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ShimmerBox(width: 160, height: 14, cs: cs),
                        _ShimmerBox(
                            width: double.infinity, height: 10, cs: cs),
                        _ShimmerBox(width: 120, height: 10, cs: cs),
                        _ShimmerBox(width: 80, height: 22, cs: cs),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final ColorScheme cs;

  const _ShimmerBox(
      {required this.width, required this.height, required this.cs});

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(6),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Add / Edit Item Form – Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _MenuItemFormSheet extends StatefulWidget {
  final String brandId;
  final String branchId;
  final String categoryId;
  final MenuItemResponse? existingItem; // null → create mode
  final VoidCallback onSuccess;
  final ValueChanged<String> onError;

  const _MenuItemFormSheet({
    required this.brandId,
    required this.branchId,
    required this.categoryId,
    this.existingItem,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<_MenuItemFormSheet> createState() => _MenuItemFormSheetState();
}

class _MenuItemFormSheetState extends State<_MenuItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _orderCtrl;
  late bool _isVeg;
  late bool _isAvailable;

  /// Becomes true after the user taps Save, so BlocListener only reacts
  /// to state changes that this form triggered.
  bool _submitted = false;

  bool get _isEditMode => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existingItem;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _codeCtrl = TextEditingController(); // not in response model
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _priceCtrl = TextEditingController(
      text: e != null
          ? (e.basePrice % 1 == 0
          ? e.basePrice.toStringAsFixed(0)
          : e.basePrice.toStringAsFixed(2))
          : '',
    );
    _orderCtrl = TextEditingController();
    _isVeg = true; // default veg; could be derived from e.foodType
    _isAvailable = e?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitted = true);

    final cubit = context.read<CubitMenu>();
    final price = double.parse(_priceCtrl.text.trim());
    final order = int.tryParse(_orderCtrl.text.trim()) ?? 0;

    if (_isEditMode) {
      // ── EDIT ──
      cubit.updateMenuItem(widget.existingItem!.id, {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'basePrice': price,
        'isVeg': _isVeg,
        'isAvailable': _isAvailable,
        if (_orderCtrl.text.trim().isNotEmpty) 'displayOrder': order,
      });
    } else {
      // ── CREATE ──
      // Payload matches the documented structure:
      // { brandId, branchId, categoryId, name, code, description,
      //   price → basePrice, isVeg, isAvailable, displayOrder }
      cubit.createMenuItems(widget.brandId, [
        {
          'brandId': widget.brandId,
          'branchId': widget.branchId,
          'categoryId': widget.categoryId,
          'name': _nameCtrl.text.trim(),
          'code': _codeCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'basePrice': price,
          'isVeg': _isVeg,
          'isAvailable': _isAvailable,
          'displayOrder': order,
        }
      ]);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final mq = MediaQuery.of(context);

    return BlocListener<CubitMenu, StateMenu>(
      listener: (context, state) {
        if (!_submitted) return; // only react to our own submit
        if (state.status == MenuStatus.loaded) {
          Navigator.pop(context);
          widget.onSuccess();
        } else if (state.status == MenuStatus.error) {
          setState(() => _submitted = false);
          widget.onError(state.errorMessage ?? 'An error occurred');
        }
      },
      child: Container(
        // On wide screens the sheet gets max-width so it doesn't stretch full-width
        margin: EdgeInsets.only(
          left: mq.size.width > 700
              ? (mq.size.width - 620) / 2
              : 0,
          right: mq.size.width > 700
              ? (mq.size.width - 620) / 2
              : 0,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: mq.size.height * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ─────────────────────────────────────────────
            const SizedBox(height: 14),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),

            // ── Sheet header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isEditMode
                          ? Icons.edit_outlined
                          : Icons.add_rounded,
                      color: cs.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditMode ? 'Edit Item' : 'Add New Item',
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _isEditMode
                              ? 'Update the fields below'
                              : 'Fill in details to add to this category',
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            Divider(
              height: 24,
              color: cs.outlineVariant.withOpacity(0.5),
            ),

            // ── Scrollable form ──────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  0,
                  24,
                  mq.viewInsets.bottom + 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Name ──────────────────────────────────────────
                      _FieldLabel('Item Name *'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: _deco('e.g. Paneer Butter Masala',
                            Icons.fastfood_outlined, context),
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Item name is required'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // ── Code + Price row ──────────────────────────────
                      if (!_isEditMode) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Item Code *'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _codeCtrl,
                                    textCapitalization:
                                    TextCapitalization.characters,
                                    decoration: _deco('e.g. PBM001',
                                        Icons.qr_code_outlined, context),
                                    textInputAction: TextInputAction.next,
                                    validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Code required'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Price (₹) *'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _priceCtrl,
                                    keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}'))
                                    ],
                                    decoration: _deco(
                                        'e.g. 250',
                                        Icons.currency_rupee_rounded,
                                        context),
                                    textInputAction: TextInputAction.next,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Price required';
                                      }
                                      if (double.tryParse(v) == null) {
                                        return 'Invalid price';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        // Edit mode: price as full-width field
                        _FieldLabel('Price (₹) *'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _priceCtrl,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'))
                          ],
                          decoration: _deco('e.g. 250',
                              Icons.currency_rupee_rounded, context),
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Price required';
                            }
                            if (double.tryParse(v) == null) {
                              return 'Invalid price';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── Description ───────────────────────────────────
                      _FieldLabel('Description'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descCtrl,
                        minLines: 2,
                        maxLines: 4,
                        decoration: _deco(
                          'e.g. Rich tomato gravy with cottage cheese cubes',
                          Icons.description_outlined,
                          context,
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // ── Display Order ─────────────────────────────────
                      _FieldLabel('Display Order'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _orderCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: _deco(
                          'e.g. 1  (lower = appears first)',
                          Icons.sort_rounded,
                          context,
                        ),
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 20),

                      // ── Toggle section ────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: cs.outlineVariant.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: [
                            _ToggleTile(
                              title: _isVeg ? 'Vegetarian' : 'Non-Vegetarian',
                              subtitle: _isVeg
                                  ? 'No meat, poultry, or seafood'
                                  : 'Contains meat, poultry, or seafood',
                              icon: _isVeg
                                  ? Icons.eco_outlined
                                  : Icons.no_food_outlined,
                              iconColor: _isVeg
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC62828),
                              value: _isVeg,
                              onChanged: (v) => setState(() => _isVeg = v),
                            ),
                            Divider(
                              height: 1,
                              color: cs.outlineVariant.withOpacity(0.4),
                              indent: 16,
                              endIndent: 16,
                            ),
                            _ToggleTile(
                              title: _isAvailable
                                  ? 'Available'
                                  : 'Unavailable',
                              subtitle: _isAvailable
                                  ? 'Customers can see and order this item'
                                  : 'Item is hidden from customers',
                              icon: _isAvailable
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              iconColor: _isAvailable
                                  ? Colors.green.shade700
                                  : cs.onSurfaceVariant,
                              value: _isAvailable,
                              onChanged: (v) =>
                                  setState(() => _isAvailable = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Save button ───────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _submitted ? null : _submit,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _submitted
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isEditMode
                                    ? Icons.save_outlined
                                    : Icons.add_rounded,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isEditMode
                                    ? 'Update Item'
                                    : 'Save Item',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Standardised InputDecoration used throughout the form.
  InputDecoration _deco(
      String hint,
      IconData icon,
      BuildContext context,
      ) {
    final cs = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: cs.outlineVariant),
    );
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18),
      filled: true,
      fillColor: cs.surfaceContainerLowest,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: cs.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form helpers
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyItemsView extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback? onAdd;

  const _EmptyItemsView({required this.isFiltered, this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered
                    ? Icons.manage_search_rounded
                    : Icons.restaurant_menu_outlined,
                size: 44,
                color: cs.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'No results found' : 'No items yet',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try a different search term or clear the filter.'
                  : 'This category has no items. Add your first item to get started.',
              style: tt.bodySmall?.copyWith(color: cs.outline),
              textAlign: TextAlign.center,
            ),
            if (onAdd != null) ...[
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add First Item'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.errorContainer.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, size: 36, color: cs.error),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.error),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
