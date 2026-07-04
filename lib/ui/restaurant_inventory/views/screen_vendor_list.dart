import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/vendor_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';

class ScreenVendorList extends StatefulWidget {
  final String brandId;
  const ScreenVendorList({super.key, required this.brandId});

  @override
  State<ScreenVendorList> createState() => _ScreenVendorListState();
}

class _ScreenVendorListState extends State<ScreenVendorList> {
  late final VendorController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(VendorController(repository: VendorRepositoryImpl()));
    controller.loadVendors();
  }

  @override
  void dispose() {
    Get.delete<VendorController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers & Vendors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => controller.loadVendors(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push('/brands/${widget.brandId}/inventory/suppliers/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Vendor'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.vendors.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null && controller.vendors.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load vendors',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadVendors(),
          );
        }

        if (controller.vendors.isEmpty) {
          return AppEmptyState(
            icon: Icons.people_outline,
            title: 'No vendors yet',
            subtitle: 'Add procurement vendors and suppliers who supply raw materials.',
            actionLabel: 'Add Vendor',
            onAction: () => context.push('/brands/${widget.brandId}/inventory/suppliers/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadVendors(),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: controller.vendors.length,
            itemBuilder: (context, index) {
              final v = controller.vendors[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primary.withOpacity(0.1),
                    child: Icon(Icons.business, color: cs.primary),
                  ),
                  title: Text(v.vendorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Code: ${v.vendorCode} • Contact: ${v.contactPerson ?? "N/A"} • Phone: ${v.phone ?? "N/A"} • Bal: \$${v.openingBalance} (${v.balanceType})'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => context.push('/brands/${widget.brandId}/inventory/suppliers/${v.id}/edit'),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: cs.error),
                        onPressed: () => _confirmDelete(context, v),
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

  void _confirmDelete(BuildContext context, VendorModel v) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Vendor?'),
        content: Text('Are you sure you want to delete "${v.displayLabel}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await controller.deleteVendor(v.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vendor deleted successfully'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(controller.errorMessage.value ?? 'Failed to delete vendor'), backgroundColor: cs.error),
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
