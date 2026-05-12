import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/branch_repository_impl.dart';
import 'package:back_office/ui/branch/branch_list/cubit_branch.dart';
import 'package:back_office/ui/branch/branch_list/state_branch.dart';
import 'package:back_office/data/models/branch_model.dart';
import 'package:back_office/shared/shared.dart';

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

    return BlocConsumer<CubitBranch, StateBranch>(
      listener: (context, state) {
        if (state.status == BranchStatus.success && state.branch == null) {
          showToast(context, message: 'Branch deleted', status: 'success');
          context.go('/brands/$brandId/branches');
        }
        if (state.status == BranchStatus.error) {
          showToast(context, message: state.errorMessage ?? 'Error', status: 'error');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Branch Details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/brands/$brandId/branches'),
            ),
            actions: [
              FilledButton.icon(
                onPressed: () => context.go(
                    '/brands/$brandId/branches/$branchId/subscription'),
                icon: const Icon(Icons.layers, size: 16),
                label: const Text('Subscription'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Branch',
                onPressed: () => context.go('/brands/$brandId/branches/$branchId/edit'),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: cs.error),
                tooltip: 'Delete Branch',
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, StateBranch state) {
    final cs = Theme.of(context).colorScheme;

    if (state.status == BranchStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == BranchStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: cs.error),
            SizedBox(height: AppSpacing.md),
            Text(state.errorMessage ?? 'Error', style: TextStyle(color: cs.error)),
            SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: () => context.read<CubitBranch>().loadBranch(branchId),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
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
          // ── Header Card ──
          _BranchHeaderCard(branch: branch),

          SizedBox(height: AppSpacing.md),

          // ── Contact ──
          _DetailSection(
            icon: Icons.contact_phone,
            title: 'Contact',
            color: Colors.teal,
            children: [
              _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: branch.contact.phones.primary),
              _InfoRow(icon: Icons.email_outlined, label: 'Email', value: branch.contact.email),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // ── Address ──
          _DetailSection(
            icon: Icons.location_on,
            title: 'Address',
            color: Colors.blue,
            children: [
              _InfoRow(
                icon: Icons.home_outlined,
                label: 'Address',
                value: branch.address.full,
              ),
              if (branch.address.city.isNotEmpty)
                _InfoRow(
                  icon: Icons.location_city,
                  label: 'City',
                  value: '${branch.address.city}, ${branch.address.state}',
                ),
              if (branch.address.country.isNotEmpty)
                _InfoRow(
                  icon: Icons.public,
                  label: 'Country',
                  value: '${branch.address.country} ${branch.address.zipCode}',
                ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // ── Registration ──
          if (branch.registration.gstNo.isNotEmpty || branch.registration.fssaiNo.isNotEmpty)
            _DetailSection(
              icon: Icons.description,
              title: 'Registration',
              color: Colors.orange,
              children: [
                _InfoRow(icon: Icons.receipt_long, label: 'GST No', value: branch.registration.gstNo),
                _InfoRow(icon: Icons.verified_outlined, label: 'FSSAI', value: branch.registration.fssaiNo),
              ],
            ),

          if (branch.registration.gstNo.isNotEmpty || branch.registration.fssaiNo.isNotEmpty)
            SizedBox(height: AppSpacing.md),

          // ── Operating Hours ──
          _DetailSection(
            icon: Icons.access_time,
            title: 'Operating Hours',
            color: Colors.purple,
            children: [
              _InfoRow(
                icon: Icons.star,
                label: 'Type',
                value: branch.settings.isMasterBranch ? 'Master Branch' : 'Regular Branch',
              ),
              if (branch.settings.open.isNotEmpty)
                _InfoRow(icon: Icons.access_time, label: 'Opens', value: branch.settings.open),
              if (branch.settings.close.isNotEmpty)
                _InfoRow(icon: Icons.access_time_filled, label: 'Closes', value: branch.settings.close),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // ── Service Types ──
          if (branch.serviceTypes.isNotEmpty)
            _DetailSection(
              icon: Icons.room_service,
              title: 'Service Types',
              color: Colors.indigo,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: branch.serviceTypes.map((type) {
                    return Chip(
                      label: Text(type, style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ),

          if (branch.serviceTypes.isNotEmpty) SizedBox(height: AppSpacing.md),

          // ── Plan Details ──
          if (branch.planDetails != null) ...[
            _PlanCard(plan: branch.planDetails!),
            SizedBox(height: AppSpacing.md),
          ],

          SizedBox(height: AppSpacing.lg),
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
        title: const Text('Delete Branch?'),
        content: const Text(
          'This will permanently delete this branch.\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CubitBranch>().deleteBranch(branchId);
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Delete Branch'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header card

class _BranchHeaderCard extends StatelessWidget {
  final BranchModel branch;

  const _BranchHeaderCard({required this.branch});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = branch.isActive ? Colors.green : Colors.grey;

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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      branch.displayName[0].toUpperCase(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: statusColor,
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
                        branch.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      if (branch.branchCode.isNotEmpty)
                        Text(
                          'Code: ${branch.branchCode}',
                          style: TextStyle(color: cs.outline, fontSize: 13),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        branch.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (branch.settings.isMasterBranch) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.star, size: 12, color: Colors.amber),
                            SizedBox(width: 2),
                            Text(
                              'Master',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.amber,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
            width: 70,
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
// Plan card

class _PlanCard extends StatelessWidget {
  final BranchPlanDetails plan;

  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isExpired = plan.isExpired;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(height: 3, color: isExpired ? Colors.red : Colors.green),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (isExpired ? Colors.red : Colors.green).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        color: isExpired ? Colors.red : Colors.green,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Plan Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    if (isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Expired',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _PlanStat(
                      icon: Icons.people,
                      label: 'Max Users',
                      value: '${plan.maxUsers}',
                    ),
                    SizedBox(width: AppSpacing.lg),
                    _PlanStat(
                      icon: Icons.tablet_android,
                      label: 'Max Devices',
                      value: '${plan.maxPosDevices}',
                    ),
                    SizedBox(width: AppSpacing.lg),
                    _PlanStat(
                      icon: Icons.calendar_today,
                      label: 'Expires',
                      value: plan.expiryDate?.toString().split(' ')[0] ?? '-',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PlanStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: cs.outline),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: cs.outline, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}