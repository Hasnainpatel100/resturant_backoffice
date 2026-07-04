import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';

class ScreenMaterialList extends StatefulWidget {
  final String brandId;
  const ScreenMaterialList({super.key, required this.brandId});

  @override
  State<ScreenMaterialList> createState() => _ScreenMaterialListState();
}

class _ScreenMaterialListState extends State<ScreenMaterialList> {
  late final RawMaterialController controller;
  late final RawMaterialGroupController groupController;
  late final UnitController unitController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RawMaterialController(repository: RawMaterialRepositoryImpl()));
    groupController = Get.put(RawMaterialGroupController(repository: RawMaterialGroupRepositoryImpl()));
    unitController = Get.put(UnitController(repository: UnitRepositoryImpl()));

    controller.loadMaterials();
    groupController.loadGroups();
    unitController.loadUnits();
  }

  @override
  void dispose() {
    Get.delete<RawMaterialController>();
    super.dispose();
  }

  String _getGroupName(String groupId) {
    final group = groupController.groups.firstWhereOrNull((g) => g.id == groupId);
    return group?.groupName ?? 'Unknown Group';
  }

  String _getUnitName(String unitId) {
    final unit = unitController.units.firstWhereOrNull((u) => u.id == unitId);
    return unit?.shortName ?? 'pcs';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raw Materials & Ingredients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              controller.loadMaterials();
              groupController.loadGroups();
              unitController.loadUnits();
            },
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push('/brands/${widget.brandId}/inventory/items/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Material'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.materials.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null && controller.materials.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load raw materials',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadMaterials(),
          );
        }

        if (controller.materials.isEmpty) {
          return AppEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No raw materials yet',
            subtitle: 'Add raw ingredients and materials like Flour, Sugar, Chicken breasts, etc.',
            actionLabel: 'Add Raw Material',
            onAction: () => context.push('/brands/${widget.brandId}/inventory/items/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadMaterials();
          },
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: controller.materials.length,
            itemBuilder: (context, index) {
              final mat = controller.materials[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primary.withOpacity(0.1),
                    child: Icon(Icons.eco, color: cs.primary),
                  ),
                  title: Text(mat.materialName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Code: ${mat.materialCode} • Group: ${_getGroupName(mat.groupId)} • Base Unit: ${_getUnitName(mat.baseUnitId)} • Rate: \$${mat.purchaseRate}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => context.push('/brands/${widget.brandId}/inventory/items/${mat.id}/edit'),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: cs.error),
                        onPressed: () => _confirmDelete(context, mat),
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

  void _confirmDelete(BuildContext context, RawMaterialModel mat) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Raw Material?'),
        content: Text('Are you sure you want to delete "${mat.displayLabel}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await controller.deleteMaterial(mat.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Raw material deleted successfully'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(controller.errorMessage.value ?? 'Failed to delete material'), backgroundColor: cs.error),
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
