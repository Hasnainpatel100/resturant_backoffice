import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/goods_receipt_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/procurement_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';
import 'package:back_office/data/repositories/restaurant_inventory/procurement_repositories.dart';
import 'package:intl/intl.dart';

class ScreenGRNList extends StatefulWidget {
  final String brandId;
  const ScreenGRNList({super.key, required this.brandId});

  @override
  State<ScreenGRNList> createState() => _ScreenGRNListState();
}

class _ScreenGRNListState extends State<ScreenGRNList> {
  late final GoodsReceiptController controller;
  late final VendorController vendorController;

  @override
  void initState() {
    super.initState();
    controller =
        Get.put(GoodsReceiptController(repository: GoodsReceiptRepositoryImpl()));
    vendorController =
        Get.put(VendorController(repository: VendorRepositoryImpl()));
    controller.loadGRNs();
    vendorController.loadVendors();
  }

  @override
  void dispose() {
    Get.delete<GoodsReceiptController>();
    super.dispose();
  }

  String _getVendorName(String vendorId) {
    final v =
        vendorController.vendors.firstWhereOrNull((v) => v.id == vendorId);
    return v?.vendorName ?? 'Unknown Vendor';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surface,
        scrolledUnderElevation: 1,
        title: const Text('Goods Receipts (GRN)',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              controller.loadGRNs();
              vendorController.loadVendors();
            },
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push(
                '/brands/${widget.brandId}/inventory/goods-receipts/create'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New GRN'),
            style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.grns.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null && controller.grns.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load GRNs',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadGRNs(),
          );
        }

        if (controller.grns.isEmpty) {
          return AppEmptyState(
            icon: Icons.download_done_rounded,
            title: 'No goods receipts',
            subtitle:
                'Log a Goods Receipt (GRN) when receiving inventory from a supplier.',
            actionLabel: 'New Goods Receipt',
            onAction: () => context.push(
                '/brands/${widget.brandId}/inventory/goods-receipts/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadGRNs(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
            itemCount: controller.grns.length,
            itemBuilder: (context, index) {
              final grn = controller.grns[index];
              final dateStr =
                  DateFormat('dd MMM yyyy, HH:mm').format(grn.grnDate);
              final isPosted = grn.status == 'posted';

              return AppListCard(
                icon: Icons.download_done_rounded,
                iconColor:
                    isPosted ? Colors.green.shade600 : Colors.amber.shade700,
                title: grn.grnNo,
                status: AppListCardStatus(
                  label: grn.status,
                  color: isPosted ? Colors.green : Colors.amber.shade700,
                ),
                lines: [
                  'Vendor: ${_getVendorName(grn.vendorId)}',
                  '$dateStr  •  ${grn.items.length} items  •  \$${grn.totalWithTax.toStringAsFixed(2)}',
                ],
                actions: [
                  AppListCardAction(
                    icon: isPosted
                        ? Icons.visibility_outlined
                        : Icons.edit_outlined,
                    tooltip: isPosted ? 'View' : 'Edit',
                    onTap: () => context.push(
                        '/brands/${widget.brandId}/inventory/goods-receipts/${grn.id}/edit'),
                  ),
                  if (!isPosted)
                    AppListCardAction(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Delete',
                      color: cs.error,
                      onTap: () => _confirmDelete(context, grn),
                    ),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, GoodsReceiptModel grn) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Goods Receipt?'),
        content: Text(
            'Are you sure you want to delete "${grn.grnNo}"? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await controller.deleteGRN(grn.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Goods Receipt deleted successfully'),
                    backgroundColor: Colors.green));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(controller.errorMessage.value ??
                        'Failed to delete GRN'),
                    backgroundColor: cs.error));
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
