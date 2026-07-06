import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/supplier_invoice_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/procurement_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';
import 'package:back_office/data/repositories/restaurant_inventory/procurement_repositories.dart';
import 'package:intl/intl.dart';

class ScreenInvoiceList extends StatefulWidget {
  final String brandId;
  const ScreenInvoiceList({super.key, required this.brandId});

  @override
  State<ScreenInvoiceList> createState() => _ScreenInvoiceListState();
}

class _ScreenInvoiceListState extends State<ScreenInvoiceList> {
  late final SupplierInvoiceController controller;
  late final VendorController vendorController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
        SupplierInvoiceController(repository: SupplierInvoiceRepositoryImpl()));
    vendorController =
        Get.put(VendorController(repository: VendorRepositoryImpl()));
    controller.loadInvoices();
    vendorController.loadVendors();
  }

  @override
  void dispose() {
    Get.delete<SupplierInvoiceController>();
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
        title: const Text('Supplier Invoices',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              controller.loadInvoices();
              vendorController.loadVendors();
            },
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push(
                '/brands/${widget.brandId}/inventory/supplier-invoices/create'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New Invoice'),
            style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.invoices.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null &&
            controller.invoices.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load invoices',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadInvoices(),
          );
        }
        if (controller.invoices.isEmpty) {
          return AppEmptyState(
            icon: Icons.receipt_outlined,
            title: 'No supplier invoices',
            subtitle:
                'Log a Supplier Invoice to record financial liabilities from a vendor.',
            actionLabel: 'New Supplier Invoice',
            onAction: () => context.push(
                '/brands/${widget.brandId}/inventory/supplier-invoices/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadInvoices(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
            itemCount: controller.invoices.length,
            itemBuilder: (context, index) {
              final inv = controller.invoices[index];
              final dateStr =
                  DateFormat('dd MMM yyyy').format(inv.invoiceDate);
              final isPosted = inv.status == 'posted';
              final statusColor =
                  isPosted ? Colors.green.shade600 : Colors.amber.shade700;

              return AppListCard(
                icon: Icons.receipt_rounded,
                iconColor: statusColor,
                title: inv.invoiceNo,
                status: AppListCardStatus(label: inv.status, color: statusColor),
                lines: [
                  'Vendor: ${_getVendorName(inv.vendorId)}',
                  '$dateStr  •  ${inv.items.length} items  •  \$${inv.totalWithTax.toStringAsFixed(2)}',
                ],
                actions: [
                  AppListCardAction(
                    icon: isPosted
                        ? Icons.visibility_outlined
                        : Icons.edit_outlined,
                    tooltip: isPosted ? 'View' : 'Edit',
                    onTap: () => context.push(
                        '/brands/${widget.brandId}/inventory/supplier-invoices/${inv.id}/edit'),
                  ),
                  if (!isPosted)
                    AppListCardAction(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Delete',
                      color: cs.error,
                      onTap: () => _confirmDelete(context, inv),
                    ),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, SupplierInvoiceModel inv) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Invoice?'),
        content: Text(
            'Are you sure you want to delete "${inv.invoiceNo}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await controller.deleteInvoice(inv.id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? 'Invoice deleted successfully'
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
