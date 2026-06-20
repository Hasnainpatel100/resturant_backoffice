import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/brand_repository_impl.dart';
import 'package:back_office/ui/brand/brand_list/cubit_brand.dart';
import 'package:back_office/ui/brand/brand_list/state_brand.dart';
import 'package:back_office/routing/app_routes.dart';
import 'package:back_office/data/models/brand_model.dart';

class ScreenBrandList extends StatelessWidget {
  const ScreenBrandList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CubitBrand(repository: BrandRepositoryImpl())..loadBrands(),
      child: const _BrandListView(),
    );
  }
}

class _BrandListView extends StatelessWidget {
  const _BrandListView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brands'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CubitBrand>().loadBrands(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.brandCreate),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Brand'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocConsumer<CubitBrand, StateBrand>(
        listener: (context, state) {
          if (state.status == BrandStatus.success) {
            // Reload after delete
            context.read<CubitBrand>().loadBrands();
          }
        },
        builder: (context, state) {
          if (state.status == BrandStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BrandStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 56, color: cs.error),
                  SizedBox(height: AppSpacing.md),
                  Text(state.errorMessage ?? 'Error loading brands',
                      style: TextStyle(color: cs.error)),
                  SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: () => context.read<CubitBrand>().loadBrands(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.brands.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.store_outlined, size: 64, color: cs.primary),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text('No brands yet',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  SizedBox(height: AppSpacing.sm),
                  Text('Create your first brand to get started',
                      style: TextStyle(color: cs.outline)),
                  SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.brandCreate),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Brand'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CubitBrand>().loadBrands();
            },
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: state.brands.length,
              itemBuilder: (context, index) {
                final brand = state.brands[index];
                return _BrandCard(
                  brand: brand,
                  onTap: () => context.go('/brands/${brand.id}'),
                  onDelete: () => _confirmDelete(context, brand),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, BrandBasicModel brand) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Brand?'),
        content: Text(
          'Are you sure you want to delete "${brand.displayName}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CubitBrand>().deleteBrand(brand.id);
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _BrandCard extends StatelessWidget {
  final BrandBasicModel brand;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BrandCard({
    required this.brand,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _statusColor(brand.status);

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            // Color accent strip
            Container(height: 3, color: statusColor),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primary.withOpacity(0.8),
                          cs.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        brand.displayName[0].toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          brand.displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        _StatusBadge(status: brand.status),
                      ],
                    ),
                  ),
                  // Actions
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: cs.outline),
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.go('/brands/${brand.id}/edit');
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: cs.error),
                          title: Text('Delete', style: TextStyle(color: cs.error)),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
        return Colors.green;
      case AccountStatus.inactive:
        return Colors.grey;
      case AccountStatus.suspended:
        return Colors.red;
      case AccountStatus.pending:
        return Colors.orange;
    }
  }
}

// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final AccountStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case AccountStatus.active:
        color = Colors.green;
        label = 'Active';
        break;
      case AccountStatus.inactive:
        color = Colors.grey;
        label = 'Inactive';
        break;
      case AccountStatus.suspended:
        color = Colors.red;
        label = 'Suspended';
        break;
      case AccountStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}