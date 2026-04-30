import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/branch_repository_impl.dart';
import 'package:back_office/ui/branch/branch_list/cubit_branch.dart';
import 'package:back_office/ui/branch/branch_list/state_branch.dart';

class ScreenBranchList extends StatelessWidget {
  final String brandId;

  const ScreenBranchList({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CubitBranch(repository: BranchRepositoryImpl())..loadBranches(brandId),
      child: _BranchListView(brandId: brandId),
    );
  }
}

class _BranchListView extends StatelessWidget {
  final String brandId;

  const _BranchListView({required this.brandId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branches'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/brands/$brandId'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/brands/$brandId/branches/create'),
          ),
        ],
      ),
      body: BlocBuilder<CubitBranch, StateBranch>(
        builder: (context, state) {
          if (state.status == BranchStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BranchStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Error loading branches'),
                  SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => context.read<CubitBranch>().loadBranches(brandId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.branches.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_city_outlined, size: 64, color: cs.outline),
                  SizedBox(height: AppSpacing.md),
                  Text('No branches found', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: AppSpacing.sm),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/brands/$brandId/branches/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Branch'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CubitBranch>().loadBranches(brandId);
            },
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: state.branches.length,
              itemBuilder: (context, index) {
                final branch = state.branches[index];
                return Card(
                  margin: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cs.primaryContainer,
                      child: const Icon(Icons.store),
                    ),
                    title: Text(branch.displayName),
                    subtitle: Text(branch.city.isEmpty ? 'No city' : branch.city),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: branch.isActive ? Colors.green.shade100 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            branch.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              color: branch.isActive ? Colors.green.shade700 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => context.go('/brands/$brandId/branches/${branch.id}'),
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