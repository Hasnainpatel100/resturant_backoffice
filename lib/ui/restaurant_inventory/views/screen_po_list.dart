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
    controller = Get.put(PurchaseOrderController(repository: PurchaseOrderRepositoryImpl()));
    vendorController = Get.put(VendorController(repository: VendorRepositoryImpl()));

    controller.loadPOs();
    vendorController.loadVendors();
  }

  @override
  void dispose() {
    Get.delete<PurchaseOrderController>();
    super.dispose();
  }

  String _getVendorName(String vendorId) {
    final v = vendorController.vendors.firstWhereOrNull((vendor) => vendor.id == vendorId);
    return v?.vendorName ?? 'Unknown Vendor';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'posted':
      case 'received':
        return Colors.green;
      case 'submitted':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'draft':
      default:
        return Colors.amber.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.loadPOs();
              vendorController.loadVendors();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.pos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null && controller.pos.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
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
            subtitle: 'Create a purchase order to request items/materials from a vendor.',
            actionLabel: 'New Purchase Order',
            onAction: () => context.push('/brands/${widget.brandId}/inventory/purchase-orders/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadPOs(),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: controller.pos.length,
            itemBuilder: (context, index) {
              final po = controller.pos[index];
              final poDateStr = DateFormat('yyyy-MM-dd').format(po.poDate);
              final delDateStr = DateFormat('yyyy-MM-dd').format(po.deliveryDate);
              final isEditable = po.status == 'draft';

              return Card(
                child: ListTile(
                  title: Row(
                    children: [
                      Text(po.poNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(po.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          po.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(po.status),
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
                      Text('Vendor: ${_getVendorName(po.vendorId)}'),
                      Text('Date: $poDateStr • Delivery: $delDateStr • Total: \$${po.totalWithTax.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(isEditable ? Icons.edit_outlined : Icons.visibility_outlined),
                        onPressed: () => context.push('/brands/${widget.brandId}/inventory/purchase-orders/${po.id}/edit'),
                      ),
                      if (isEditable)
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: cs.error),
                          onPressed: () => _confirmDelete(context, po),
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
        onPressed: () => context.push('/brands/${widget.brandId}/inventory/purchase-orders/create'),
        icon: const Icon(Icons.add),
        label: const Text('New PO'),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PurchaseOrderModel po) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Purchase Order?'),
        content: Text('Are you sure you want to delete "${po.poNo}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await controller.deletePO(po.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Purchase Order deleted successfully'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(controller.errorMessage.value ?? 'Failed to delete PO'), backgroundColor: cs.error),
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
