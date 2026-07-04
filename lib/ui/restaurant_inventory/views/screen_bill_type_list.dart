import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/bill_type_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';

class ScreenBillTypeList extends StatefulWidget {
  final String brandId;
  const ScreenBillTypeList({super.key, required this.brandId});

  @override
  State<ScreenBillTypeList> createState() => _ScreenBillTypeListState();
}

class _ScreenBillTypeListState extends State<ScreenBillTypeList> {
  late final BillTypeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(BillTypeController(repository: BillTypeRepositoryImpl()));
    controller.loadBillTypes();
  }

  @override
  void dispose() {
    Get.delete<BillTypeController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Procurement Bill Types'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => controller.loadBillTypes(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push('/brands/${widget.brandId}/inventory/bill-types/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Bill Type'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.billTypes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null && controller.billTypes.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load bill types',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadBillTypes(),
          );
        }

        if (controller.billTypes.isEmpty) {
          return AppEmptyState(
            icon: Icons.receipt_long,
            title: 'No bill types yet',
            subtitle: 'Add procurement invoice bill types like Cash, Credit Bill, Consignment, atc.',
            actionLabel: 'Add Bill Type',
            onAction: () => context.push('/brands/${widget.brandId}/inventory/bill-types/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadBillTypes(),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: controller.billTypes.length,
            itemBuilder: (context, index) {
              final bt = controller.billTypes[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.tertiary.withOpacity(0.1),
                    child: Icon(Icons.receipt_long, color: cs.tertiary),
                  ),
                  title: Text(bt.billTypeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Remark: ${bt.remark ?? "N/A"} • Status: ${bt.isActive ? "Active" : "Inactive"}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => context.push('/brands/${widget.brandId}/inventory/bill-types/${bt.id}/edit'),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: cs.error),
                        onPressed: () => _confirmDelete(context, bt),
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

  void _confirmDelete(BuildContext context, BillTypeModel bt) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Bill Type?'),
        content: Text('Are you sure you want to delete "${bt.displayLabel}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await controller.deleteBillType(bt.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bill type deleted successfully'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(controller.errorMessage.value ?? 'Failed to delete bill type'), backgroundColor: cs.error),
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
