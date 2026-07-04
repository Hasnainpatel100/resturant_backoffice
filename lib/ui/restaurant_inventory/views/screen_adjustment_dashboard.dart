import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/manual_stock_entry_model.dart';
import 'package:back_office/data/models/restaurant_inventory/manual_stock_out_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/manual_inventory_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';
import 'package:back_office/data/repositories/restaurant_inventory/manual_inventory_repositories.dart';
import 'package:intl/intl.dart';

class ScreenAdjustmentDashboard extends StatefulWidget {
  final String brandId;
  const ScreenAdjustmentDashboard({super.key, required this.brandId});

  @override
  State<ScreenAdjustmentDashboard> createState() => _ScreenAdjustmentDashboardState();
}

class _ScreenAdjustmentDashboardState extends State<ScreenAdjustmentDashboard> {
  late final ManualStockEntryController entryController;
  late final ManualStockOutController outController;
  late final LocationController locationController;
  late final StockReasonController reasonController;

  @override
  void initState() {
    super.initState();
    entryController = Get.put(ManualStockEntryController(repository: ManualStockEntryRepositoryImpl()));
    outController = Get.put(ManualStockOutController(repository: ManualStockOutRepositoryImpl()));
    locationController = Get.put(LocationController(repository: LocationRepositoryImpl()));
    reasonController = Get.put(StockReasonController(repository: StockReasonRepositoryImpl()));

    entryController.loadEntries();
    outController.loadOuts();
    locationController.loadLocations();
    reasonController.loadReasons();
  }

  @override
  void dispose() {
    Get.delete<ManualStockEntryController>();
    Get.delete<ManualStockOutController>();
    super.dispose();
  }

  String _getWarehouseName(String warehouseId) {
    final loc = locationController.locations.firstWhereOrNull((l) => l.id == warehouseId);
    return loc?.locationName ?? 'Unknown Warehouse';
  }

  String _getReasonName(String reasonId) {
    final r = reasonController.reasons.firstWhereOrNull((reason) => reason.id == reasonId);
    return r?.reasonName ?? 'Unknown Reason';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stock Adjustments'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.download), text: 'Manual Stock In'),
              Tab(icon: Icon(Icons.upload), text: 'Manual Stock Out'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh All',
              onPressed: () {
                entryController.loadEntries();
                outController.loadOuts();
                locationController.loadLocations();
                reasonController.loadReasons();
              },
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'in') {
                  context.push('/brands/${widget.brandId}/inventory/adjustments/entries/create');
                } else if (value == 'out') {
                  context.push('/brands/${widget.brandId}/inventory/adjustments/outs/create');
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'in',
                  child: Row(
                    children: [
                      Icon(Icons.download, size: 20),
                      SizedBox(width: 8),
                      Text('New Manual Stock In'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'out',
                  child: Row(
                    children: [
                      Icon(Icons.upload, size: 20),
                      SizedBox(width: 8),
                      Text('New Manual Stock Out'),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Adjustment',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: TabBarView(
          children: [
            _buildStockInList(),
            _buildStockOutList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInList() {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      if (entryController.isLoading.value && entryController.entries.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (entryController.errorMessage.value != null && entryController.entries.isEmpty) {
        return AppEmptyState(
          icon: Icons.error_outline,
          title: 'Failed to load entries',
          subtitle: entryController.errorMessage.value,
          actionLabel: 'Retry',
          onAction: () => entryController.loadEntries(),
        );
      }

      if (entryController.entries.isEmpty) {
        return AppEmptyState(
          icon: Icons.download_done_rounded,
          title: 'No manual stock in entries',
          subtitle: 'Create a stock-in entry to manually add quantity and value to your warehouse inventory.',
          actionLabel: 'Create Stock In',
          onAction: () => context.push('/brands/${widget.brandId}/inventory/adjustments/entries/create'),
        );
      }

      return RefreshIndicator(
        onRefresh: () => entryController.loadEntries(),
        child: ListView.builder(
          padding: EdgeInsets.all(AppSpacing.md),
          itemCount: entryController.entries.length,
          itemBuilder: (context, index) {
            final entry = entryController.entries[index];
            final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(entry.entryDate);
            final isPosted = entry.status == 'posted';

            return Card(
              child: ListTile(
                title: Row(
                  children: [
                    Text(entry.entryNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPosted ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        entry.status.toUpperCase(),
                        style: TextStyle(
                          color: isPosted ? Colors.green : Colors.amber.shade800,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Warehouse: ${_getWarehouseName(entry.warehouseId)}'),
                    Text('Date: $dateStr • Items: ${entry.items.length} • Total: \$${entry.totalWithTax.toStringAsFixed(2)}'),
                    if (entry.remark != null) Text('Remark: ${entry.remark}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(isPosted ? Icons.visibility_outlined : Icons.edit_outlined),
                      onPressed: () => context.push('/brands/${widget.brandId}/inventory/adjustments/entries/${entry.id}/edit'),
                    ),
                    if (!isPosted)
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: cs.error),
                        onPressed: () => _confirmDeleteEntry(context, entry),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildStockOutList() {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      if (outController.isLoading.value && outController.outs.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (outController.errorMessage.value != null && outController.outs.isEmpty) {
        return AppEmptyState(
          icon: Icons.error_outline,
          title: 'Failed to load stock outs',
          subtitle: outController.errorMessage.value,
          actionLabel: 'Retry',
          onAction: () => outController.loadOuts(),
        );
      }

      if (outController.outs.isEmpty) {
        return AppEmptyState(
          icon: Icons.upload_file_rounded,
          title: 'No manual stock out entries',
          subtitle: 'Create a stock-out entry to write-off or manually reduce stock for wastage, theft, etc.',
          actionLabel: 'Create Stock Out',
          onAction: () => context.push('/brands/${widget.brandId}/inventory/adjustments/outs/create'),
        );
      }

      return RefreshIndicator(
        onRefresh: () => outController.loadOuts(),
        child: ListView.builder(
          padding: EdgeInsets.all(AppSpacing.md),
          itemCount: outController.outs.length,
          itemBuilder: (context, index) {
            final out = outController.outs[index];
            final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(out.stockOutDate);
            final isPosted = out.status == 'posted';

            return Card(
              child: ListTile(
                title: Row(
                  children: [
                    Text(out.stockOutNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPosted ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        out.status.toUpperCase(),
                        style: TextStyle(
                          color: isPosted ? Colors.green : Colors.amber.shade800,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Warehouse: ${_getWarehouseName(out.warehouseId)} • Reason: ${_getReasonName(out.reasonId)}'),
                    Text('Date: $dateStr • Items: ${out.items.length}'),
                    if (out.remark != null) Text('Remark: ${out.remark}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(isPosted ? Icons.visibility_outlined : Icons.edit_outlined),
                      onPressed: () => context.push('/brands/${widget.brandId}/inventory/adjustments/outs/${out.id}/edit'),
                    ),
                    if (!isPosted)
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: cs.error),
                        onPressed: () => _confirmDeleteOut(context, out),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _confirmDeleteEntry(BuildContext context, ManualStockEntryModel entry) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Stock Entry?'),
        content: Text('Are you sure you want to delete "${entry.entryNo}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await entryController.deleteEntry(entry.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stock Entry deleted successfully'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(entryController.errorMessage.value ?? 'Failed to delete entry'), backgroundColor: cs.error),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteOut(BuildContext context, ManualStockOutModel out) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Stock Out?'),
        content: Text('Are you sure you want to delete "${out.stockOutNo}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await outController.deleteOut(out.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stock Out deleted successfully'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(outController.errorMessage.value ?? 'Failed to delete stock out'), backgroundColor: cs.error),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
