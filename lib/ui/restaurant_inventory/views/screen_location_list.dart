import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/location_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';

class ScreenLocationList extends StatefulWidget {
  final String brandId;
  const ScreenLocationList({super.key, required this.brandId});

  @override
  State<ScreenLocationList> createState() => _ScreenLocationListState();
}

class _ScreenLocationListState extends State<ScreenLocationList> {
  late final LocationController controller;
  late final MongoBranchController branchController;

  @override
  void initState() {
    super.initState();
    controller =
        Get.put(LocationController(repository: LocationRepositoryImpl()));
    branchController = Get.put(
        MongoBranchController(repository: MongoBranchRepositoryImpl()));
    controller.loadLocations();
    branchController.loadBranches();
  }

  @override
  void dispose() {
    Get.delete<LocationController>();
    Get.delete<MongoBranchController>();
    super.dispose();
  }

  String _getBranchName(String? branchId) {
    if (branchId == null) return 'Central Inventory';
    final branch =
        branchController.branches.firstWhereOrNull((b) => b.id == branchId);
    if (branch != null) {
      return branch.name.en.isNotEmpty ? branch.name.en : branch.branchCode;
    }
    return 'Unknown Branch';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surface,
        scrolledUnderElevation: 1,
        title: const Text('Inventory Locations',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              controller.loadLocations();
              branchController.loadBranches();
            },
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context
                .push('/brands/${widget.brandId}/inventory/warehouses/create'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New Location'),
            style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.locations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null &&
            controller.locations.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load locations',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () {
              controller.loadLocations();
              branchController.loadBranches();
            },
          );
        }
        if (controller.locations.isEmpty) {
          return AppEmptyState(
            icon: Icons.warehouse_outlined,
            title: 'No locations yet',
            subtitle:
                'Add inventory locations like main warehouse, kitchen store, cold storage, etc.',
            actionLabel: 'Add Location',
            onAction: () => context.push(
                '/brands/${widget.brandId}/inventory/warehouses/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.loadLocations();
            branchController.loadBranches();
          },
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
            itemCount: controller.locations.length,
            itemBuilder: (context, index) {
              final loc = controller.locations[index];
              return AppListCard(
                icon: Icons.warehouse_rounded,
                iconColor: Colors.indigo.shade500,
                title: loc.locationName,
                ref: loc.locationCode,
                lines: [
                  'Type: ${loc.locationType.toUpperCase()}  •  Branch: ${_getBranchName(loc.branchId)}',
                ],
                actions: [
                  AppListCardAction(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit',
                    onTap: () => context.push(
                        '/brands/${widget.brandId}/inventory/warehouses/${loc.id}/edit'),
                  ),
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
                          title: const Text('Delete Location?'),
                          content: Text(
                              'Delete "${loc.locationName}"? This cannot be undone.'),
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
                        final ok = await controller.deleteLocation(loc.id);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok ? 'Location deleted' : 'Failed'),
                          backgroundColor: ok ? Colors.green : cs.error,
                        ));
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
