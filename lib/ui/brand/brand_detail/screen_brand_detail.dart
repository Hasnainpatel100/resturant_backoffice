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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.brandList),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/brands/$brandId/edit'),
          ),
        ],
      ),
      body: BlocBuilder<CubitBrand, StateBrand>(
        builder: (context, state) {
          if (state.status == BrandStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BrandStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Error'));
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
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: cs.primaryContainer,
                              child: Text(
                                brand.displayName[0].toUpperCase(),
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    brand.displayName,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    'Status: ${brand.status.name}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact Information', style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: AppSpacing.sm),
                        _InfoRow(label: 'Email', value: brand.contact.email),
                        _InfoRow(label: 'Phone', value: brand.contact.phones.primary),
                        _InfoRow(label: 'Website', value: brand.contact.website),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Branches', style: Theme.of(context).textTheme.titleMedium),
                            TextButton.icon(
                              onPressed: () => context.go('/brands/$brandId/branches'),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add'),
                            ),
                          ],
                        ),
                        BlocBuilder<CubitBranch, StateBranch>(
                          builder: (context, branchState) {
                            if (branchState.status == BranchStatus.loading) {
                              return Padding(
                                padding: EdgeInsets.all(AppSpacing.md),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            if (branchState.branches.isEmpty) {
                              return Padding(
                                padding: EdgeInsets.all(AppSpacing.md),
                                child: Text('No branches', style: TextStyle(color: cs.outline)),
                              );
                            }

                            return Column(
                              children: branchState.branches.take(3).map((branch) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(branch.displayName),
                                  subtitle: Text(branch.city),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => context.go('/brands/$brandId/branches/${branch.id}'),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.people,
                        label: 'Users',
                        onTap: () => context.go('/brands/$brandId/users'),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.restaurant_menu,
                        label: 'Menu',
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
                        onTap: () => context.go('/brands/$brandId/tables'),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.bed,
                        label: 'Room Types',
                        onTap: () => context.go('/brands/$brandId/room-types'),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.tablet_android,
                        label: 'POS Devices',
                        onTap: () => context.go('/brands/$brandId/pos-devices'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Icon(icon, size: 32, color: cs.primary),
              SizedBox(height: AppSpacing.sm),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}