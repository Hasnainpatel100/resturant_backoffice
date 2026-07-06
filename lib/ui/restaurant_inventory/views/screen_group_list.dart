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
    controller = Get.put(
        RawMaterialGroupController(repository: RawMaterialGroupRepositoryImpl()));
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
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surface,
        scrolledUnderElevation: 1,
        title: const Text('Raw Material Groups',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => controller.loadGroups(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context
                .push('/brands/${widget.brandId}/inventory/groups/create'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New Group'),
            style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
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
            icon: Icons.error_outline_rounded,
            title: 'Failed to load groups',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadGroups(),
          );
        }
        if (controller.groups.isEmpty) {
          return AppEmptyState(
            icon: Icons.folder_outlined,
            title: 'No groups yet',
            subtitle:
                'Add categories like Meat, Vegetables, Packaging, etc.',
            actionLabel: 'Add Group',
            onAction: () => context
                .push('/brands/${widget.brandId}/inventory/groups/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadGroups(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
            itemCount: controller.groups.length,
            itemBuilder: (context, index) {
              final group = controller.groups[index];
              return AppListCard(
                icon: Icons.folder_rounded,
                iconColor: cs.secondary,
                title: group.groupName,
                ref: group.groupCode,
                lines: [
                  group.description ?? 'No description',
                ],
                status: AppListCardStatus(
                  label: group.isActive ? 'Active' : 'Inactive',
                  color:
                      group.isActive ? Colors.green.shade600 : Colors.grey,
                ),
                actions: [
                  AppListCardAction(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit',
                    onTap: () => context.push(
                        '/brands/${widget.brandId}/inventory/groups/${group.id}/edit'),
                  ),
                  AppListCardAction(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete',
                    color: cs.error,
                    onTap: () => _confirmDelete(context, group),
                  ),
                ],
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
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Group?'),
        content: Text(
            'Are you sure you want to delete "${group.displayLabel}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await controller.deleteGroup(group.id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? 'Group deleted successfully'
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
