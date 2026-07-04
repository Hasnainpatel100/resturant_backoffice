import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/unit_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';

class ScreenUnitList extends StatefulWidget {
  final String brandId;
  const ScreenUnitList({super.key, required this.brandId});

  @override
  State<ScreenUnitList> createState() => _ScreenUnitListState();
}

class _ScreenUnitListState extends State<ScreenUnitList> {
  late final UnitController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(UnitController(repository: UnitRepositoryImpl()));
    controller.loadUnits();
  }

  @override
  void dispose() {
    Get.delete<UnitController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Units of Measurement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => controller.loadUnits(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push('/brands/${widget.brandId}/inventory/units/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Unit'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.units.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null && controller.units.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load units',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadUnits(),
          );
        }

        if (controller.units.isEmpty) {
          return AppEmptyState(
            icon: Icons.straighten_outlined,
            title: 'No units yet',
            subtitle: 'Add units of measurement like kg, litre, piece, etc.',
            actionLabel: 'Add Unit',
            onAction: () => context.push('/brands/${widget.brandId}/inventory/units/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadUnits(),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: controller.units.length,
            itemBuilder: (context, index) {
              final unit = controller.units[index];
              return Card(
                child: ListTile(
                  title: Text(unit.unitName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Code: ${unit.shortName} • Decimal: ${unit.decimalAllowed ? "Allowed" : "Not Allowed"} • Status: ${unit.isActive ? "Active" : "Inactive"}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => context.push('/brands/${widget.brandId}/inventory/units/${unit.id}/edit'),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: cs.error),
                        onPressed: () => _confirmDelete(context, unit),
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

  void _confirmDelete(BuildContext context, UnitModel unit) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Unit?'),
        content: Text('Are you sure you want to delete "${unit.displayLabel}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await controller.deleteUnit(unit.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unit deleted successfully'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(controller.errorMessage.value ?? 'Failed to delete unit'), backgroundColor: cs.error),
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
