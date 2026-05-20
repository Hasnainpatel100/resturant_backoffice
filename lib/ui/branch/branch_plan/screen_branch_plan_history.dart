import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/branch_plan_repository_impl.dart';
import '../../../theme/theme_constants.dart';
import 'cubit_branch_plan.dart';
import 'state_branch_plan.dart';

class ScreenBranchPlanHistory extends StatelessWidget {
  final String brandId;
  final String branchId;

  const ScreenBranchPlanHistory({
    super.key,
    required this.brandId,
    required this.branchId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitBranchPlan(repository: BranchPlanRepositoryImpl())
        ..loadPlanHistory(branchId),
      child: _PlanHistoryView(brandId: brandId, branchId: branchId),
    );
  }
}

class _PlanHistoryView extends StatelessWidget {
  final String brandId;
  final String branchId;

  const _PlanHistoryView({required this.brandId, required this.branchId});

  Future<void> _navigateToForm(BuildContext context) async {
    await context.pushNamed(
      'branchPlanForm',
      pathParameters: {
        'brandId': brandId,
        'branchId': branchId,
      },
    );
    // Refresh list when returning from form
    if (context.mounted) {
      context.read<CubitBranchPlan>().loadPlanHistory(branchId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(
                'branchDetail',
                pathParameters: {
                  'brandId': brandId,
                  'branchId': branchId,
                },
              );
            }
          },
        ),
        title: const Text('Plan History'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _navigateToForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Assign Plan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
            ),
          ),
          SizedBox(width: AppSpacing.md),
        ],
      ),
      body: BlocBuilder<CubitBranchPlan, StateBranchPlan>(
        builder: (context, state) {
          if (state.status == BranchPlanStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BranchPlanStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: cs.error),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    state.errorMessage ?? 'Failed to load plan history',
                    style: TextStyle(color: cs.error),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<CubitBranchPlan>()
                        .loadPlanHistory(branchId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: cs.outline),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'No plan history yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Assign a plan to this branch to get started',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.outline,
                        ),
                  ),
                ],
              ),
            );
          }

          // Display plan history list
          return RefreshIndicator(
            onRefresh: () => context
                .read<CubitBranchPlan>()
                .loadPlanHistory(branchId),
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.lg),
              itemCount: state.history.length,
              itemBuilder: (context, index) {
                final plan = state.history[index];

                // Format expiry date
                String expiryFormatted = plan.expiryAt;
                try {
                  final ms = int.tryParse(plan.expiryAt);
                  if (ms != null) {
                    expiryFormatted = DateFormat('MMM dd, yyyy')
                        .format(DateTime.fromMillisecondsSinceEpoch(ms));
                  }
                } catch (_) {}

                // Format created date
                String createdFormatted = '';
                if (plan.createdAt != null) {
                  try {
                    createdFormatted = DateFormat('MMM dd, yyyy – hh:mm a')
                        .format(DateTime.fromMillisecondsSinceEpoch(
                            plan.createdAt!));
                  } catch (_) {}
                }

                // Check if expired
                final isExpired = (() {
                  final ms = int.tryParse(plan.expiryAt);
                  if (ms == null) return false;
                  return DateTime.fromMillisecondsSinceEpoch(ms)
                      .isBefore(DateTime.now());
                })();

                return Card(
                  margin: EdgeInsets.only(bottom: AppSpacing.md),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: isExpired
                          ? cs.error.withOpacity(0.3)
                          : cs.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row with status badge
                        Row(
                          children: [
                            Icon(Icons.assignment_outlined,
                                size: 20, color: cs.primary),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                plan.note.isNotEmpty
                                    ? plan.note
                                    : 'Plan Assignment',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: isExpired
                                    ? cs.error.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                isExpired ? 'Expired' : 'Active',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: isExpired
                                          ? cs.error
                                          : Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.md),
                        Divider(height: 1, color: cs.outline.withOpacity(0.15)),
                        SizedBox(height: AppSpacing.md),

                        // Details grid
                        Row(
                          children: [
                            Expanded(
                              child: _DetailItem(
                                icon: Icons.people_outline,
                                label: 'Max Users',
                                value: '${plan.maxUsers}',
                              ),
                            ),
                            Expanded(
                              child: _DetailItem(
                                icon: Icons.devices_outlined,
                                label: 'Max Devices',
                                value: '${plan.maxPosDevices}',
                              ),
                            ),
                            Expanded(
                              child: _DetailItem(
                                icon: Icons.calendar_today_outlined,
                                label: 'Expires',
                                value: expiryFormatted,
                                valueColor: isExpired ? cs.error : null,
                              ),
                            ),
                          ],
                        ),

                        // Created date footer
                        if (createdFormatted.isNotEmpty) ...[
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Assigned on $createdFormatted',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: cs.outline,
                                    ),
                          ),
                        ],
                      ],
                    ),
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

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: cs.outline),
            SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.outline,
                  ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}
