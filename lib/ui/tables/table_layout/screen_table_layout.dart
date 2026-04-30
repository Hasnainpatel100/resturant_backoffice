import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/table_repository_impl.dart';
import 'package:back_office/data/repositories/branch_repository_impl.dart';
import 'package:back_office/ui/tables/table_layout/cubit_table.dart';
import 'package:back_office/ui/tables/table_layout/state_table.dart';
import 'package:back_office/ui/branch/branch_list/cubit_branch.dart';
import 'package:back_office/ui/branch/branch_list/state_branch.dart';
import 'package:back_office/routing/global_navigator.dart';

class ScreenTableLayout extends StatefulWidget {
  final String brandId;
  final String? branchId;

  const ScreenTableLayout({super.key, required this.brandId, this.branchId});

  @override
  State<ScreenTableLayout> createState() => _ScreenTableLayoutState();
}

class _ScreenTableLayoutState extends State<ScreenTableLayout> {
  String? _selectedBranchId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CubitBranch(repository: BranchRepositoryImpl())..loadBranches(widget.brandId),
      child: _TableLayoutBody(
        brandId: widget.brandId,
        selectedBranchId: _selectedBranchId,
        onBranchSelected: (branchId) {
          setState(() => _selectedBranchId = branchId);
        },
        onAddTable: () => _showAddTableDialog(context),
      ),
    );
  }

  void _showAddTableDialog(BuildContext context) {
    if (_selectedBranchId == null) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Branch Required'),
          content: const Text('Please enter a Branch ID to add tables.'),
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

    final tableNumberController = TextEditingController();
    final capacityController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Table'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: tableNumberController, decoration: const InputDecoration(labelText: 'Table Number')),
            SizedBox(height: AppSpacing.md),
            TextField(controller: capacityController, decoration: const InputDecoration(labelText: 'Capacity'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (tableNumberController.text.isNotEmpty) {
                context.read<CubitTable>().createTables(widget.brandId, [
                  {
                    'tableNumber': tableNumberController.text,
                    'capacity': int.tryParse(capacityController.text) ?? 4,
                    'branchId': _selectedBranchId,
                  }
                ]);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _TableLayoutBody extends StatelessWidget {
  final String brandId;
  final String? selectedBranchId;
  final ValueChanged<String> onBranchSelected;
  final VoidCallback onAddTable;

  const _TableLayoutBody({
    required this.brandId,
    this.selectedBranchId,
    required this.onBranchSelected,
    required this.onAddTable,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/brands/$brandId')),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: onAddTable),
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
                        child: Text('No branches found', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
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
                      if (value != null) {
                        onBranchSelected(value);
                      }
                    },
                  );
                },
              ),
            )
          else
            Expanded(
              child: BlocProvider(
                create: (context) => CubitTable(repository: TableRepositoryImpl())
                  ..loadTables(brandId, selectedBranchId!),
                child: BlocBuilder<CubitTable, StateTable>(
                  builder: (context, state) {
                    if (state.status == StateTableStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.tables.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.table_restaurant_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                            SizedBox(height: AppSpacing.md),
                            const Text('No tables configured'),
                            SizedBox(height: AppSpacing.md),
                            ElevatedButton.icon(
                              onPressed: onAddTable,
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
                        crossAxisCount: 4,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                      ),
                      itemCount: state.tables.length,
                      itemBuilder: (context, index) {
                        return _TableCard(table: state.tables[index]);
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  final dynamic table;

  const _TableCard({required this.table});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
        onTap: () {},
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
              SizedBox(height: 4),
              Text(table.tableNumber, style: Theme.of(context).textTheme.titleSmall),
              Text('${table.capacity} seats', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}