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
    controller = Get.put(StockReasonController(repository: StockReasonRepositoryImpl()));
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
      appBar: AppBar(
        title: const Text('Stock Out / Adjustment Reasons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => controller.loadReasons(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push('/brands/${widget.brandId}/inventory/reasons/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Reason'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.reasons.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null && controller.reasons.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load stock reasons',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadReasons(),
          );
        }

        if (controller.reasons.isEmpty) {
          return AppEmptyState(
            icon: Icons.assignment_late_outlined,
            title: 'No stock reasons yet',
            subtitle: 'Add reasons for manual stock adjustments and stock-out events like Spoiled, Expired, Theft, Internal Consumption, etc.',
            actionLabel: 'Add Reason',
            onAction: () => context.push('/brands/${widget.brandId}/inventory/reasons/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadReasons(),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: controller.reasons.length,
            itemBuilder: (context, index) {
              final r = controller.reasons[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primary.withOpacity(0.1),
                    child: Icon(Icons.help_outline, color: cs.primary),
                  ),
                  title: Text(r.reasonName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Type: ${r.reasonType.toUpperCase()} • Status: ${r.isActive ? "Active" : "Inactive"}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => context.push('/brands/${widget.brandId}/inventory/reasons/${r.id}/edit'),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: cs.error),
                        onPressed: () => _confirmDelete(context, r),
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

  void _confirmDelete(BuildContext context, StockReasonModel r) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Stock Reason?'),
        content: Text('Are you sure you want to delete "${r.displayLabel}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await controller.deleteReason(r.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stock reason deleted successfully'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(controller.errorMessage.value ?? 'Failed to delete reason'), backgroundColor: cs.error),
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
