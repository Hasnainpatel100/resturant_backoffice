import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/stock_transfer_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/internal_movement_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/internal_movement_repositories.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/inventory_lookup_controller.dart';
import 'package:intl/intl.dart';

class ScreenTransferList extends StatefulWidget {
  final String brandId;
  const ScreenTransferList({super.key, required this.brandId});

  @override
  State<ScreenTransferList> createState() => _ScreenTransferListState();
}

class _ScreenTransferListState extends State<ScreenTransferList> {
  late final StockTransferController controller;
  late final InventoryLookupController lookupController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(StockTransferController(repository: StockTransferRepositoryImpl()));
    lookupController = Get.put(InventoryLookupController());
    controller.loadTransfers();
    lookupController.loadAllLookups();
  }

  @override
  void dispose() {
    Get.delete<StockTransferController>();
    super.dispose();
  }

  String _getWarehouseName(String id) {
    final branch = lookupController.branches.firstWhereOrNull((b) => b.id == id);
    if (branch != null) {
      return branch.name.en.isNotEmpty ? branch.name.en : branch.branchCode;
    }
    return 'Unknown Warehouse';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Transfers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadTransfers(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push('/brands/${widget.brandId}/inventory/transfers/create'),
            icon: const Icon(Icons.add),
            label: const Text('New Transfer'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.transfers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null && controller.transfers.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load transfers',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadTransfers(),
          );
        }

        if (controller.transfers.isEmpty) {
          return AppEmptyState(
            icon: Icons.compare_arrows_outlined,
            title: 'No transfers yet',
            subtitle: 'Log physical stock transfers between kitchen locations or warehouses.',
            actionLabel: 'New Transfer',
            onAction: () => context.push('/brands/${widget.brandId}/inventory/transfers/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadTransfers(),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: controller.transfers.length,
            itemBuilder: (context, idx) {
              final transfer = controller.transfers[idx];
              final isDraft = transfer.status == 'draft';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primary.withOpacity(0.1),
                    child: Icon(Icons.compare_arrows, color: cs.primary),
                  ),
                  title: Text(transfer.transferNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('From: ${_getWarehouseName(transfer.fromWarehouseId)}\nTo: ${_getWarehouseName(transfer.toWarehouseId)}\nDate: ${DateFormat('yyyy-MM-dd').format(transfer.transferDate)}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDraft ? Colors.grey[200] : Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          transfer.status.toUpperCase(),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDraft ? Colors.grey[800] : Colors.green[800]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(isDraft ? Icons.edit_outlined : Icons.visibility_outlined),
                        onPressed: () => context.push('/brands/${widget.brandId}/inventory/transfers/${transfer.id}/edit'),
                      ),
                      if (isDraft)
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: cs.error),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Transfer?'),
                                content: Text('Are you sure you want to delete "${transfer.transferNo}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await controller.deleteTransfer(transfer.id);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
