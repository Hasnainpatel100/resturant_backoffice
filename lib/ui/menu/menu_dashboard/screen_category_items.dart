import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/repositories/menu_repository_impl.dart';
import 'package:back_office/data/repositories/room_type_repository_impl.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/ui/menu/menu_dashboard/cubit_menu.dart';
import 'package:back_office/ui/menu/menu_dashboard/state_menu.dart';
import 'package:back_office/data/models/menu_model.dart';
import 'package:back_office/data/models/room_type_model.dart';

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
    _cubit = CubitMenu(
      repository: MenuRepositoryImpl(),
      roomTypeRepository: RoomTypeRepositoryImpl(),
    );
    _loadItems();
    _cubit.loadRoomTypes(widget.brandId, widget.branchId);
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

  // ── Sheet helpers ──────────────────────────────────────────────────────────

  void _openAddItemSheet() {
    final parentContext = context;
    final roomTypes = _cubit.state.roomTypes;
    showDialog<void>(
      context: parentContext,
      barrierColor: Colors.black54,
      builder: (dialogContext) => BlocProvider.value(
        value: _cubit,
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: Alignment.bottomCenter,
          child: _MenuItemFormSheet(
            brandId: widget.brandId,
            branchId: widget.branchId,
            categoryId: widget.categoryId,
            roomTypes: roomTypes,
            onSuccess: () {
              Navigator.of(dialogContext).pop();
              _showSuccess('Item added successfully');
            },
            onError: _showErrorSnack,
          ),
        ),
      ),
    );
  }

  void _openEditItemSheet(MenuItemResponse item) {
    final parentContext = context;
    final roomTypes = _cubit.state.roomTypes;
    showDialog<void>(
      context: parentContext,
      barrierColor: Colors.black54,
      builder: (dialogContext) => BlocProvider.value(
        value: _cubit,
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: Alignment.bottomCenter,
          child: _MenuItemFormSheet(
            brandId: widget.brandId,
            branchId: widget.branchId,
            categoryId: widget.categoryId,
            existingItem: item,
            roomTypes: roomTypes,
            onSuccess: () {
              Navigator.of(dialogContext).pop();
              _showSuccess('Item updated successfully');
            },
            onError: _showErrorSnack,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(MenuItemResponse item) {
    showDialog<void>(
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
              _cubit.deleteMenuItem(item.id, widget.brandId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openSeeDetailsDialog(MenuItemResponse item) {
    final parentContext = context;
    final roomTypes = _cubit.state.roomTypes;
    showDialog<void>(
      context: parentContext,
      barrierColor: Colors.black54,
      builder: (_) => _MenuItemDetailDialog(
        item: item,
        roomTypes: roomTypes,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            child: CircularProgressIndicator(strokeWidth: 2),
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
                    if (state.status == MenuStatus.loading &&
                        state.menuItems.isEmpty) {
                      return const _LoadingGrid();
                    }

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
                        onAdd: _searchQuery.isNotEmpty ? null : _openAddItemSheet,
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
                              AppSpacing.md + 80,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              mainAxisSpacing: AppSpacing.sm,
                              crossAxisSpacing: AppSpacing.sm,
                              childAspectRatio: cols == 1 ? 3.8 : 2.6,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (_, index) {
                              final item = filtered[index];
                              return _ItemCard(
                                item: item,
                                onEdit: () => _openEditItemSheet(item),
                                onSeeDetails: () => _openSeeDetailsDialog(item),
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
  final VoidCallback onSeeDetails;
  final ValueChanged<bool> onToggle;

  const _ItemCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onSeeDetails,
    required this.onToggle,
  });

  bool get _isVeg {
    final t = item.foodType.toUpperCase();
    if (t.isEmpty) return item.isVeg;
    if (t.contains('NON')) return false;
    return t.contains('VEG');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final vegColor =
        _isVeg ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final vegBg = _isVeg ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final availColor =
        item.isAvailable ? Colors.green.shade700 : Colors.red.shade700;
    final availBg =
        item.isAvailable ? Colors.green.shade50 : Colors.red.shade50;
    final availBorder =
        item.isAvailable ? Colors.green.shade200 : Colors.red.shade200;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      color: cs.surface,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: vegColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                value: _ItemAction.seeDetails,
                                height: 40,
                                child: Row(children: [
                                  Icon(Icons.info_outline_rounded,
                                      size: 16, color: cs.onSurface),
                                  const SizedBox(width: 10),
                                  const Text('See Details'),
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
                              if (a == _ItemAction.seeDetails) onSeeDetails();
                              if (a == _ItemAction.delete) onDelete();
                            },
                          ),
                        ),
                      ],
                    ),
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 26),
                        child: Text(
                          item.description!,
                          style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant, height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: Row(
                        children: [
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
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: vegBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: vegColor.withValues(alpha: 0.3)),
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

enum _ItemAction { edit, seeDetails, delete }

// ─────────────────────────────────────────────────────────────────────────────
// Loading shimmer grid
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
              side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
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
                        _ShimmerBox(width: double.infinity, height: 10, cs: cs),
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
// Add / Edit Item Form — Bottom Sheet  (full API fields)
// ─────────────────────────────────────────────────────────────────────────────

class _MenuItemFormSheet extends StatefulWidget {
  final String brandId;
  final String branchId;
  final String categoryId;
  final MenuItemResponse? existingItem;
  final List<RoomTypeModel> roomTypes;
  final VoidCallback onSuccess;
  final ValueChanged<String> onError;

  const _MenuItemFormSheet({
    required this.brandId,
    required this.branchId,
    required this.categoryId,
    this.existingItem,
    required this.roomTypes,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<_MenuItemFormSheet> createState() => _MenuItemFormSheetState();
}

class _MenuItemFormSheetState extends State<_MenuItemFormSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TabController _tabController;

  // ── Basic info controllers ─────────────────────────────────────────────────
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _taxCtrl;
  late final TextEditingController _orderCtrl;

  // ── Toggles ────────────────────────────────────────────────────────────────
  late bool _isVeg;
  late bool _isAvailable;
  late String _status; // 'ACTIVE' | 'INACTIVE'

  // ── Dynamic sections ───────────────────────────────────────────────────────
  late List<RoomPrice> _roomPrices;
  late List<MenuSize> _sizes;
  late List<MenuModifier> _modifiers;
  late List<String> _images;

  bool _submitted = false;
  bool get _isEditMode => widget.existingItem != null;

  static const _tabs = ['Basic', 'Pricing', 'Variants', 'Modifiers', 'Images'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    final e = widget.existingItem;

    // Basic
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _codeCtrl = TextEditingController(text: e?.code ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _priceCtrl = TextEditingController(
      text: e != null
          ? (e.basePrice % 1 == 0
              ? e.basePrice.toStringAsFixed(0)
              : e.basePrice.toStringAsFixed(2))
          : '',
    );
    _taxCtrl = TextEditingController(
      text: e != null && e.taxPercentage > 0
          ? e.taxPercentage.toStringAsFixed(
              e.taxPercentage % 1 == 0 ? 0 : 1)
          : '',
    );
    _orderCtrl = TextEditingController(
      text: e != null && e.displayOrder > 0 ? e.displayOrder.toString() : '',
    );

    // Toggles
    if (e != null) {
      final t = e.foodType.toUpperCase();
      _isVeg = t.contains('NON') ? false : (t.contains('VEG') ? true : e.isVeg);
    } else {
      _isVeg = true;
    }
    _isAvailable = e?.isAvailable ?? true;
    _status = (e?.status ?? 'ACTIVE').toUpperCase();

    // Dynamic
    _roomPrices = List<RoomPrice>.from(e?.roomPrices ?? []);
    _sizes = List<MenuSize>.from(e?.sizes ?? []);
    _modifiers = List<MenuModifier>.from(e?.modifiers ?? []);
    _images = List<String>.from(e?.images ?? []);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _taxCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0); // jump to Basic on validation error
      return;
    }
    setState(() => _submitted = true);

    final cubit = context.read<CubitMenu>();
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final tax = double.tryParse(_taxCtrl.text.trim()) ?? 0.0;
    final order = int.tryParse(_orderCtrl.text.trim()) ?? 0;
    final desc = _descCtrl.text.trim();

    final payload = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      if (!_isEditMode) 'code': _codeCtrl.text.trim(),
      if (desc.isNotEmpty) 'description': desc,
      'price': price,          // API field name: "price"
      'isVeg': _isVeg,
      'foodType': _isVeg ? 'VEG' : 'NON_VEG',
      'isAvailable': _isAvailable,
      'status': _status,
      if (tax > 0) 'taxPercentage': tax,
      if (order > 0) 'displayOrder': order,
      if (_roomPrices.isNotEmpty)
        'roomPrices': _roomPrices.map((r) => r.toJson()).toList(),
      if (_sizes.isNotEmpty)
        'sizes': _sizes.map((s) => s.toJson()).toList(),
      if (_modifiers.isNotEmpty)
        'modifiers': _modifiers.map((m) => m.toJson()).toList(),
      if (_images.isNotEmpty) 'images': _images,
    };

    if (_isEditMode) {
      cubit.updateMenuItem(widget.existingItem!.id, {
        'brandId': widget.brandId,
        ...payload,
      });
    } else {
      cubit.createMenuItems(widget.brandId, [
        {
          'brandId': widget.brandId,
          'branchId': widget.branchId,
          'categoryId': widget.categoryId,
          ...payload,
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
        if (!_submitted) return;
        if (state.status == MenuStatus.loaded) {
          widget.onSuccess();
        } else if (state.status == MenuStatus.error) {
          setState(() => _submitted = false);
          widget.onError(state.errorMessage ?? 'An error occurred');
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          left: mq.size.width > 700 ? (mq.size.width - 680) / 2 : 0,
          right: mq.size.width > 700 ? (mq.size.width - 680) / 2 : 0,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.94),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ────────────────────────────────────────────────
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isEditMode ? Icons.edit_outlined : Icons.add_rounded,
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

            const SizedBox(height: 10),

            // ── Tab bar ───────────────────────────────────────────────────
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
              indicator: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),

            Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),

            // ── Tab views ─────────────────────────────────────────────────
            Flexible(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _BasicTab(
                      nameCtrl: _nameCtrl,
                      codeCtrl: _codeCtrl,
                      descCtrl: _descCtrl,
                      taxCtrl: _taxCtrl,
                      orderCtrl: _orderCtrl,
                      isEditMode: _isEditMode,
                      isVeg: _isVeg,
                      isAvailable: _isAvailable,
                      status: _status,
                      onVegChanged: (v) => setState(() => _isVeg = v),
                      onAvailableChanged: (v) =>
                          setState(() => _isAvailable = v),
                      onStatusChanged: (v) => setState(() => _status = v!),
                    ),
                    _PricingTab(
                      priceCtrl: _priceCtrl,
                      roomPrices: _roomPrices,
                      roomTypes: widget.roomTypes,
                      onRoomPricesChanged: (list) =>
                          setState(() => _roomPrices = list),
                    ),
                    _SizesTab(
                      sizes: _sizes,
                      onChanged: (list) => setState(() => _sizes = list),
                    ),
                    _ModifiersTab(
                      modifiers: _modifiers,
                      onChanged: (list) => setState(() => _modifiers = list),
                    ),
                    _ImagesTab(
                      images: _images,
                      onChanged: (list) => setState(() => _images = list),
                    ),
                  ],
                ),
              ),
            ),

            // ── Save button ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 12, 20, mq.viewInsets.bottom + 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _submitted ? null : _submit,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _submitted
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
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
                              _isEditMode ? 'Update Item' : 'Save Item',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — Basic Info
// ─────────────────────────────────────────────────────────────────────────────

class _BasicTab extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController codeCtrl;
  final TextEditingController descCtrl;
  final TextEditingController taxCtrl;
  final TextEditingController orderCtrl;
  final bool isEditMode;
  final bool isVeg;
  final bool isAvailable;
  final String status;
  final ValueChanged<bool> onVegChanged;
  final ValueChanged<bool> onAvailableChanged;
  final ValueChanged<String?> onStatusChanged;

  const _BasicTab({
    required this.nameCtrl,
    required this.codeCtrl,
    required this.descCtrl,
    required this.taxCtrl,
    required this.orderCtrl,
    required this.isEditMode,
    required this.isVeg,
    required this.isAvailable,
    required this.status,
    required this.onVegChanged,
    required this.onAvailableChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          _FieldLabel('Item Name *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: _deco('e.g. Paneer Butter Masala',
                Icons.fastfood_outlined, context),
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Item name is required'
                : null,
          ),
          const SizedBox(height: 14),

          // Code (create only)
          if (!isEditMode) ...[
            _FieldLabel('Item Code *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration:
                  _deco('e.g. PBM001', Icons.qr_code_outlined, context),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Code is required' : null,
            ),
            const SizedBox(height: 14),
          ],

          // Description
          _FieldLabel('Description'),
          const SizedBox(height: 6),
          TextFormField(
            controller: descCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: _deco(
              'e.g. Rich tomato gravy with cottage cheese cubes',
              Icons.description_outlined,
              context,
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),

          // Tax + Order row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Tax %'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: taxCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                      decoration: _deco('e.g. 5', Icons.percent_rounded, context),
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Display Order'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: orderCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: _deco('e.g. 1', Icons.sort_rounded, context),
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status dropdown
          _FieldLabel('Status'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: ['ACTIVE', 'INACTIVE'].contains(status.toUpperCase())
                ? status.toUpperCase()
                : 'ACTIVE',
            decoration: _deco('', Icons.toggle_on_outlined, context),
            items: const [
              DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
              DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
            ],
            onChanged: onStatusChanged,
          ),
          const SizedBox(height: 16),

          // Toggles card
          _TogglesCard(
            isVeg: isVeg,
            isAvailable: isAvailable,
            onVegChanged: onVegChanged,
            onAvailableChanged: onAvailableChanged,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — Pricing (base price + room prices)
// ─────────────────────────────────────────────────────────────────────────────

class _PricingTab extends StatelessWidget {
  final TextEditingController priceCtrl;
  final List<RoomPrice> roomPrices;
  final List<RoomTypeModel> roomTypes;
  final ValueChanged<List<RoomPrice>> onRoomPricesChanged;

  const _PricingTab({
    required this.priceCtrl,
    required this.roomPrices,
    required this.roomTypes,
    required this.onRoomPricesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Base price
          _FieldLabel('Base Price (₹) *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: priceCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
            ],
            decoration:
                _deco('e.g. 250', Icons.currency_rupee_rounded, context),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Price is required';
              if (double.tryParse(v) == null) return 'Invalid price';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Room prices header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Room Type Prices',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Override price per room type',
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: roomTypes.isEmpty
                    ? null
                    : () {
                        final usedIds =
                            roomPrices.map((r) => r.roomTypeId).toSet();
                        final available = roomTypes
                            .where((rt) => !usedIds.contains(rt.id))
                            .toList();
                        if (available.isEmpty) return;
                        onRoomPricesChanged([
                          ...roomPrices,
                          RoomPrice(
                              roomTypeId: available.first.id, price: 0.0),
                        ]);
                      },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 4),
                    Text('Add'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (roomTypes.isEmpty)
            _InfoBanner(
                text: 'No room types found. Create room types first.',
                icon: Icons.info_outline,
                cs: cs)
          else if (roomPrices.isEmpty)
            _InfoBanner(
                text: 'No room-specific pricing. Tap Add to override.',
                icon: Icons.hotel_outlined,
                cs: cs)
          else
            ...roomPrices.asMap().entries.map((entry) {
              final idx = entry.key;
              final rp = entry.value;
              return _RoomPriceRow(
                key: ValueKey('rp_$idx'),
                roomPrice: rp,
                roomTypes: roomTypes,
                usedIds: roomPrices
                    .where((r) => r.roomTypeId != rp.roomTypeId)
                    .map((r) => r.roomTypeId)
                    .toSet(),
                onChanged: (updated) {
                  final list = List<RoomPrice>.from(roomPrices);
                  list[idx] = updated;
                  onRoomPricesChanged(list);
                },
                onDelete: () {
                  final list = List<RoomPrice>.from(roomPrices)
                    ..removeAt(idx);
                  onRoomPricesChanged(list);
                },
              );
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _RoomPriceRow extends StatefulWidget {
  final RoomPrice roomPrice;
  final List<RoomTypeModel> roomTypes;
  final Set<String> usedIds;
  final ValueChanged<RoomPrice> onChanged;
  final VoidCallback onDelete;

  const _RoomPriceRow({
    super.key,
    required this.roomPrice,
    required this.roomTypes,
    required this.usedIds,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_RoomPriceRow> createState() => _RoomPriceRowState();
}

class _RoomPriceRowState extends State<_RoomPriceRow> {
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(
      text: widget.roomPrice.price > 0
          ? widget.roomPrice.price.toStringAsFixed(
              widget.roomPrice.price % 1 == 0 ? 0 : 2)
          : '',
    );
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final allowedTypes = widget.roomTypes
        .where((rt) =>
            rt.id == widget.roomPrice.roomTypeId ||
            !widget.usedIds.contains(rt.id))
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: widget.roomPrice.roomTypeId,
              decoration: InputDecoration(
                labelText: 'Room Type',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                isDense: true,
              ),
              items: allowedTypes
                  .map((rt) => DropdownMenuItem(
                      value: rt.id, child: Text(rt.name)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  widget.onChanged(
                      widget.roomPrice.copyWith(roomTypeId: val));
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: _priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}'))
              ],
              decoration: InputDecoration(
                labelText: '₹ Price',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                isDense: true,
              ),
              onChanged: (val) {
                final p = double.tryParse(val) ?? 0.0;
                widget.onChanged(widget.roomPrice.copyWith(price: p));
              },
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon:
                Icon(Icons.delete_outline, size: 20, color: cs.error),
            onPressed: widget.onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — Sizes
// ─────────────────────────────────────────────────────────────────────────────

class _SizesTab extends StatelessWidget {
  final List<MenuSize> sizes;
  final ValueChanged<List<MenuSize>> onChanged;

  const _SizesTab({required this.sizes, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Size Variants',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text('e.g. Half / Full with different prices',
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: () =>
                    onChanged([...sizes, const MenuSize(name: '', price: 0)]),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 4),
                    Text('Add Size'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sizes.isEmpty)
            _InfoBanner(
                text: 'No size variants. Tap Add Size to create one.',
                icon: Icons.straighten_outlined,
                cs: cs)
          else
            ...sizes.asMap().entries.map((e) => _SizeRow(
                  key: ValueKey('size_${e.key}'),
                  size: e.value,
                  onChanged: (updated) {
                    final list = List<MenuSize>.from(sizes);
                    list[e.key] = updated;
                    onChanged(list);
                  },
                  onDelete: () {
                    final list = List<MenuSize>.from(sizes)
                      ..removeAt(e.key);
                    onChanged(list);
                  },
                )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SizeRow extends StatefulWidget {
  final MenuSize size;
  final ValueChanged<MenuSize> onChanged;
  final VoidCallback onDelete;

  const _SizeRow({
    super.key,
    required this.size,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_SizeRow> createState() => _SizeRowState();
}

class _SizeRowState extends State<_SizeRow> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.size.name);
    _priceCtrl = TextEditingController(
      text: widget.size.price > 0
          ? widget.size.price.toStringAsFixed(
              widget.size.price % 1 == 0 ? 0 : 2)
          : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Size Name',
                hintText: 'e.g. Half',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                isDense: true,
              ),
              onChanged: (v) =>
                  widget.onChanged(widget.size.copyWith(name: v)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: _priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}'))
              ],
              decoration: InputDecoration(
                labelText: '₹ Price',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                isDense: true,
              ),
              onChanged: (v) => widget.onChanged(
                  widget.size.copyWith(price: double.tryParse(v) ?? 0.0)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 20, color: cs.error),
            onPressed: widget.onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 4 — Modifiers
// ─────────────────────────────────────────────────────────────────────────────

class _ModifiersTab extends StatelessWidget {
  final List<MenuModifier> modifiers;
  final ValueChanged<List<MenuModifier>> onChanged;

  const _ModifiersTab({required this.modifiers, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Modifier Groups',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text('e.g. Spice Level, Add-ons',
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: () => onChanged([
                  ...modifiers,
                  const MenuModifier(name: '', min: 0, max: 1, options: []),
                ]),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 4),
                    Text('Add Group'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (modifiers.isEmpty)
            _InfoBanner(
                text: 'No modifier groups. Tap Add Group to create one.',
                icon: Icons.tune_outlined,
                cs: cs)
          else
            ...modifiers.asMap().entries.map((e) => _ModifierGroupCard(
                  key: ValueKey('mod_${e.key}'),
                  modifier: e.value,
                  onChanged: (updated) {
                    final list = List<MenuModifier>.from(modifiers);
                    list[e.key] = updated;
                    onChanged(list);
                  },
                  onDelete: () {
                    final list = List<MenuModifier>.from(modifiers)
                      ..removeAt(e.key);
                    onChanged(list);
                  },
                )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ModifierGroupCard extends StatefulWidget {
  final MenuModifier modifier;
  final ValueChanged<MenuModifier> onChanged;
  final VoidCallback onDelete;

  const _ModifierGroupCard({
    super.key,
    required this.modifier,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_ModifierGroupCard> createState() => _ModifierGroupCardState();
}

class _ModifierGroupCardState extends State<_ModifierGroupCard> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.modifier.name);
    _minCtrl = TextEditingController(text: widget.modifier.min.toString());
    _maxCtrl = TextEditingController(text: widget.modifier.max.toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final m = widget.modifier;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 0),
            child: Row(
              children: [
                Icon(Icons.tune_outlined,
                    size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      hintText: 'e.g. Spice Level',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      isDense: true,
                    ),
                    onChanged: (v) =>
                        widget.onChanged(m.copyWith(name: v)),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      size: 20, color: cs.error),
                  onPressed: widget.onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Min / Max row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Min selections',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      isDense: true,
                    ),
                    onChanged: (v) => widget.onChanged(
                        m.copyWith(min: int.tryParse(v) ?? 0)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _maxCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Max selections',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      isDense: true,
                    ),
                    onChanged: (v) => widget.onChanged(
                        m.copyWith(max: int.tryParse(v) ?? 1)),
                  ),
                ),
              ],
            ),
          ),

          // Options
          Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.4),
              indent: 12,
              endIndent: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Text('Options',
                    style: tt.labelSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    final opts = [...m.options,
                      const ModifierOption(name: '', price: 0)];
                    widget.onChanged(m.copyWith(options: opts));
                  },
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Option'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          if (m.options.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Text('No options yet. Tap Add Option.',
                  style: tt.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                children: m.options.asMap().entries.map((oe) {
                  return _ModifierOptionRow(
                    key: ValueKey('opt_${oe.key}'),
                    option: oe.value,
                    onChanged: (updated) {
                      final opts = List<ModifierOption>.from(m.options);
                      opts[oe.key] = updated;
                      widget.onChanged(m.copyWith(options: opts));
                    },
                    onDelete: () {
                      final opts = List<ModifierOption>.from(m.options)
                        ..removeAt(oe.key);
                      widget.onChanged(m.copyWith(options: opts));
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModifierOptionRow extends StatefulWidget {
  final ModifierOption option;
  final ValueChanged<ModifierOption> onChanged;
  final VoidCallback onDelete;

  const _ModifierOptionRow({
    super.key,
    required this.option,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_ModifierOptionRow> createState() => _ModifierOptionRowState();
}

class _ModifierOptionRowState extends State<_ModifierOptionRow> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.option.name);
    _priceCtrl = TextEditingController(
      text: widget.option.price > 0
          ? widget.option.price.toStringAsFixed(
              widget.option.price % 1 == 0 ? 0 : 2)
          : '0',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'e.g. Mild',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                isDense: true,
              ),
              onChanged: (v) =>
                  widget.onChanged(widget.option.copyWith(name: v)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: TextFormField(
              controller: _priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}'))
              ],
              decoration: InputDecoration(
                hintText: '₹ 0',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                isDense: true,
              ),
              onChanged: (v) => widget.onChanged(widget.option
                  .copyWith(price: double.tryParse(v) ?? 0.0)),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, size: 18, color: cs.error),
          onPressed: widget.onDelete,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.only(bottom: 6),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 5 — Images
// ─────────────────────────────────────────────────────────────────────────────

class _ImagesTab extends StatelessWidget {
  final List<String> images;
  final ValueChanged<List<String>> onChanged;

  const _ImagesTab({required this.images, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Image URLs',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Add one or more image links for this item',
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: () => onChanged([...images, '']),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 4),
                    Text('Add URL'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (images.isEmpty)
            _InfoBanner(
                text: 'No images added. Tap Add URL to add image links.',
                icon: Icons.image_outlined,
                cs: cs)
          else
            ...images.asMap().entries.map((e) => _ImageUrlRow(
                  key: ValueKey('img_${e.key}'),
                  url: e.value,
                  index: e.key + 1,
                  onChanged: (updated) {
                    final list = List<String>.from(images);
                    list[e.key] = updated;
                    onChanged(list);
                  },
                  onDelete: () {
                    final list = List<String>.from(images)
                      ..removeAt(e.key);
                    onChanged(list);
                  },
                )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ImageUrlRow extends StatefulWidget {
  final String url;
  final int index;
  final ValueChanged<String> onChanged;
  final VoidCallback onDelete;

  const _ImageUrlRow({
    super.key,
    required this.url,
    required this.index,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_ImageUrlRow> createState() => _ImageUrlRowState();
}

class _ImageUrlRowState extends State<_ImageUrlRow> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.url);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${widget.index}',
                style: TextStyle(
                    color: cs.onPrimaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: _ctrl,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: 'https://cdn.example.com/image.jpg',
                prefixIcon: const Icon(Icons.link, size: 18),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                isDense: true,
              ),
              onChanged: widget.onChanged,
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final uri = Uri.tryParse(v);
                  if (uri == null || !uri.hasScheme) {
                    return 'Enter a valid URL';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 20, color: cs.error),
            onPressed: widget.onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _TogglesCard extends StatelessWidget {
  final bool isVeg;
  final bool isAvailable;
  final ValueChanged<bool> onVegChanged;
  final ValueChanged<bool> onAvailableChanged;

  const _TogglesCard({
    required this.isVeg,
    required this.isAvailable,
    required this.onVegChanged,
    required this.onAvailableChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _ToggleTile(
            title: isVeg ? 'Vegetarian' : 'Non-Vegetarian',
            subtitle: isVeg
                ? 'No meat, poultry, or seafood'
                : 'Contains meat, poultry, or seafood',
            icon: isVeg ? Icons.eco_outlined : Icons.no_food_outlined,
            iconColor:
                isVeg ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
            value: isVeg,
            onChanged: onVegChanged,
          ),
          Divider(
            height: 1,
            color: cs.outlineVariant.withValues(alpha: 0.4),
            indent: 16,
            endIndent: 16,
          ),
          _ToggleTile(
            title: isAvailable ? 'Available' : 'Unavailable',
            subtitle: isAvailable
                ? 'Customers can see and order this item'
                : 'Item is hidden from customers',
            icon: isAvailable
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            iconColor: isAvailable
                ? Colors.green.shade700
                : cs.onSurfaceVariant,
            value: isAvailable,
            onChanged: onAvailableChanged,
          ),
        ],
      ),
    );
  }
}

InputDecoration _deco(String hint, IconData icon, BuildContext context) {
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
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        )),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  final IconData icon;
  final ColorScheme cs;

  const _InfoBanner(
      {required this.text, required this.icon, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
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
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered
                    ? Icons.manage_search_rounded
                    : Icons.restaurant_menu_outlined,
                size: 44,
                color: cs.primary.withValues(alpha: 0.7),
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
                color: cs.errorContainer.withValues(alpha: 0.4),
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

class _MenuItemDetailDialog extends StatelessWidget {
  final MenuItemResponse item;
  final List<RoomTypeModel> roomTypes;

  const _MenuItemDetailDialog({
    required this.item,
    required this.roomTypes,
  });

  String _getRoomTypeName(String id) {
    final rt = roomTypes.firstWhere(
      (r) => r.id == id,
      orElse: () => RoomTypeModel(
        id: '',
        brandId: '',
        branchId: '',
        name: 'Unknown',
        createdAt: 0,
        createdBy: '',
      ),
    );
    return rt.name;
  }

  bool get _isVeg {
    final t = item.foodType.toUpperCase();
    if (t.isEmpty) return item.isVeg;
    if (t.contains('NON')) return false;
    return t.contains('VEG');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final vegColor = _isVeg ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final vegBg = _isVeg ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 650),
        child: Column(
          children: [
            // Title Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (item.code != null && item.code!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Code: ${item.code}',
                            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section (if present)
                    if (item.images.isNotEmpty) ...[
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: item.images.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, idx) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.images[idx],
                                height: 180,
                                width: 260,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 260,
                                  color: cs.surfaceContainerLow,
                                  child: Icon(Icons.broken_image, color: cs.onSurfaceVariant),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Description Section
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      _buildSectionTitle('Description', Icons.description_outlined, cs, tt),
                      const SizedBox(height: 8),
                      Text(
                        item.description!,
                        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Basic Details Grid
                    _buildSectionTitle('Basic Details', Icons.info_outline, cs, tt),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Veg / Non-Veg', Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: vegBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _isVeg ? 'Veg' : 'Non-Veg',
                              style: tt.labelSmall?.copyWith(color: vegColor, fontWeight: FontWeight.bold),
                            ),
                          ), cs, tt),
                          const Divider(),
                          _buildDetailRow('Availability', Text(
                            item.isAvailable ? 'Available' : 'Unavailable',
                            style: tt.bodyMedium?.copyWith(
                              color: item.isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ), cs, tt),
                          const Divider(),
                          _buildDetailRow('Status', Text(
                            item.status,
                            style: tt.bodyMedium?.copyWith(
                              color: item.status == 'ACTIVE' ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ), cs, tt),
                          const Divider(),
                          _buildDetailRow('Tax Rate', Text('${item.taxPercentage}%'), cs, tt),
                          const Divider(),
                          _buildDetailRow('Display Order', Text(item.displayOrder.toString()), cs, tt),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Pricing Section
                    _buildSectionTitle('Pricing & Overrides', Icons.payments_outlined, cs, tt),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Base Price',
                            Text(
                              '${item.currency} ${item.basePrice.toStringAsFixed(2)}',
                              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
                            ),
                            cs,
                            tt,
                          ),
                          if (item.roomPrices.isNotEmpty) ...[
                            const Divider(),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Room Type Pricing:',
                                style: tt.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurfaceVariant),
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...item.roomPrices.map((rp) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: _buildDetailRow(
                                  _getRoomTypeName(rp.roomTypeId),
                                  Text('${item.currency} ${rp.price.toStringAsFixed(2)}'),
                                  cs,
                                  tt,
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sizes Section
                    if (item.sizes.isNotEmpty) ...[
                      _buildSectionTitle('Sizes & Pricing', Icons.straighten_outlined, cs, tt),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: item.sizes.map((s) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: _buildDetailRow(
                                s.name,
                                Text('${item.currency} ${s.price.toStringAsFixed(2)}', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                cs,
                                tt,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Modifiers Section
                    if (item.modifiers.isNotEmpty) ...[
                      _buildSectionTitle('Modifiers', Icons.tune_outlined, cs, tt),
                      const SizedBox(height: 8),
                      ...item.modifiers.map((m) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          color: cs.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(m.name, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: cs.secondaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Min: ${m.min} / Max: ${m.max}',
                                        style: tt.labelSmall?.copyWith(color: cs.onSecondaryContainer),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),
                                ...m.options.map((opt) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(opt.name, style: tt.bodyMedium),
                                        Text('+${item.currency} ${opt.price.toStringAsFixed(2)}', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String label, IconData icon, ColorScheme cs, TextTheme tt) {
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, Widget valueWidget, ColorScheme cs, TextTheme tt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        valueWidget,
      ],
    );
  }
}
