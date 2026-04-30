import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/branch_repository_impl.dart';
import 'package:back_office/ui/branch/branch_list/cubit_branch.dart';
import 'package:back_office/ui/branch/branch_list/state_branch.dart';

class ScreenBranchDetail extends StatelessWidget {
  final String brandId;
  final String branchId;

  const ScreenBranchDetail({super.key, required this.brandId, required this.branchId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CubitBranch(repository: BranchRepositoryImpl())..loadBranch(branchId),
      child: _BranchDetailView(brandId: brandId, branchId: branchId),
    );
  }
}

class _BranchDetailView extends StatelessWidget {
  final String brandId;
  final String branchId;

  const _BranchDetailView({required this.brandId, required this.branchId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/brands/$brandId/branches'),
        ),
      ),
      body: BlocBuilder<CubitBranch, StateBranch>(
        builder: (context, state) {
          if (state.status == BranchStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BranchStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Error'));
          }

          final branch = state.branch;
          if (branch == null) {
            return const Center(child: Text('Branch not found'));
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
                                branch.displayName[0].toUpperCase(),
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(branch.displayName, style: Theme.of(context).textTheme.titleLarge),
                                  Text('Branch Code: ${branch.branchCode}', style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.md),
                        Chip(
                          label: Text(branch.isActive ? 'Active' : 'Inactive'),
                          backgroundColor: branch.isActive ? Colors.green.shade100 : Colors.grey.shade200,
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
                        Text('Contact', style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: AppSpacing.sm),
                        _InfoRow(label: 'Phone', value: branch.contact.phones.primary),
                        _InfoRow(label: 'Email', value: branch.contact.email),
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
                        Text('Address', style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: AppSpacing.sm),
                        Text(branch.address.full.isEmpty ? 'No address' : branch.address.full),
                        if (branch.address.city.isNotEmpty) ...[
                          SizedBox(height: AppSpacing.xs),
                          Text('${branch.address.city}, ${branch.address.state} ${branch.address.zipCode}'),
                        ],
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
                        Text('Hours', style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: AppSpacing.sm),
                        Text(branch.settings.isMasterBranch ? 'Master Branch' : 'Regular Branch'),
                        if (branch.settings.open.isNotEmpty)
                          _InfoRow(label: 'Opens', value: branch.settings.open),
                        if (branch.settings.close.isNotEmpty)
                          _InfoRow(label: 'Closes', value: branch.settings.close),
                      ],
                    ),
                  ),
                ),
                if (branch.planDetails != null) ...[
                  SizedBox(height: AppSpacing.md),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Plan', style: Theme.of(context).textTheme.titleMedium),
                          SizedBox(height: AppSpacing.sm),
                          _InfoRow(label: 'Max Users', value: '${branch.planDetails!.maxUsers}'),
                          _InfoRow(label: 'Max Devices', value: '${branch.planDetails!.maxPosDevices}'),
                          _InfoRow(
                            label: 'Expires',
                            value: branch.planDetails!.expiryDate?.toString().split(' ')[0] ?? '-',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.outline))),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}