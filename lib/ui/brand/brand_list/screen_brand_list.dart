import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/brand_repository_impl.dart';
import 'package:back_office/ui/brand/brand_list/cubit_brand.dart';
import 'package:back_office/ui/brand/brand_list/state_brand.dart';
import 'package:back_office/routing/app_routes.dart';

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
            icon: const Icon(Icons.add),
            onPressed: () => context.go(AppRoutes.brandCreate),
          ),
        ],
      ),
      body: BlocBuilder<CubitBrand, StateBrand>(
        builder: (context, state) {
          if (state.status == BrandStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BrandStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Error loading brands'),
                  SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => context.read<CubitBrand>().loadBrands(),
                    child: const Text('Retry'),
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
                  Icon(Icons.store_outlined, size: 64, color: cs.outline),
                  SizedBox(height: AppSpacing.md),
                  Text('No brands found', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: AppSpacing.sm),
                  ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.brandCreate),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Brand'),
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
                return Card(
                  margin: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cs.primaryContainer,
                      child: Text(brand.displayName[0].toUpperCase()),
                    ),
                    title: Text(brand.displayName),
                    subtitle: Text(brand.status.name.toUpperCase()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/brands/${brand.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}