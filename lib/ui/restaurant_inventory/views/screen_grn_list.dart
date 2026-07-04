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
    controller = Get.put(GoodsReceiptController(repository: GoodsReceiptRepositoryImpl()));
    vendorController = Get.put(VendorController(repository: VendorRepositoryImpl()));

    controller.loadGRNs();
    vendorController.loadVendors();
  }

  @override
  void dispose() {
    Get.delete<GoodsReceiptController>();
    super.dispose();
  }

  String _getVendorName(String vendorId) {
    final v = vendorController.vendors.firstWhereOrNull((vendor) => vendor.id == vendorId);
    return v?.vendorName ?? 'Unknown Vendor';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goods Receipts (GRN)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.loadGRNs();
              vendorController.loadVendors();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.grns.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null && controller.grns.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
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
            subtitle: 'Log a Goods Receipt (GRN) when receiving inventory from a supplier.',
            actionLabel: 'New Goods Receipt',
            onAction: () => context.push('/brands/${widget.brandId}/inventory/goods-receipts/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadGRNs(),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: controller.grns.length,
            itemBuilder: (context, index) {
              final grn = controller.grns[index];
              final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(grn.grnDate);
              final isPosted = grn.status == 'posted';

              return Card(
                child: ListTile(
                  title: Row(
                    children: [
                      Text(grn.grnNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPosted ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          grn.status.toUpperCase(),
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
                      Text('Vendor: ${_getVendorName(grn.vendorId)}'),
                      Text('Date: $dateStr • Items: ${grn.items.length} • Total: \$${grn.totalWithTax.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(isPosted ? Icons.visibility_outlined : Icons.edit_outlined),
                        onPressed: () => context.push('/brands/${widget.brandId}/inventory/goods-receipts/${grn.id}/edit'),
                      ),
                      if (!isPosted)
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: cs.error),
                          onPressed: () => _confirmDelete(context, grn),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/brands/${widget.brandId}/inventory/goods-receipts/create'),
        icon: const Icon(Icons.add),
        label: const Text('New GRN'),
      ),
    );
  }

  void _confirmDelete(BuildContext context, GoodsReceiptModel grn) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Goods Receipt?'),
        content: Text('Are you sure you want to delete "${grn.grnNo}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await controller.deleteGRN(grn.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Goods Receipt deleted successfully'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(controller.errorMessage.value ?? 'Failed to delete GRN'), backgroundColor: cs.error),
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
