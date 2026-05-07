import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/brand_repository_impl.dart';
import 'package:back_office/data/repositories/branch_repository_impl.dart';
import 'package:back_office/ui/brand/brand_list/cubit_brand.dart';
import 'package:back_office/ui/brand/brand_list/state_brand.dart';
import 'package:back_office/ui/branch/branch_list/cubit_branch.dart';
import 'package:back_office/ui/branch/branch_list/state_branch.dart';
import 'package:back_office/routing/app_routes.dart';
import 'package:back_office/data/models/brand_model.dart';
import 'package:back_office/shared/shared.dart';

class ScreenBrandDetail extends StatelessWidget {
  final String brandId;

  const ScreenBrandDetail({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CubitBrand(repository: BrandRepositoryImpl())..loadBrand(brandId),
        ),
        BlocProvider(
          create: (context) => CubitBranch(repository: BranchRepositoryImpl())..loadBranches(brandId),
        ),
      ],
      child: _BrandDetailView(brandId: brandId),
    );
  }
}

class _BrandDetailView extends StatelessWidget {
  final String brandId;

  const _BrandDetailView({required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<CubitBrand, StateBrand>(
      listener: (context, state) {
        if (state.status == BrandStatus.success && state.brand == null) {
          // Brand was deleted
          showToast(context, message: 'Brand deleted', status: 'success');
          context.go(AppRoutes.brandList);
        }
        if (state.status == BrandStatus.error) {
          showToast(context, message: state.errorMessage ?? 'Error', status: 'error');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Brand Details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(AppRoutes.brandList),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Brand',
                onPressed: () => context.go('/brands/$brandId/edit'),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: cs.error),
                tooltip: 'Delete Brand',
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, StateBrand state) {
    final cs = Theme.of(context).colorScheme;

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
            Text(state.errorMessage ?? 'Error', style: TextStyle(color: cs.error)),
            SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: () => context.read<CubitBrand>().loadBrand(brandId),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final brand = state.brand;
    if (brand == null) {
      return const Center(child: Text('Brand not found'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Brand Header Card ──
          _BrandHeaderCard(brand: brand),

          SizedBox(height: AppSpacing.md),

          // ── Contact Information ──
          _DetailSection(
            icon: Icons.contact_phone,
            title: 'Contact Information',
            color: Colors.teal,
            children: [
              _InfoRow(icon: Icons.email_outlined, label: 'Email', value: brand.contact.email),
              _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: brand.contact.phones.primary),
              _InfoRow(icon: Icons.language, label: 'Website', value: brand.contact.website),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // ── Registration ──
          _DetailSection(
            icon: Icons.description,
            title: 'Registration',
            color: Colors.orange,
            children: [
              _InfoRow(icon: Icons.receipt_long, label: 'GST No', value: brand.registration.gstNo),
              _InfoRow(icon: Icons.verified_outlined, label: 'FSSAI No', value: brand.registration.fssaiNo),
              if (brand.registration.cin.isNotEmpty)
                _InfoRow(icon: Icons.business_center, label: 'CIN', value: brand.registration.cin),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // ── Settings ──
          _DetailSection(
            icon: Icons.settings,
            title: 'Settings',
            color: Colors.purple,
            children: [
              _InfoRow(icon: Icons.currency_rupee, label: 'Currency', value: brand.settings.currency),
              _InfoRow(icon: Icons.schedule, label: 'Timezone', value: brand.settings.timezone),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // ── Branches ──
          _BranchesSection(brandId: brandId),

          SizedBox(height: AppSpacing.md),

          // ── Quick Actions ──
          Text('Quick Actions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.people,
                  label: 'Users',
                  color: Colors.indigo,
                  onTap: () => context.go('/brands/$brandId/users'),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.restaurant_menu,
                  label: 'Menu',
                  color: Colors.deepOrange,
                  onTap: () => context.go('/brands/$brandId/menu'),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.table_restaurant,
                  label: 'Tables',
                  color: Colors.teal,
                  onTap: () => context.go('/brands/$brandId/tables'),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.bed,
                  label: 'Room Types',
                  color: Colors.purple,
                  onTap: () => context.go('/brands/$brandId/room-types'),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.tablet_android,
                  label: 'POS Devices',
                  color: Colors.blue,
                  onTap: () => context.go('/brands/$brandId/pos-devices'),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Brand?'),
        content: const Text(
          'This will permanently delete this brand and all associated data.\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CubitBrand>().deleteBrand(brandId);
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Delete Brand'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Brand header card

class _BrandHeaderCard extends StatelessWidget {
  final BrandModel brand;

  const _BrandHeaderCard({required this.brand});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _statusColor(brand.status);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(height: 4, color: statusColor),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary.withOpacity(0.8), cs.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      brand.displayName[0].toUpperCase(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      if (brand.branchCode.isNotEmpty)
                        Text(
                          'Code: ${brand.branchCode}',
                          style: TextStyle(color: cs.outline, fontSize: 13),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    brand.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
// Detail section

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<Widget> children;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info row

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.outline),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: cs.outline, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                color: value.isEmpty ? cs.outline : cs.onSurface,
                fontWeight: value.isEmpty ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Branches section

class _BranchesSection extends StatelessWidget {
  final String brandId;

  const _BranchesSection({required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.location_city, color: Colors.blue, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Branches',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.go('/brands/$brandId/branches'),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            BlocBuilder<CubitBranch, StateBranch>(
              builder: (context, branchState) {
                if (branchState.status == BranchStatus.loading) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (branchState.branches.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        Icon(Icons.location_city_outlined, size: 32, color: cs.outline),
                        const SizedBox(height: 8),
                        Text('No branches', style: TextStyle(color: cs.outline)),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/brands/$brandId/branches/create'),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Branch'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: branchState.branches.take(3).map((branch) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: branch.isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.store,
                          size: 18,
                          color: branch.isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                      title: Text(branch.displayName),
                      subtitle: Text(
                        branch.city.isEmpty ? 'No city' : branch.city,
                        style: TextStyle(color: cs.outline, fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: branch.isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, size: 20),
                        ],
                      ),
                      onTap: () => context.go('/brands/$brandId/branches/${branch.id}'),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick action card

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}