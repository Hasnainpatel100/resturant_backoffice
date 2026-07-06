import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/indent_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/internal_movement_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/internal_movement_repositories.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/inventory_lookup_controller.dart';
import 'package:intl/intl.dart';

class ScreenIndentList extends StatefulWidget {
  final String brandId;
  const ScreenIndentList({super.key, required this.brandId});

  @override
  State<ScreenIndentList> createState() => _ScreenIndentListState();
}

class _ScreenIndentListState extends State<ScreenIndentList> {
  late final IndentController controller;
  late final InventoryLookupController lookupController;

  @override
  void initState() {
    super.initState();
    controller =
        Get.put(IndentController(repository: IndentRepositoryImpl()));
    lookupController = Get.put(InventoryLookupController());
    controller.loadIndents();
    lookupController.loadAllLookups();
  }

  @override
  void dispose() {
    Get.delete<IndentController>();
    super.dispose();
  }

  String _getWarehouseName(String id) {
    final branch =
        lookupController.branches.firstWhereOrNull((b) => b.id == id);
    if (branch != null) {
      return branch.name.en.isNotEmpty ? branch.name.en : branch.branchCode;
    }
    return 'Unknown Warehouse';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surface,
        scrolledUnderElevation: 1,
        title: const Text('Purchase Indents',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => controller.loadIndents(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context
                .push('/brands/${widget.brandId}/inventory/indents/create'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New Indent'),
            style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.indents.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null &&
            controller.indents.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load indents',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadIndents(),
          );
        }
        if (controller.indents.isEmpty) {
          return AppEmptyState(
            icon: Icons.assignment_rounded,
            title: 'No indents yet',
            subtitle:
                'Create purchase indents to request stock from another branch or central warehouse.',
            actionLabel: 'New Indent',
            onAction: () => context
                .push('/brands/${widget.brandId}/inventory/indents/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadIndents(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
            itemCount: controller.indents.length,
            itemBuilder: (context, idx) {
              final indent = controller.indents[idx];
              final isDraft = indent.status == 'draft';
              final dateStr = DateFormat('dd MMM yyyy')
                  .format(indent.indentDate);
              final statusColor =
                  isDraft ? Colors.amber.shade700 : Colors.green.shade600;

              return AppListCard(
                icon: Icons.assignment_rounded,
                iconColor: statusColor,
                title: indent.indentNo,
                status: AppListCardStatus(
                    label: indent.status, color: statusColor),
                lines: [
                  'From: ${_getWarehouseName(indent.fromWarehouseId)}',
                  'To: ${_getWarehouseName(indent.toWarehouseId)}  •  $dateStr',
                ],
                actions: [
                  AppListCardAction(
                    icon: isDraft
                        ? Icons.edit_outlined
                        : Icons.visibility_outlined,
                    tooltip: isDraft ? 'Edit' : 'View',
                    onTap: () => context.push(
                        '/brands/${widget.brandId}/inventory/indents/${indent.id}/edit'),
                  ),
                  if (isDraft)
                    AppListCardAction(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Delete',
                      color: cs.error,
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            icon: Icon(Icons.warning_amber_rounded,
                                color: cs.error, size: 40),
                            title: const Text('Delete Indent?'),
                            content: Text(
                                'Delete "${indent.indentNo}"? This cannot be undone.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel')),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: cs.error),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await controller.deleteIndent(indent.id);
                        }
                      },
                    ),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}
