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
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surface,
        scrolledUnderElevation: 1,
        title: const Text('Units of Measurement',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => controller.loadUnits(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context
                .push('/brands/${widget.brandId}/inventory/units/create'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New Unit'),
            style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
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
            icon: Icons.error_outline_rounded,
            title: 'Failed to load units',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadUnits(),
          );
        }
        if (controller.units.isEmpty) {
          return AppEmptyState(
            icon: Icons.straighten_rounded,
            title: 'No units yet',
            subtitle: 'Add units of measurement like kg, litre, piece, etc.',
            actionLabel: 'Add Unit',
            onAction: () => context
                .push('/brands/${widget.brandId}/inventory/units/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadUnits(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
            itemCount: controller.units.length,
            itemBuilder: (context, index) {
              final unit = controller.units[index];
              final isActive = unit.isActive;
              return AppListCard(
                icon: Icons.straighten_rounded,
                iconColor: cs.primary,
                title: unit.unitName,
                ref: unit.shortName,
                lines: [
                  'Decimal: ${unit.decimalAllowed ? "Allowed" : "Not Allowed"}  •  ${isActive ? "Active" : "Inactive"}',
                ],
                status: AppListCardStatus(
                  label: isActive ? 'Active' : 'Inactive',
                  color: isActive ? Colors.green.shade600 : Colors.grey,
                ),
                actions: [
                  AppListCardAction(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit',
                    onTap: () => context.push(
                        '/brands/${widget.brandId}/inventory/units/${unit.id}/edit'),
                  ),
                  AppListCardAction(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete',
                    color: cs.error,
                    onTap: () => _confirmDelete(context, unit),
                  ),
                ],
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
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Unit?'),
        content: Text(
            'Are you sure you want to delete "${unit.displayLabel}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await controller.deleteUnit(unit.id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? 'Unit deleted successfully'
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
