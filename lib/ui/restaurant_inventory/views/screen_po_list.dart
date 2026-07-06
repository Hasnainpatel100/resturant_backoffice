import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/purchase_order_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/procurement_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';
import 'package:back_office/data/repositories/restaurant_inventory/procurement_repositories.dart';
import 'package:intl/intl.dart';

class ScreenPOList extends StatefulWidget {
  final String brandId;
  const ScreenPOList({super.key, required this.brandId});

  @override
  State<ScreenPOList> createState() => _ScreenPOListState();
}

class _ScreenPOListState extends State<ScreenPOList> {
  late final PurchaseOrderController controller;
  late final VendorController vendorController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
        PurchaseOrderController(repository: PurchaseOrderRepositoryImpl()));
    vendorController =
        Get.put(VendorController(repository: VendorRepositoryImpl()));
    controller.loadPOs();
    vendorController.loadVendors();
  }

  @override
  void dispose() {
    Get.delete<PurchaseOrderController>();
    super.dispose();
  }

  String _getVendorName(String vendorId) {
    final v =
        vendorController.vendors.firstWhereOrNull((v) => v.id == vendorId);
    return v?.vendorName ?? 'Unknown Vendor';
  }

  Color _statusColor(String status) {
    return switch (status.toLowerCase()) {
      'posted' || 'received' => Colors.green.shade600,
      'submitted' => Colors.blue.shade600,
      'cancelled' => Colors.red.shade600,
      _ => Colors.amber.shade700,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surface,
        scrolledUnderElevation: 1,
        title: const Text('Purchase Orders',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              controller.loadPOs();
              vendorController.loadVendors();
            },
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push(
                '/brands/${widget.brandId}/inventory/purchase-orders/create'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New PO'),
            style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.pos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null && controller.pos.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load Purchase Orders',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadPOs(),
          );
        }
        if (controller.pos.isEmpty) {
          return AppEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No purchase orders',
            subtitle:
                'Create a purchase order to request items from a vendor.',
            actionLabel: 'New Purchase Order',
            onAction: () => context.push(
                '/brands/${widget.brandId}/inventory/purchase-orders/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadPOs(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
            itemCount: controller.pos.length,
            itemBuilder: (context, index) {
              final po = controller.pos[index];
              final poDateStr = DateFormat('dd MMM yyyy').format(po.poDate);
              final delDateStr =
                  DateFormat('dd MMM yyyy').format(po.deliveryDate);
              final isEditable = po.status == 'draft';
              final statusColor = _statusColor(po.status);

              return AppListCard(
                icon: Icons.assignment_rounded,
                iconColor: statusColor,
                title: po.poNo,
                status: AppListCardStatus(label: po.status, color: statusColor),
                lines: [
                  'Vendor: ${_getVendorName(po.vendorId)}',
                  'PO: $poDateStr  •  Delivery: $delDateStr  •  \$${po.totalWithTax.toStringAsFixed(2)}',
                ],
                actions: [
                  AppListCardAction(
                    icon: isEditable
                        ? Icons.edit_outlined
                        : Icons.visibility_outlined,
                    tooltip: isEditable ? 'Edit' : 'View',
                    onTap: () => context.push(
                        '/brands/${widget.brandId}/inventory/purchase-orders/${po.id}/edit'),
                  ),
                  if (isEditable)
                    AppListCardAction(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Delete',
                      color: cs.error,
                      onTap: () => _confirmDelete(context, po),
                    ),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, PurchaseOrderModel po) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Purchase Order?'),
        content: Text(
            'Are you sure you want to delete "${po.poNo}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await controller.deletePO(po.id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? 'Purchase Order deleted'
                    : controller.errorMessage.value ?? 'Failed'),
                backgroundColor: ok ? Colors.green : cs.error,
              ));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
