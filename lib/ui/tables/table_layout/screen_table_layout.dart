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

class ScreenTableLayout extends StatefulWidget {
  final String brandId;
  final String? branchId;

  const ScreenTableLayout({super.key, required this.brandId, this.branchId});

  @override
  State<ScreenTableLayout> createState() => _ScreenTableLayoutState();
}

class _ScreenTableLayoutState extends State<ScreenTableLayout> {
  late String? _selectedBranchId = widget.branchId;
  List<RoomTypeModel> _roomTypes = [];
  bool _roomTypesLoading = false;
  CubitTable? _cubitTable;

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
      // ✅ FIX: Load room types on init when branchId is pre-provided.
      // Previously _loadRoomTypes() was only called on branch selection,
      // so the dropdown was always empty if branchId came from route params.
      _loadRoomTypes();
    }
  }

  @override
  void dispose() {
    _cubitTable?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
          CubitBranch(repository: BranchRepositoryImpl())
            ..loadBranches(widget.brandId),
        ),
        if (_cubitTable != null)
          BlocProvider<CubitTable>.value(value: _cubitTable!),
      ],
      child: _TableLayoutBody(
        brandId: widget.brandId,
        selectedBranchId: _selectedBranchId,
        hasCubitTable: _cubitTable != null,
        onBranchSelected: (branchId) {
          setState(() {
            _selectedBranchId = branchId;
            _initTableCubit(branchId);
          });
          _loadRoomTypes();
        },
        onAddTable: _showAddTableDialog,
      ),
    );
  }

  Future<void> _loadRoomTypes() async {
    if (_selectedBranchId == null) return;
    if (_roomTypes.isNotEmpty) return; // Cache: skip if already loaded

    setState(() => _roomTypesLoading = true);

    final result = await RoomTypeRepositoryImpl()
        .getRoomTypes(widget.brandId, _selectedBranchId!);

    result.fold(
          (failure) {
        debugPrint("RoomType load error: ${failure.message}");
      },
          (response) {
        setState(() {
          _roomTypes = response.items;
          _roomTypesLoading = false;
        });
      },
    );
  }

  void _showAddTableDialog(BuildContext context) {
    if (_selectedBranchId == null) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Branch Required'),
          content: const Text('Please select a branch before adding tables.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Controllers
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
            title: const Text('Add Table'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ BULK TOGGLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bulk Add',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Switch(
                        value: isBulk,
                        onChanged: (val) => setDialogState(() => isBulk = val),
                      ),
                    ],
                  ),
                  const Divider(height: 8),
                  const SizedBox(height: 8),

                  if (!isBulk) ...[
                    // ── SINGLE MODE ──
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
                    // ── BULK MODE ──
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

                  // ── SHARED FIELDS ──
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
                    initialValue: selectedRoomTypeId,
                    items: _roomTypes.map((room) {
                      return DropdownMenuItem(
                        value: room.id,
                        child: Text(room.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedRoomTypeId = value);
                    },
                  ),

                  // Loading / hint when no room types
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
                  final capacity = int.tryParse(capacityController.text) ?? 4;

                  // Validation
                  if (prefix.isEmpty || selectedRoomTypeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Table number and room type are required.'),
                      ),
                    );
                    return;
                  }

                  List<Map<String, dynamic>> tables;

                  if (isBulk) {
                    final count = int.tryParse(bulkCountController.text) ?? 1;
                    if (count < 1) return;
                    // ✅ Generates: T1, T2, T3... with all required fields
                    tables = List.generate(count, (i) => {
                      'tableNumber': '$prefix${i + 1}',
                      'displayName': '$prefix${i + 1}',
                      'capacity': capacity,
                      'branchId': _selectedBranchId,
                      'roomTypeId': selectedRoomTypeId,
                    });
                  } else {
                    final displayName = displayNameController.text.trim();
                    tables = [
                      {
                        'tableNumber': prefix,
                        'displayName': displayName.isNotEmpty ? displayName : prefix,
                        'capacity': capacity,
                        'branchId': _selectedBranchId,
                        'roomTypeId': selectedRoomTypeId,
                      }
                    ];
                  }

                  _cubitTable?.createTables(widget.brandId, tables);
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
}

// ---------------------------------------------------------------------------

class _TableLayoutBody extends StatelessWidget {
  final String brandId;
  final String? selectedBranchId;
  final bool hasCubitTable;
  final ValueChanged<String> onBranchSelected;
  final void Function(BuildContext context) onAddTable;

  const _TableLayoutBody({
    required this.brandId,
    this.selectedBranchId,
    required this.hasCubitTable,
    required this.onBranchSelected,
    required this.onAddTable,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/brands/$brandId'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => onAddTable(context),
          ),
        ],
      ),
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
                          style: TextStyle(color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Branch'),
                    hint: const Text('Select branch'),
                    items: branchState.branches.map((b) {
                      return DropdownMenuItem(value: b.id, child: Text(b.displayName));
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
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _crossAxisCount(context),
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                    ),
                    itemCount: state.tables.length,
                    itemBuilder: (context, index) {
                      final table = state.tables[index];
                      return _TableCard(
                        table: table,
                        onEdit: () => _showEditTableDialog(context, table),
                        onDelete: () => context.read<CubitTable>().deleteTable(table.id),
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
    final displayNameController = TextEditingController(text: table.displayName);
    final capacityController = TextEditingController(text: table.capacity.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
                'capacity': int.tryParse(capacityController.text) ?? table.capacity,
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
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
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
                table.displayName.isNotEmpty ? table.displayName : table.tableNumber,
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
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
