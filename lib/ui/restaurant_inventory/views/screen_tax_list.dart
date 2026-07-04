import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/data/models/restaurant_inventory/raw_material_tax_model.dart';
import 'package:back_office/ui/restaurant_inventory/controllers/master_controllers.dart';
import 'package:back_office/data/repositories/restaurant_inventory/master_repositories.dart';

class ScreenTaxList extends StatefulWidget {
  final String brandId;
  const ScreenTaxList({super.key, required this.brandId});

  @override
  State<ScreenTaxList> createState() => _ScreenTaxListState();
}

class _ScreenTaxListState extends State<ScreenTaxList> {
  late final RawMaterialTaxController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RawMaterialTaxController(repository: RawMaterialTaxRepositoryImpl()));
    controller.loadTaxes();
  }

  @override
  void dispose() {
    Get.delete<RawMaterialTaxController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raw Material Taxes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => controller.loadTaxes(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.push('/brands/${widget.brandId}/inventory/taxes/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Tax'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.taxes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null && controller.taxes.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load taxes',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: () => controller.loadTaxes(),
          );
        }

        if (controller.taxes.isEmpty) {
          return AppEmptyState(
            icon: Icons.percent,
            title: 'No taxes defined yet',
            subtitle: 'Define taxes applied on raw materials (e.g. VAT 5%, Service Tax, etc.)',
            actionLabel: 'Add Tax',
            onAction: () => context.push('/brands/${widget.brandId}/inventory/taxes/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadTaxes(),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: controller.taxes.length,
            itemBuilder: (context, index) {
              final tax = controller.taxes[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primary.withOpacity(0.1),
                    child: Icon(Icons.percent, color: cs.primary),
                  ),
                  title: Text(tax.taxName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Value: ${tax.taxValue}${tax.taxType == 'percentage' ? '%' : ' Fixed'} • Applies On: ${tax.appliesOn.toUpperCase()} • Include in Rate: ${tax.includeInRate ? "Yes" : "No"}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => context.push('/brands/${widget.brandId}/inventory/taxes/${tax.id}/edit'),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: cs.error),
                        onPressed: () => _confirmDelete(context, tax),
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

  void _confirmDelete(BuildContext context, RawMaterialTaxModel tax) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Tax?'),
        content: Text('Are you sure you want to delete "${tax.displayLabel}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await controller.deleteTax(tax.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tax deleted successfully'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(controller.errorMessage.value ?? 'Failed to delete tax'), backgroundColor: cs.error),
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
