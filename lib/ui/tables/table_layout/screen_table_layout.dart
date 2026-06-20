import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/models/table_model.dart';
import 'package:back_office/data/repositories/table_repository_impl.dart';
import 'package:back_office/data/repositories/branch_repository_impl.dart';
import 'package:back_office/ui/tables/table_layout/cubit_table.dart';
import 'package:back_office/ui/tables/table_layout/state_table.dart';
import 'package:back_office/ui/branch/branch_list/cubit_branch.dart';
import 'package:back_office/ui/branch/branch_list/state_branch.dart';

import '../../../data/models/room_type_model.dart';
import '../../../data/repositories/room_type_repository_impl.dart';
import '../../../services/table_import_service.dart';

// ---------------------------------------------------------------------------
// ScreenTableLayout
// ---------------------------------------------------------------------------

class ScreenTableLayout extends StatefulWidget {
  final String brandId;
  final String? branchId;

  const ScreenTableLayout({super.key, required this.brandId, this.branchId});

  @override
  State<ScreenTableLayout> createState() => _ScreenTableLayoutState();
}

class _ScreenTableLayoutState extends State<ScreenTableLayout> {
  late String? _selectedBranchId = widget.branchId;

  /// Full list of room types for the selected branch.
  List<RoomTypeModel> _roomTypes = [];
  bool _roomTypesLoading = false;

  /// Case-insensitive lookup: trimmed-lower-name → Mongo ObjectId.
  /// Built once after [_roomTypes] is loaded and reused by every import.
  Map<String, String> _roomTypeNameToId = {};

  CubitTable? _cubitTable;

  // Services
  final _importService = TableImportService();
  final _exportService = TableExportService();

  // Loading state flags for button indicators
  bool _isImporting = false;
  bool _isDownloading = false;

  void _initTableCubit(String branchId) {
    _cubitTable?.close();
    _cubitTable = CubitTable(repository: TableRepositoryImpl())
      ..loadTables(widget.brandId, branchId);
  }

  @override
  void initState() {
    super.initState();
    if (_selectedBranchId != null) {
      _cubitTable = CubitTable(repository: TableRepositoryImpl())
        ..loadTables(widget.brandId, _selectedBranchId!);
      _loadRoomTypes();
    }
  }

  @override
  void dispose() {
    _cubitTable?.close();
    super.dispose();
  }

  // ── Room types ─────────────────────────────────────────────────────────────

  Future<void> _loadRoomTypes() async {
    if (_selectedBranchId == null) return;
    // Always refresh when the branch changes (list cleared on branch switch).
    if (_roomTypes.isNotEmpty) return;

    setState(() => _roomTypesLoading = true);

    final result = await RoomTypeRepositoryImpl()
        .getRoomTypes(widget.brandId, _selectedBranchId!);

    result.fold(
          (failure) {
        debugPrint('RoomType load error: ${failure.message}');
        setState(() => _roomTypesLoading = false);
      },
          (response) {
        // Build the lookup map: lower-cased name → Mongo ID.
        final nameToId = <String, String>{
          for (final rt in response.items) rt.name.trim().toLowerCase(): rt.id,
        };

        setState(() {
          _roomTypes = response.items;
          _roomTypeNameToId = nameToId;
          _roomTypesLoading = false;
        });
      },
    );
  }

  // ── Upload (Import) ────────────────────────────────────────────────────────

  Future<void> _handleUpload(BuildContext context) async {
    if (_selectedBranchId == null) {
      _showBranchRequired(context);
      return;
    }

    // Make sure room types are available before opening the file picker.
    // If they haven't loaded yet, wait for them now.
    if (_roomTypes.isEmpty && !_roomTypesLoading) {
      await _loadRoomTypes();
    }

    if (!mounted) return;

    // If room types are still loading, block the import with a user-facing message.
    if (_roomTypesLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Room types are still loading. Please try again in a moment.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange.shade700,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => _isImporting = true);

    TableImportResult? result;
    try {
      // Pass the pre-built lookup map so the parser can resolve names → IDs
      // without any extra async calls.
      result = await _importService.pickAndParse(
        roomTypeNameToId: _roomTypeNameToId,
      );
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }

    if (result == null || !mounted) return; // user cancelled

    // Show preview dialog
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ImportPreviewDialog(
        result: result!,
        onConfirm: () => _submitImport(context, result!),
      ),
    );
  }

  void _submitImport(BuildContext context, TableImportResult result) {
    if (_cubitTable == null) return;

    // toApiMap() now includes roomTypeId (the resolved Mongo ObjectId).
    final rows = result.rows
        .map((r) => r.toApiMap(
      brandId: widget.brandId,
      branchId: _selectedBranchId!,
    ))
        .toList();

    _cubitTable!.createTables(widget.brandId, rows);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${result.rows.length} table${result.rows.length == 1 ? '' : 's'} '
              'imported successfully.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ── Download Format ────────────────────────────────────────────────────────

  Future<void> _handleDownloadFormat(BuildContext context) async {
    setState(() => _isDownloading = true);

    bool success = false;
    try {
      success = await _exportService.downloadTemplate();
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Template downloaded to your Downloads folder.'
              : 'Download failed. Please try again.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ── Bulk numbering helper ────────────────────────────────────────────────

  /// Returns the next available numeric suffix for [prefix], based on the
  /// currently loaded tables in `_cubitTable.state.tables`.
  /// e.g. if A1..A5 exist, returns 6. If no matching tables exist, returns 1.
  int _nextNumberForPrefix(String prefix) {
    final tables = _cubitTable?.state.tables ?? [];
    final regex = RegExp('^${RegExp.escape(prefix)}(\\d+)\$');

    int maxSuffix = 0;
    for (final t in tables) {
      final match = regex.firstMatch(t.tableNumber);
      if (match == null) continue;
      final n = int.tryParse(match.group(1)!) ?? 0;
      if (n > maxSuffix) maxSuffix = n;
    }
    return maxSuffix + 1;
  }

  // ── Add Table dialog ───────────────────────────────────────────────────────

  void _showAddTableDialog(BuildContext context) {
    if (_selectedBranchId == null) {
      _showBranchRequired(context);
      return;
    }

    final tableNumberController = TextEditingController();
    final displayNameController = TextEditingController();
    final capacityController = TextEditingController(text: '4');
    final bulkCountController = TextEditingController(text: '5');
    String? selectedRoomTypeId;
    bool isBulk = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Add Table'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bulk toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bulk Add',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Switch(
                        value: isBulk,
                        onChanged: (val) =>
                            setDialogState(() => isBulk = val),
                      ),
                    ],
                  ),
                  const Divider(height: 8),
                  const SizedBox(height: 8),

                  if (!isBulk) ...[
                    TextField(
                      controller: tableNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Table Number *',
                        hintText: 'e.g. T01',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        hintText: 'e.g. Window Table',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: tableNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Table Number Prefix *',
                        hintText: 'e.g. "T" → T1, T2, T3…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bulkCountController,
                      decoration: const InputDecoration(
                        labelText: 'Number of Tables *',
                        hintText: 'e.g. 10',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],

                  const SizedBox(height: 12),

                  TextField(
                    controller: capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacity *',
                      hintText: 'e.g. 4',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Room Type *',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedRoomTypeId,
                    items: _roomTypes.map((room) {
                      return DropdownMenuItem(
                          value: room.id, child: Text(room.name));
                    }).toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedRoomTypeId = value),
                  ),

                  if (_roomTypesLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (_roomTypes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'No room types found. Please add a room type first.',
                        style: TextStyle(fontSize: 11, color: Colors.orange),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final prefix = tableNumberController.text.trim();
                  final capacity =
                      int.tryParse(capacityController.text) ?? 4;

                  if (prefix.isEmpty || selectedRoomTypeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Table number and room type are required.'),
                      ),
                    );
                    return;
                  }

                  List<Map<String, dynamic>> tables;

                  if (isBulk) {
                    final count =
                        int.tryParse(bulkCountController.text) ?? 1;
                    if (count < 1) return;

                    // ✅ Auto-continue numbering: find the highest existing
                    // numeric suffix for this prefix and start after it,
                    // instead of always restarting at 1 (which caused dupes).
                    final startNumber = _nextNumberForPrefix(prefix);

                    tables = List.generate(
                      count,
                          (i) {
                        final number = startNumber + i;
                        return {
                          'tableNumber': '$prefix$number',
                          'displayName': '$prefix$number',
                          'capacity': capacity,
                          'branchId': _selectedBranchId,
                          'roomTypeId': selectedRoomTypeId,
                        };
                      },
                    );
                  } else {
                    final displayName =
                    displayNameController.text.trim();
                    tables = [
                      {
                        'tableNumber': prefix,
                        'displayName': displayName.isNotEmpty
                            ? displayName
                            : prefix,
                        'capacity': capacity,
                        'branchId': _selectedBranchId,
                        'roomTypeId': selectedRoomTypeId,
                      }
                    ];
                  }

                  debugPrint('TABLES SENT: $tables');
                  _cubitTable?.createTables(widget.brandId, tables);
                  debugPrint('TABLES SENT: $tables');
                  Navigator.pop(dialogContext);
                },
                child: Text(isBulk ? 'Add Tables' : 'Add Table'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Helper dialogs ─────────────────────────────────────────────────────────

  void _showBranchRequired(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Branch Required'),
        content:
        const Text('Please select a branch before managing tables.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CubitBranch(repository: BranchRepositoryImpl())
            ..loadBranches(widget.brandId),
        ),
        if (_cubitTable != null)
          BlocProvider<CubitTable>.value(value: _cubitTable!),
      ],
      child: _TableLayoutBody(
        brandId: widget.brandId,
        selectedBranchId: _selectedBranchId,
        hasCubitTable: _cubitTable != null,
        isImporting: _isImporting,
        isDownloading: _isDownloading,
        onBranchSelected: (branchId) {
          setState(() {
            _selectedBranchId = branchId;
            // Clear room types so they are re-fetched for the new branch.
            _roomTypes = [];
            _roomTypeNameToId = {};
            _initTableCubit(branchId);
          });
          _loadRoomTypes();
        },
        onAddTable: _showAddTableDialog,
        onUpload: _handleUpload,
        onDownloadFormat: _handleDownloadFormat,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TableLayoutBody
// ---------------------------------------------------------------------------

class _TableLayoutBody extends StatelessWidget {
  final String brandId;
  final String? selectedBranchId;
  final bool hasCubitTable;
  final bool isImporting;
  final bool isDownloading;
  final ValueChanged<String> onBranchSelected;
  final void Function(BuildContext context) onAddTable;
  final void Function(BuildContext context) onUpload;
  final void Function(BuildContext context) onDownloadFormat;

  const _TableLayoutBody({
    required this.brandId,
    this.selectedBranchId,
    required this.hasCubitTable,
    required this.isImporting,
    required this.isDownloading,
    required this.onBranchSelected,
    required this.onAddTable,
    required this.onUpload,
    required this.onDownloadFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Layout'),
        actions: [
          // ── Download Format button ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _HeaderButton(
              label: isDownloading ? 'Downloading…' : 'Download Format',
              icon: isDownloading
                  ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download_rounded),
              outlined: true,
              disabled: isDownloading,
              onPressed: () => onDownloadFormat(context),
            ),
          ),
          // ── Upload button ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _HeaderButton(
              label: isImporting ? 'Importing…' : 'Upload',
              icon: isImporting
                  ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.upload_rounded),
              outlined: true,
              disabled: isImporting,
              onPressed: () => onUpload(context),
            ),
          ),
          // ── Add Table button ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _HeaderButton(
              label: 'Add Table',
              icon: const Icon(Icons.add_rounded, size: 18),
              outlined: false,
              onPressed: () => onAddTable(context),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),

      // ── Body ───────────────────────────────────────────────────────────────
      body: Column(
        children: [
          if (selectedBranchId == null)
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: BlocBuilder<CubitBranch, StateBranch>(
                builder: (context, branchState) {
                  if (branchState.status == BranchStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (branchState.branches.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          'No branches found',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    decoration:
                    const InputDecoration(labelText: 'Branch'),
                    hint: const Text('Select branch'),
                    items: branchState.branches.map((b) {
                      return DropdownMenuItem(
                          value: b.id, child: Text(b.displayName));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) onBranchSelected(value);
                    },
                  );
                },
              ),
            )
          else if (hasCubitTable)
            Expanded(
              child: BlocBuilder<CubitTable, StateTable>(
                builder: (context, state) {
                  if (state.status == StateTableStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          SizedBox(height: AppSpacing.md),
                          Text(state.errorMessage ?? 'An error occurred'),
                          SizedBox(height: AppSpacing.md),
                          ElevatedButton(
                            onPressed: () => context
                                .read<CubitTable>()
                                .loadTables(brandId, selectedBranchId!),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.status == StateTableStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.tables.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.table_restaurant_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          SizedBox(height: AppSpacing.md),
                          const Text('No tables configured'),
                          SizedBox(height: AppSpacing.md),
                          ElevatedButton.icon(
                            onPressed: () => onAddTable(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Table'),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(AppSpacing.md),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _crossAxisCount(context),
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                    ),
                    itemCount: state.tables.length,
                    itemBuilder: (context, index) {
                      final table = state.tables[index];
                      return _TableCard(
                        table: table,
                        onEdit: () =>
                            _showEditTableDialog(context, table),
                        onDelete: () => context
                            .read<CubitTable>()
                            .deleteTable(table.id),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  int _crossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 6;
    if (width > 900) return 5;
    if (width > 600) return 4;
    return 3;
  }

  void _showEditTableDialog(BuildContext context, TableModel table) {
    final displayNameController =
    TextEditingController(text: table.displayName);
    final capacityController =
    TextEditingController(text: table.capacity.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Table ${table.tableNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CubitTable>().updateTable(table.id, {
                'displayName': displayNameController.text,
                'capacity':
                int.tryParse(capacityController.text) ?? table.capacity,
                'tableNumber': table.tableNumber,
                'brandId': table.brandId,
                'branchId': table.branchId,
                'roomTypeId': table.roomTypeId,
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _HeaderButton  – compact desktop-style AppBar action button
// ---------------------------------------------------------------------------

class _HeaderButton extends StatefulWidget {
  final String label;
  final Widget icon;
  final bool outlined;
  final bool disabled;
  final VoidCallback onPressed;

  const _HeaderButton({
    required this.label,
    required this.icon,
    required this.outlined,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // ── Outlined style (Upload / Download Format) ──────────────────────────
    if (widget.outlined) {
      return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hovered && !widget.disabled
                ? colorScheme.surfaceContainerHighest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.disabled
                  ? colorScheme.outline.withOpacity(0.35)
                  : colorScheme.outline.withOpacity(0.6),
            ),
          ),
          child: InkWell(
            onTap: widget.disabled ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                    data: IconThemeData(
                      color: widget.disabled
                          ? colorScheme.onSurface.withOpacity(0.38)
                          : colorScheme.onSurface,
                      size: 18,
                    ),
                    child: widget.icon,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: widget.disabled
                          ? colorScheme.onSurface.withOpacity(0.38)
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── Filled / primary style (Add Table) ────────────────────────────────
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _hovered
              ? colorScheme.primary.withOpacity(0.88)
              : colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: _hovered
              ? [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.28),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ]
              : [],
        ),
        child: InkWell(
          onTap: widget.disabled ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTheme(
                  data: IconThemeData(
                      color: colorScheme.onPrimary, size: 18),
                  child: widget.icon,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TableCard  – unchanged from original
// ---------------------------------------------------------------------------

class _TableCard extends StatelessWidget {
  final TableModel table;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TableCard({
    required this.table,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (table.status) {
      case 'available':
        statusColor = Colors.green;
        break;
      case 'occupied':
        statusColor = Colors.orange;
        break;
      case 'reserved':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      child: InkWell(
        onTap: onEdit,
        onLongPress: () {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text('Delete Table ${table.tableNumber}?'),
              content: const Text('This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    onDelete();
                  },
                  style:
                  TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.table_restaurant, color: statusColor, size: 24),
              const SizedBox(height: 4),
              Text(
                table.displayName.isNotEmpty
                    ? table.displayName
                    : table.tableNumber,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${table.tableNumber} · ${table.capacity} seats',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (!table.isActive)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Inactive',
                    style: TextStyle(fontSize: 9, color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
