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
    controller = Get.put(SupplierInvoiceController(repository: SupplierInvoiceRepositoryImpl()));
    vendorController = Get.put(VendorController(repository: VendorRepositoryImpl()));

    controller.loadInvoices();
    vendorController.loadVendors();
  }

  @override
  void dispose() {
    Get.delete<SupplierInvoiceController>();
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
        title: const Text('Supplier Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.loadInvoices();
              vendorController.loadVendors();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.invoices.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null && controller.invoices.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
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
            subtitle: 'Log a Supplier Invoice to record financial liabilities from a vendor.',
            actionLabel: 'New Supplier Invoice',
            onAction: () => context.push('/brands/${widget.brandId}/inventory/supplier-invoices/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadInvoices(),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: controller.invoices.length,
            itemBuilder: (context, index) {
              final invoice = controller.invoices[index];
              final dateStr = DateFormat('yyyy-MM-dd').format(invoice.invoiceDate);
              final isPosted = invoice.status == 'posted';

              return Card(
                child: ListTile(
                  title: Row(
                    children: [
                      Text(invoice.invoiceNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPosted ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          invoice.status.toUpperCase(),
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
                      Text('Vendor: ${_getVendorName(invoice.vendorId)}'),
                      Text('Date: $dateStr • Items: ${invoice.items.length} • Total: \$${invoice.totalWithTax.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(isPosted ? Icons.visibility_outlined : Icons.edit_outlined),
                        onPressed: () => context.push('/brands/${widget.brandId}/inventory/supplier-invoices/${invoice.id}/edit'),
                      ),
                      if (!isPosted)
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: cs.error),
                          onPressed: () => _confirmDelete(context, invoice),
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
        onPressed: () => context.push('/brands/${widget.brandId}/inventory/supplier-invoices/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SupplierInvoiceModel invoice) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Invoice?'),
        content: Text('Are you sure you want to delete "${invoice.invoiceNo}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await controller.deleteInvoice(invoice.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invoice deleted successfully'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(controller.errorMessage.value ?? 'Failed to delete invoice'), backgroundColor: cs.error),
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
