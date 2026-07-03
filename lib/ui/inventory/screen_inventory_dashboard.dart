import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/shared/shared.dart';

class ScreenInventoryDashboard extends StatelessWidget {
  final String brandId;

  const ScreenInventoryDashboard({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final modules = _inventoryModules(context, brandId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.primary.withValues(alpha: 0.15), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inventory Management',
                          style: tt.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900, color: cs.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage items, categories, units, and storage locations',
                          style: tt.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // ── Module grid ──────────────────────────────────────────────────
            Text(
              'Modules',
              style: tt.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppSpacing.md),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final mod = modules[index];
                return _ModuleCard(
                  module: mod,
                  onTap: () => context.push(mod.route),
                );
              },
            ),

            SizedBox(height: AppSpacing.lg),

            // ── Quick tips ───────────────────────────────────────────────────
            Text(
              'Getting Started',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppSpacing.sm),
            _TipCard(
              step: '1',
              title: 'Set up Categories',
              subtitle: 'Group your items into categories like Beverages, Meat, Dairy.',
              color: cs.primary,
              onTap: () => context.push('/brands/$brandId/inventory/categories'),
            ),
            SizedBox(height: AppSpacing.sm),
            _TipCard(
              step: '2',
              title: 'Define Units',
              subtitle: 'Set up units of measurement like kg, litre, piece.',
              color: cs.primary.withValues(alpha: 0.8),
              onTap: () => context.push('/brands/$brandId/inventory/units'),
            ),
            SizedBox(height: AppSpacing.sm),
            _TipCard(
              step: '3',
              title: 'Add Warehouses',
              subtitle: 'Define your storage locations — kitchen store, cold room, etc.',
              color: cs.primary.withValues(alpha: 0.6),
              onTap: () => context.push('/brands/$brandId/inventory/warehouses'),
            ),
            SizedBox(height: AppSpacing.sm),
            _TipCard(
              step: '4',
              title: 'Create Items',
              subtitle: 'Add your products with pricing, stock levels, and alerts.',
              color: cs.primary.withValues(alpha: 0.45),
              onTap: () => context.push('/brands/$brandId/inventory/items'),
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  List<_InventoryModule> _inventoryModules(BuildContext context, String brandId) {
    final cs = Theme.of(context).colorScheme;
    return [
      _InventoryModule(
        title: 'Items',
        subtitle: 'Product master list',
        icon: Icons.inventory_2_outlined,
        color: cs.primary,
        route: '/brands/$brandId/inventory/items',
      ),
      _InventoryModule(
        title: 'Categories',
        subtitle: 'Item groupings',
        icon: Icons.category_outlined,
        color: cs.primary.withValues(alpha: 0.85),
        route: '/brands/$brandId/inventory/categories',
      ),
      _InventoryModule(
        title: 'Units',
        subtitle: 'UoM (kg, L, pc…)',
        icon: Icons.straighten_outlined,
        color: cs.primary.withValues(alpha: 0.7),
        route: '/brands/$brandId/inventory/units',
      ),
      _InventoryModule(
        title: 'Warehouses',
        subtitle: 'Storage locations',
        icon: Icons.warehouse_outlined,
        color: cs.primary.withValues(alpha: 0.55),
        route: '/brands/$brandId/inventory/warehouses',
      ),
      _InventoryModule(
        title: 'Suppliers',
        subtitle: 'Vendor contact directory',
        icon: Icons.people_outline,
        color: cs.secondary,
        route: '/brands/$brandId/inventory/suppliers',
      ),
      _InventoryModule(
        title: 'Stock In',
        subtitle: 'Receive purchase stock',
        icon: Icons.download_rounded,
        color: cs.secondary.withValues(alpha: 0.8),
        route: '/brands/$brandId/inventory/purchases',
      ),
      _InventoryModule(
        title: 'Adjustments',
        subtitle: 'Manual stock corrections',
        icon: Icons.edit_note_outlined,
        color: cs.secondary.withValues(alpha: 0.65),
        route: '/brands/$brandId/inventory/adjustments',
      ),
      _InventoryModule(
        title: 'Transfers',
        subtitle: 'Warehouse movements',
        icon: Icons.compare_arrows_outlined,
        color: cs.secondary.withValues(alpha: 0.5),
        route: '/brands/$brandId/inventory/transfers',
      ),
      _InventoryModule(
        title: 'Reports',
        subtitle: 'Analytics & valuations',
        icon: Icons.analytics_outlined,
        color: cs.tertiary,
        route: '/brands/$brandId/inventory/reports',
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InventoryModule {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _InventoryModule({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _ModuleCard extends StatelessWidget {
  final _InventoryModule module;
  final VoidCallback onTap;

  const _ModuleCard({required this.module, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: module.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(module.icon, color: module.color, size: 24),
              ),
              const Spacer(),
              Text(
                module.title,
                style: tt.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                module.subtitle,
                style: tt.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _TipCard({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    step,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.outline),
            ],
          ),
        ),
      ),
    );
  }
}
