import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/models/plan_model.dart';
import 'package:back_office/data/repositories/plan_repository_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_plan.dart';
import 'state_plan.dart';

class ScreenPlanList extends StatelessWidget {
  const ScreenPlanList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitPlan(repository: PlanRepositoryImpl())..getPlans(),
      child: const _PlanListView(),
    );
  }
}

class _PlanListView extends StatelessWidget {
  const _PlanListView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<CubitPlan>().getPlans(),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.go('/plans/create'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Plan'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocConsumer<CubitPlan, StatePlan>(
        listener: (context, state) {
          if (state.status == PlanStatus.success) {
            showToast(context,
                message: 'Plan deleted successfully', status: 'success');
            context.read<CubitPlan>().getPlans();
          }
          if (state.status == PlanStatus.error) {
            showToast(context,
                message: state.errorMessage ?? 'An error occurred',
                status: 'error');
          }
        },
        builder: (context, state) {
          if (state.status == PlanStatus.loading &&
              state.plans.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == PlanStatus.error && state.plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 56, color: cs.error),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    state.errorMessage ?? 'Error loading plans',
                    style: TextStyle(color: cs.error),
                  ),
                  SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: () => context.read<CubitPlan>().getPlans(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(Icons.layers_outlined, size: 64, color: cs.primary),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'No plans yet',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text('Create your first subscription plan',
                      style: TextStyle(color: cs.outline)),
                  SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: () => context.go('/plans/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Plan'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                  ),
                ],
              ),
            );
          }

          // Summary strip
          final active = state.plans.where((p) => p.isActive).length;
          final inactive = state.plans.length - active;
          final popular = state.plans.where((p) => p.isPopular).length;

          return Column(
            children: [
              // ── Stats strip ──────────────────────────────────────────────
              Container(
                color: cs.surfaceContainerHighest,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _SummaryChip(
                        icon: Icons.check_circle,
                        color: Colors.green,
                        label: '$active Active'),
                    const SizedBox(width: 16),
                    _SummaryChip(
                        icon: Icons.cancel,
                        color: Colors.grey,
                        label: '$inactive Inactive'),
                    const SizedBox(width: 16),
                    _SummaryChip(
                        icon: Icons.star,
                        color: Colors.amber,
                        label: '$popular Popular'),
                    const Spacer(),
                    Text(
                      '${state.plans.length} total',
                      style: TextStyle(color: cs.outline, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // ── Grid ─────────────────────────────────────────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossCount = constraints.maxWidth > 1200
                        ? 3
                        : constraints.maxWidth > 800
                            ? 2
                            : 1;
                    return GridView.builder(
                      padding: EdgeInsets.all(AppSpacing.md),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossCount,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: state.plans.length,
                      itemBuilder: (context, index) {
                        final plan = state.plans[index];
                        return _PlanCard(
                          plan: plan,
                          onEdit: () => context.go('/plans/${plan.id}/edit'),
                          onDelete: () => _confirmDelete(context, plan),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, PlanModel plan) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('Delete Plan?'),
        content: Text(
          'Are you sure you want to delete "${plan.name}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CubitPlan>().deletePlan(plan.id);
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Plan Card ────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final PlanModel plan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlanCard({
    required this.plan,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final statusColor = plan.isActive ? Colors.green : Colors.grey;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: plan.isPopular ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: plan.isPopular
            ? BorderSide(color: cs.primary, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored accent bar
          Container(
            height: 4,
            color: plan.isActive ? cs.primary : Colors.grey.shade400,
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:
                            Icon(Icons.layers, color: cs.onPrimaryContainer, size: 20),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          plan.name,
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (plan.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star,
                                  color: Colors.amber.shade700, size: 12),
                              const SizedBox(width: 3),
                              Text('Popular',
                                  style: TextStyle(
                                    color: Colors.amber.shade800,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ],
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.sm),

                  // Price
                  Row(
                    children: [
                      Text(
                        '₹${plan.monthlyPrice.toStringAsFixed(0)}',
                        style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
                      Text('/mo',
                          style: tt.bodySmall
                              ?.copyWith(color: cs.outline)),
                      const SizedBox(width: 12),
                      Text(
                        '₹${plan.yearlyPrice.toStringAsFixed(0)}/yr',
                        style: tt.bodySmall?.copyWith(color: cs.outline),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.xs),

                  // Description
                  if (plan.description.isNotEmpty)
                    Text(
                      plan.description,
                      style: tt.bodySmall?.copyWith(color: cs.outline),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  SizedBox(height: AppSpacing.sm),

                  // Limits row
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _LimitBadge(
                          icon: Icons.people,
                          label: '${plan.maxUsers} users'),
                      _LimitBadge(
                          icon: Icons.point_of_sale,
                          label: '${plan.maxPosDevices} POS'),
                      _LimitBadge(
                          icon: Icons.store,
                          label: '${plan.maxBranches} branches'),
                    ],
                  ),

                  const Spacer(),

                  // Features chips
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: plan.features
                        .take(4)
                        .map((f) => _FeatureChip(featureKey: f))
                        .toList(),
                  ),

                  SizedBox(height: AppSpacing.sm),

                  // Footer: status + actions
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              plan.isActive
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: statusColor,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              plan.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.edit_outlined,
                            size: 18, color: cs.primary),
                        tooltip: 'Edit',
                        visualDensity: VisualDensity.compact,
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            size: 18, color: cs.error),
                        tooltip: 'Delete',
                        visualDensity: VisualDensity.compact,
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LimitBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: cs.outline),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String featureKey;

  const _FeatureChip({required this.featureKey});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        PlanFeatures.label(featureKey),
        style: TextStyle(
          fontSize: 10,
          color: cs.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _SummaryChip(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
