import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/models/table_model.dart';
import 'package:back_office/data/repositories/table_repository_impl.dart';
import 'package:back_office/ui/tables/table_layout/cubit_table.dart';
import 'package:back_office/ui/tables/table_layout/state_table.dart';

/// Shows all tables belonging to a specific room type.
/// Tapping a table opens the order placement sheet.
class ScreenRoomTables extends StatelessWidget {
  final String brandId;
  final String branchId;
  final String roomTypeId;
  final String roomTypeName;

  const ScreenRoomTables({
    super.key,
    required this.brandId,
    required this.branchId,
    required this.roomTypeId,
    required this.roomTypeName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitTable(repository: TableRepositoryImpl())
        ..loadTables(brandId, branchId),
      child: _RoomTablesBody(
        brandId: brandId,
        branchId: branchId,
        roomTypeId: roomTypeId,
        roomTypeName: roomTypeName,
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _RoomTablesBody extends StatelessWidget {
  final String brandId;
  final String branchId;
  final String roomTypeId;
  final String roomTypeName;

  const _RoomTablesBody({
    required this.brandId,
    required this.branchId,
    required this.roomTypeId,
    required this.roomTypeName,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(roomTypeName),
        leading: const BackButton(),
        actions: [
          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LegendDot(color: Colors.green, label: 'Free'),
                const SizedBox(width: 8),
                _LegendDot(color: Colors.orange, label: 'Busy'),
                const SizedBox(width: 8),
                _LegendDot(color: Colors.blue, label: 'Reserved'),
              ],
            ),
          ),
        ],
      ),
      body: BlocBuilder<CubitTable, StateTable>(
        builder: (context, state) {
          if (state.status == StateTableStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == StateTableStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: cs.error),
                  const SizedBox(height: 12),
                  Text(state.errorMessage ?? 'Something went wrong'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<CubitTable>().loadTables(brandId, branchId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Filter tables for this room type only
          final roomTables = state.tables
              .where((t) => t.roomTypeId == roomTypeId)
              .toList();

          if (roomTables.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.table_restaurant_outlined,
                      size: 64, color: cs.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No tables in $roomTypeName',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add tables from the Tables menu and assign them to this room type.',
                    style: TextStyle(color: cs.outline),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Summary bar
          final available =
              roomTables.where((t) => t.status == 'available').length;
          final occupied =
              roomTables.where((t) => t.status == 'occupied').length;
          final reserved =
              roomTables.where((t) => t.status == 'reserved').length;

          return Column(
            children: [
              // ── Summary strip ──
              Container(
                color: cs.surfaceVariant,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _SummaryChip(
                      icon: Icons.check_circle,
                      color: Colors.green,
                      label: '$available Available',
                    ),
                    const SizedBox(width: 12),
                    _SummaryChip(
                      icon: Icons.people,
                      color: Colors.orange,
                      label: '$occupied Occupied',
                    ),
                    const SizedBox(width: 12),
                    _SummaryChip(
                      icon: Icons.bookmark,
                      color: Colors.blue,
                      label: '$reserved Reserved',
                    ),
                    const Spacer(),
                    Text(
                      '${roomTables.length} tables',
                      style: TextStyle(color: cs.outline, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // ── Table grid ──
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(AppSpacing.md),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _crossAxisCount(context),
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: roomTables.length,
                  itemBuilder: (context, index) {
                    final table = roomTables[index];
                    return _RoomTableCard(
                      table: table,
                      onTap: () => _openOrderSheet(context, table),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _crossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 900) return 5;
    if (width > 600) return 4;
    return 3;
  }

  void _openOrderSheet(BuildContext context, TableModel table) {
    if (table.status == 'occupied') {
      // Table already has an active order — show options
      _showOccupiedOptions(context, table);
    } else {
      // Table is free / reserved — start a new order
      _showNewOrderSheet(context, table);
    }
  }

  void _showNewOrderSheet(BuildContext context, TableModel table) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _NewOrderSheet(table: table, brandId: brandId),
    );
  }

  void _showOccupiedOptions(BuildContext context, TableModel table) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OccupiedTableSheet(table: table, brandId: brandId),
    );
  }
}

// ---------------------------------------------------------------------------
// Table card

class _RoomTableCard extends StatelessWidget {
  final TableModel table;
  final VoidCallback onTap;

  const _RoomTableCard({required this.table, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(table.status);
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: statusColor.withOpacity(0.07),
          border: Border.all(color: statusColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Table icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withOpacity(0.15),
              ),
              child: Icon(Icons.table_restaurant, color: statusColor, size: 28),
            ),
            const SizedBox(height: 8),
            // Display name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                table.displayName.isNotEmpty
                    ? table.displayName
                    : table.tableNumber,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // Capacity
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 12, color: cs.outline),
                const SizedBox(width: 2),
                Text(
                  '${table.capacity}',
                  style: TextStyle(fontSize: 11, color: cs.outline),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Status badge
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel(table.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!table.isActive) ...[
              const SizedBox(height: 4),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Inactive',
                  style: TextStyle(fontSize: 9, color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'occupied':
        return Colors.orange;
      case 'reserved':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'available':
        return 'Available';
      case 'occupied':
        return 'Occupied';
      case 'reserved':
        return 'Reserved';
      default:
        return status;
    }
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet — new order

class _NewOrderSheet extends StatelessWidget {
  final TableModel table;
  final String brandId;

  const _NewOrderSheet({required this.table, required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outline.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.table_restaurant,
                      color: Colors.green, size: 28),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      table.displayName.isNotEmpty
                          ? table.displayName
                          : table.tableNumber,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${table.tableNumber} · ${table.capacity} seats',
                      style: TextStyle(color: cs.outline),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'Available',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            Text('What would you like to do?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.receipt_long,
                    label: 'New Order',
                    color: cs.primary,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to your order/POS screen
                      // e.g. context.push('/brands/$brandId/orders/new?tableId=${table.id}')
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Opening order for ${table.displayName.isNotEmpty ? table.displayName : table.tableNumber}…'),
                          backgroundColor: cs.primary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.bookmark_outline,
                    label: 'Reserve',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to reservation screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Reserve ${table.displayName.isNotEmpty ? table.displayName : table.tableNumber}…'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet — occupied table

class _OccupiedTableSheet extends StatelessWidget {
  final TableModel table;
  final String brandId;

  const _OccupiedTableSheet({required this.table, required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outline.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.table_restaurant,
                    color: Colors.orange, size: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    table.displayName.isNotEmpty
                        ? table.displayName
                        : table.tableNumber,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${table.tableNumber} · ${table.capacity} seats',
                    style: TextStyle(color: cs.outline),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Text(
                  'Occupied',
                  style: TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          Text('Table is occupied',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Choose an action for this table.',
              style: TextStyle(color: cs.outline)),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.visibility,
                  label: 'View Order',
                  color: cs.primary,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to current order view
                    // e.g. context.push('/brands/$brandId/orders?tableId=${table.id}')
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Add Items',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to add-items / POS screen
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.payment,
                  label: 'Bill / Pay',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to billing screen
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.swap_horiz,
                  label: 'Move Table',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Table transfer logic
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _SummaryChip(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
