import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/models/branch_subscription_model.dart';
import 'package:back_office/data/repositories/branch_subscription_repository_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_branch_subscription.dart';
import 'state_subscription.dart';

/// Shows the active subscription + full history for one branch.
///
/// Route: /brands/:brandId/branches/:branchId/subscription
class ScreenBranchSubscription extends StatelessWidget {
  final String brandId;
  final String branchId;

  const ScreenBranchSubscription({
    super.key,
    required this.brandId,
    required this.branchId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitBranchSubscription(
        repository: BranchSubscriptionRepositoryImpl(),
      )
        ..getBranchSubscription(branchId)
        ..getSubscriptionHistory(branchId),
      child: _SubscriptionView(brandId: brandId, branchId: branchId),
    );
  }
}

class _SubscriptionView extends StatelessWidget {
  final String brandId;
  final String branchId;

  const _SubscriptionView(
      {required this.brandId, required this.branchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.go('/brands/$brandId/branches/$branchId'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<CubitBranchSubscription>()
                  .getBranchSubscription(branchId);
              context
                  .read<CubitBranchSubscription>()
                  .getSubscriptionHistory(branchId);
            },
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () => context.go(
                '/brands/$brandId/branches/$branchId/plan'),
            icon: const Icon(Icons.assignment, size: 18),
            label: const Text('Assign Plan'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocConsumer<CubitBranchSubscription, StateSubscription>(
        listener: (context, state) {
          if (state.status == SubscriptionCubitStatus.success) {
            showToast(context,
                message: 'Updated successfully', status: 'success');
            context
                .read<CubitBranchSubscription>()
                .getBranchSubscription(branchId);
          }
          if (state.status == SubscriptionCubitStatus.error) {
            showToast(context,
                message: state.errorMessage ?? 'An error occurred',
                status: 'error');
          }
        },
        builder: (context, state) {
          if (state.status == SubscriptionCubitStatus.loading &&
              state.activeSubscription == null &&
              state.history.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Active Subscription Card ───────────────────────────
                _SectionHeader(title: 'Active Subscription'),
                SizedBox(height: AppSpacing.md),
                if (state.activeSubscription == null)
                  _NoSubscriptionCard(
                    brandId: brandId,
                    branchId: branchId,
                  )
                else
                  _ActiveSubscriptionCard(
                    subscription: state.activeSubscription!,
                    brandId: brandId,
                    branchId: branchId,
                  ),

                SizedBox(height: AppSpacing.xl),

                // ── History ───────────────────────────────────────────
                _SectionHeader(title: 'Subscription History'),
                SizedBox(height: AppSpacing.md),
                if (state.history.isEmpty)
                  _EmptyHistory()
                else
                  _HistoryList(history: state.history),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _NoSubscriptionCard extends StatelessWidget {
  final String brandId;
  final String branchId;

  const _NoSubscriptionCard(
      {required this.brandId, required this.branchId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.layers_clear_outlined, size: 56, color: cs.outline),
              SizedBox(height: AppSpacing.md),
              Text(
                'No active subscription',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: AppSpacing.sm),
              Text('Assign a plan to activate features for this branch.',
                  style: TextStyle(color: cs.outline)),
              SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: () => context
                    .go('/brands/$brandId/branches/$branchId/plan'),
                icon: const Icon(Icons.assignment),
                label: const Text('Assign Plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveSubscriptionCard extends StatelessWidget {
  final BranchSubscriptionModel subscription;
  final String brandId;
  final String branchId;

  const _ActiveSubscriptionCard({
    required this.subscription,
    required this.brandId,
    required this.branchId,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isExp = subscription.isExpired;
    final accentColor = isExp ? cs.error : Colors.green.shade600;
    final remaining = subscription.remainingDays;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accentColor, width: 2),
      ),
      child: Column(
        children: [
          // Top accent
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan name + status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.layers,
                          color: accentColor, size: 24),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subscription.planName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            isExp
                                ? 'Subscription Expired'
                                : '$remaining days remaining',
                            style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isExp ? 'EXPIRED' : 'ACTIVE',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.lg),
                const Divider(),
                SizedBox(height: AppSpacing.md),

                // Details grid
                Wrap(
                  spacing: AppSpacing.xl,
                  runSpacing: AppSpacing.md,
                  children: [
                    _DetailItem(
                      label: 'Started',
                      value: DateFormat('dd MMM yyyy')
                          .format(subscription.startDate),
                      icon: Icons.play_circle_outline,
                    ),
                    _DetailItem(
                      label: 'Expires',
                      value: DateFormat('dd MMM yyyy')
                          .format(subscription.expiryDate),
                      icon: Icons.timer_outlined,
                      valueColor: isExp ? cs.error : null,
                    ),
                    _DetailItem(
                      label: 'Auto Renew',
                      value:
                          subscription.autoRenew ? 'Enabled' : 'Disabled',
                      icon: Icons.autorenew,
                      valueColor: subscription.autoRenew
                          ? Colors.green.shade700
                          : null,
                    ),
                    _DetailItem(
                      label: 'Assigned By',
                      value: subscription.assignedBy.isNotEmpty
                          ? subscription.assignedBy
                          : 'System',
                      icon: Icons.person_outline,
                    ),
                    _DetailItem(
                      label: 'Assigned On',
                      value: DateFormat('dd MMM yyyy')
                          .format(subscription.assignedDate),
                      icon: Icons.calendar_today_outlined,
                    ),
                  ],
                ),

                if (subscription.note.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.md),
                  const Divider(),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note_outlined,
                          size: 16, color: cs.outline),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          subscription.note,
                          style:
                              TextStyle(color: cs.outline, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: AppSpacing.lg),

                // Actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isExp)
                      FilledButton.icon(
                        onPressed: () => context.go(
                            '/brands/$brandId/branches/$branchId/plan'),
                        icon: const Icon(Icons.autorenew, size: 18),
                        label: const Text('Renew / Change Plan'),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () => context.go(
                            '/brands/$brandId/branches/$branchId/plan'),
                        icon: const Icon(Icons.swap_horiz, size: 18),
                        label: const Text('Change Plan'),
                      ),
                    SizedBox(width: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () => _confirmCancel(
                          context, subscription.id),
                      icon: Icon(Icons.cancel_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.error),
                      label: Text('Cancel',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.error)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color:
                                Theme.of(context).colorScheme.error),
                      ),
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

  void _confirmCancel(BuildContext context, String subscriptionId) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded,
            color: cs.error, size: 40),
        title: const Text('Cancel Subscription?'),
        content: const Text(
            'This will cancel the current subscription. The branch will lose access to plan features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<CubitBranchSubscription>()
                  .cancelSubscription(subscriptionId);
            },
            style:
                FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: cs.outline),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: cs.outline)),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? cs.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: cs.outline),
              SizedBox(height: AppSpacing.md),
              Text('No subscription history',
                  style: TextStyle(color: cs.outline)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<BranchSubscriptionModel> history;

  const _HistoryList({required this.history});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (_, __) =>
          SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final sub = history[index];
        return _HistoryCard(subscription: sub);
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final BranchSubscriptionModel subscription;

  const _HistoryCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _statusColor(subscription.status, cs);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        subscription.planName,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(
                          status: subscription.status,
                          color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('dd MMM yyyy').format(subscription.startDate)}  →  '
                    '${DateFormat('dd MMM yyyy').format(subscription.expiryDate)}',
                    style: TextStyle(color: cs.outline, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (subscription.note.isNotEmpty)
              Tooltip(
                message: subscription.note,
                child:
                    Icon(Icons.note_outlined, size: 16, color: cs.outline),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(SubscriptionStatus status, ColorScheme cs) {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.expired:
        return cs.error;
      case SubscriptionStatus.cancelled:
        return Colors.grey;
      case SubscriptionStatus.pending:
        return Colors.orange;
      case SubscriptionStatus.trial:
        return Colors.blue;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final SubscriptionStatus status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5),
      ),
    );
  }
}
