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
    controller = Get.put(LocationController(repository: LocationRepositoryImpl()));
    branchController = Get.put(MongoBranchController(repository: MongoBranchRepositoryImpl()));
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
    final branch = branchController.branches.firstWhereOrNull((b) => b.id == branchId);
    if (branch != null) {
      return branch.name.en.isNotEmpty ? branch.name.en : branch.branchCode;
    }
    return 'Unknown Branch';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Locations / Warehouses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              controller.loadLocations();
              branchController.loadBranches();
            },
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push('/brands/${widget.brandId}/inventory/warehouses/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Location'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.locations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null && controller.locations.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
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
            subtitle: 'Add inventory locations like main warehouse, kitchen store, cold storage, etc.',
            actionLabel: 'Add Location',
            onAction: () => context.push('/brands/${widget.brandId}/inventory/warehouses/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.loadLocations();
            branchController.loadBranches();
          },
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: controller.locations.length,
            itemBuilder: (context, index) {
              final loc = controller.locations[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primary.withOpacity(0.1),
                    child: Icon(Icons.warehouse, color: cs.primary),
                  ),
                  title: Text(loc.locationName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Code: ${loc.locationCode} • Type: ${loc.locationType.toUpperCase()}\nBranch: ${_getBranchName(loc.branchId)}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => context.push('/brands/${widget.brandId}/inventory/warehouses/${loc.id}/edit'),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: cs.error),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Location?'),
                              content: Text('Are you sure you want to delete "${loc.locationName}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final success = await controller.deleteLocation(loc.id);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Location deleted'), backgroundColor: Colors.green),
                              );
                            }
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
