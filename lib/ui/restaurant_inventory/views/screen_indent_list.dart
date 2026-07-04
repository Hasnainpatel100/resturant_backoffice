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
    controller = Get.put(IndentController(repository: IndentRepositoryImpl()));
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
    final branch = lookupController.branches.firstWhereOrNull((b) => b.id == id);
    if (branch != null) {
      return branch.name.en.isNotEmpty ? branch.name.en : branch.branchCode;
    }
    return 'Unknown Warehouse';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Indents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadIndents(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push('/brands/${widget.brandId}/inventory/indents/create'),
            icon: const Icon(Icons.add),
            label: const Text('New Indent'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.indents.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null && controller.indents.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load indents',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadIndents(),
          );
        }

        if (controller.indents.isEmpty) {
          return AppEmptyState(
            icon: Icons.assignment_outlined,
            title: 'No indents yet',
            subtitle: 'Create purchase indents to request stock items from another branch or central warehouse.',
            actionLabel: 'New Indent',
            onAction: () => context.push('/brands/${widget.brandId}/inventory/indents/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadIndents(),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: controller.indents.length,
            itemBuilder: (context, idx) {
              final indent = controller.indents[idx];
              final isDraft = indent.status == 'draft';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primary.withOpacity(0.1),
                    child: Icon(Icons.assignment, color: cs.primary),
                  ),
                  title: Text(indent.indentNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('From: ${_getWarehouseName(indent.fromWarehouseId)}\nTo: ${_getWarehouseName(indent.toWarehouseId)}\nDate: ${DateFormat('yyyy-MM-dd').format(indent.indentDate)}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDraft ? Colors.grey[200] : Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          indent.status.toUpperCase(),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDraft ? Colors.grey[800] : Colors.green[800]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(isDraft ? Icons.edit_outlined : Icons.visibility_outlined),
                        onPressed: () => context.push('/brands/${widget.brandId}/inventory/indents/${indent.id}/edit'),
                      ),
                      if (isDraft)
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: cs.error),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Indent?'),
                                content: Text('Are you sure you want to delete "${indent.indentNo}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await controller.deleteIndent(indent.id);
                            }
                          },
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
}
