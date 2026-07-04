import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_group_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';

class ScreenGroupList extends StatefulWidget {
  final String brandId;
  const ScreenGroupList({super.key, required this.brandId});

  @override
  State<ScreenGroupList> createState() => _ScreenGroupListState();
}

class _ScreenGroupListState extends State<ScreenGroupList> {
  late final RawMaterialGroupController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RawMaterialGroupController(repository: RawMaterialGroupRepositoryImpl()));
    controller.loadGroups();
  }

  @override
  void dispose() {
    Get.delete<RawMaterialGroupController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raw Material Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => controller.loadGroups(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push('/brands/${widget.brandId}/inventory/groups/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Group'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.groups.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null && controller.groups.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load groups',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadGroups(),
          );
        }

        if (controller.groups.isEmpty) {
          return AppEmptyState(
            icon: Icons.category_outlined,
            title: 'No groups yet',
            subtitle: 'Add groups/categories of raw materials like Meat, Vegetables, Packaging materials, etc.',
            actionLabel: 'Add Group',
            onAction: () => context.push('/brands/${widget.brandId}/inventory/groups/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadGroups(),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: controller.groups.length,
            itemBuilder: (context, index) {
              final group = controller.groups[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.secondary.withOpacity(0.1),
                    child: Icon(Icons.folder_open, color: cs.secondary),
                  ),
                  title: Text(group.groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Code: ${group.groupCode} • Desc: ${group.description ?? "N/A"} • Status: ${group.isActive ? "Active" : "Inactive"}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => context.push('/brands/${widget.brandId}/inventory/groups/${group.id}/edit'),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: cs.error),
                        onPressed: () => _confirmDelete(context, group),
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

  void _confirmDelete(BuildContext context, RawMaterialGroupModel group) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Group?'),
        content: Text('Are you sure you want to delete "${group.displayLabel}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await controller.deleteGroup(group.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Group deleted successfully'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(controller.errorMessage.value ?? 'Failed to delete group'), backgroundColor: cs.error),
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
