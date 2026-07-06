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
    controller =
        Get.put(BillTypeController(repository: BillTypeRepositoryImpl()));
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
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surface,
        scrolledUnderElevation: 1,
        title: const Text('Procurement Bill Types',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => controller.loadBillTypes(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context
                .push('/brands/${widget.brandId}/inventory/bill-types/create'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New Bill Type'),
            style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.billTypes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null &&
            controller.billTypes.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load bill types',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadBillTypes(),
          );
        }
        if (controller.billTypes.isEmpty) {
          return AppEmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'No bill types yet',
            subtitle:
                'Add procurement invoice types like Cash Bill, Credit Bill, Consignment, etc.',
            actionLabel: 'Add Bill Type',
            onAction: () => context.push(
                '/brands/${widget.brandId}/inventory/bill-types/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadBillTypes(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
            itemCount: controller.billTypes.length,
            itemBuilder: (context, index) {
              final bt = controller.billTypes[index];
              return AppListCard(
                icon: Icons.receipt_long_rounded,
                iconColor: cs.tertiary,
                title: bt.billTypeName,
                lines: [
                  bt.remark ?? 'No remark',
                ],
                status: AppListCardStatus(
                  label: bt.isActive ? 'Active' : 'Inactive',
                  color: bt.isActive ? Colors.green.shade600 : Colors.grey,
                ),
                actions: [
                  AppListCardAction(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit',
                    onTap: () => context.push(
                        '/brands/${widget.brandId}/inventory/bill-types/${bt.id}/edit'),
                  ),
                  AppListCardAction(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete',
                    color: cs.error,
                    onTap: () => _confirmDelete(context, bt),
                  ),
                ],
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
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Bill Type?'),
        content: Text(
            'Are you sure you want to delete "${bt.displayLabel}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await controller.deleteBillType(bt.id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? 'Bill type deleted successfully'
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
