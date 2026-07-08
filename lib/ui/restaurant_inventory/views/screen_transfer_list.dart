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
    controller = Get.put(
        StockTransferController(repository: StockTransferRepositoryImpl()));
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
    final branch =
        lookupController.branches.firstWhereOrNull((b) => b.id == id);
    if (branch != null) {
      return branch.name.en.isNotEmpty ? branch.name.en : branch.branchCode;
    }
    return 'Unknown Warehouse';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surface,
        scrolledUnderElevation: 1,
        title: const Text('Stock Transfers',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => controller.loadTransfers(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context
                .push('/brands/${widget.brandId}/inventory/transfers/create'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New Transfer'),
            style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.transfers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null &&
            controller.transfers.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load transfers',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadTransfers(),
          );
        }
        if (controller.transfers.isEmpty) {
          return AppEmptyState(
            icon: Icons.compare_arrows_rounded,
            title: 'No transfers yet',
            subtitle:
                'Log physical stock transfers between kitchen locations or warehouses.',
            actionLabel: 'New Transfer',
            onAction: () => context
                .push('/brands/${widget.brandId}/inventory/transfers/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadTransfers(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
            itemCount: controller.transfers.length,
            itemBuilder: (context, idx) {
              final transfer = controller.transfers[idx];
              final isDraft = transfer.status == 'draft';
              final dateStr = DateFormat('dd MMM yyyy')
                  .format(transfer.transferDate);
              final statusColor =
                  isDraft ? Colors.amber.shade700 : Colors.green.shade600;

              return AppListCard(
                icon: Icons.compare_arrows_rounded,
                iconColor: statusColor,
                title: transfer.transferNo,
                status: AppListCardStatus(
                    label: transfer.status, color: statusColor),
                lines: [
                  'From: ${_getWarehouseName(transfer.fromWarehouseId)}',
                  'To: ${_getWarehouseName(transfer.toWarehouseId)}  •  $dateStr',
                ],
                actions: [
                  AppListCardAction(
                    icon: isDraft
                        ? Icons.edit_outlined
                        : Icons.visibility_outlined,
                    tooltip: isDraft ? 'Edit' : 'View',
                    onTap: () => context.push(
                        '/brands/${widget.brandId}/inventory/transfers/${transfer.id}/edit'),
                  ),
                  if (isDraft)
                    AppListCardAction(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Delete',
                      color: cs.error,
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            icon: Icon(Icons.warning_amber_rounded,
                                color: cs.error, size: 40),
                            title: const Text('Delete Transfer?'),
                            content: Text(
                                'Delete "${transfer.transferNo}"? This cannot be undone.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel')),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: cs.error),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await controller.deleteTransfer(transfer.id);
                        }
                      },
                    ),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}
