import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/stock_reason_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';

class ScreenStockReasonList extends StatefulWidget {
  final String brandId;
  const ScreenStockReasonList({super.key, required this.brandId});

  @override
  State<ScreenStockReasonList> createState() => _ScreenStockReasonListState();
}

class _ScreenStockReasonListState extends State<ScreenStockReasonList> {
  late final StockReasonController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
        StockReasonController(repository: StockReasonRepositoryImpl()));
    controller.loadReasons();
  }

  @override
  void dispose() {
    Get.delete<StockReasonController>();
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
        title: const Text('Stock Adjustment Reasons',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => controller.loadReasons(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context
                .push('/brands/${widget.brandId}/inventory/reasons/create'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New Reason'),
            style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.reasons.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null &&
            controller.reasons.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load stock reasons',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadReasons(),
          );
        }
        if (controller.reasons.isEmpty) {
          return AppEmptyState(
            icon: Icons.assignment_late_rounded,
            title: 'No stock reasons yet',
            subtitle:
                'Add reasons for stock adjustments: Spoiled, Expired, Theft, Internal Use, etc.',
            actionLabel: 'Add Reason',
            onAction: () => context
                .push('/brands/${widget.brandId}/inventory/reasons/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadReasons(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
            itemCount: controller.reasons.length,
            itemBuilder: (context, index) {
              final r = controller.reasons[index];
              return AppListCard(
                icon: Icons.help_rounded,
                iconColor: Colors.orange.shade600,
                title: r.reasonName,
                lines: [
                  'Type: ${r.reasonType.toUpperCase()}',
                ],
                status: AppListCardStatus(
                  label: r.isActive ? 'Active' : 'Inactive',
                  color: r.isActive ? Colors.green.shade600 : Colors.grey,
                ),
                actions: [
                  AppListCardAction(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit',
                    onTap: () => context.push(
                        '/brands/${widget.brandId}/inventory/reasons/${r.id}/edit'),
                  ),
                  AppListCardAction(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete',
                    color: cs.error,
                    onTap: () => _confirmDelete(context, r),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, StockReasonModel r) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Stock Reason?'),
        content: Text(
            'Are you sure you want to delete "${r.displayLabel}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await controller.deleteReason(r.id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? 'Stock reason deleted successfully'
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
