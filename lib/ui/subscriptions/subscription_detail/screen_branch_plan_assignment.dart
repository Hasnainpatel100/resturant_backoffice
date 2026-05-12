import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/models/branch_subscription_model.dart';
import 'package:back_office/data/models/plan_model.dart';
import 'package:back_office/data/repositories/branch_subscription_repository_impl.dart';
import 'package:back_office/data/repositories/plan_repository_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'package:back_office/ui/plans/plan_list/cubit_plan.dart';
import 'package:back_office/ui/plans/plan_list/state_plan.dart';
import 'package:back_office/ui/subscriptions/subscription_detail/cubit_branch_subscription.dart';
import 'package:back_office/ui/subscriptions/subscription_detail/state_subscription.dart';

/// Screen for assigning a subscription plan to a specific branch.
///
/// Route: /brands/:brandId/branches/:branchId/plan
class ScreenBranchPlanAssignment extends StatelessWidget {
  final String brandId;
  final String branchId;

  const ScreenBranchPlanAssignment({
    super.key,
    required this.brandId,
    required this.branchId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              CubitPlan(repository: PlanRepositoryImpl())..getPlans(),
        ),
        BlocProvider(
          create: (_) => CubitBranchSubscription(
            repository: BranchSubscriptionRepositoryImpl(),
          )..getBranchSubscription(branchId),
        ),
      ],
      child: _PlanAssignmentView(
          brandId: brandId, branchId: branchId),
    );
  }
}

class _PlanAssignmentView extends StatefulWidget {
  final String brandId;
  final String branchId;

  const _PlanAssignmentView(
      {required this.brandId, required this.branchId});

  @override
  State<_PlanAssignmentView> createState() => _PlanAssignmentViewState();
}

class _PlanAssignmentViewState extends State<_PlanAssignmentView> {
  final _noteCtrl = TextEditingController();
  PlanModel? _selectedPlan;
  DateTime? _startDate;
  DateTime? _expiryDate;
  bool _autoRenew = false;
  String _billingCycle = 'monthly'; // monthly | yearly

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _expiryDate = DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _onPlanSelected(PlanModel plan) {
    setState(() {
      _selectedPlan = plan;
      // Auto-set expiry based on billing cycle
      _updateExpiryFromCycle();
    });
  }

  void _updateExpiryFromCycle() {
    if (_startDate == null) return;
    setState(() {
      if (_billingCycle == 'yearly') {
        _expiryDate = _startDate!.add(const Duration(days: 365));
      } else {
        _expiryDate = _startDate!.add(const Duration(days: 30));
      }
    });
  }

  void _assignPlan() {
    if (_selectedPlan == null) {
      showToast(context, message: 'Please select a plan', status: 'warning');
      return;
    }
    if (_startDate == null || _expiryDate == null) {
      showToast(context, message: 'Please set start and expiry date',
          status: 'warning');
      return;
    }
    if (_expiryDate!.isBefore(_startDate!)) {
      showToast(context,
          message: 'Expiry date must be after start date', status: 'error');
      return;
    }

    context.read<CubitBranchSubscription>().assignPlanToBranch(
      widget.branchId,
      {
        'brandId': widget.brandId,
        'planId': _selectedPlan!.id,
        'planName': _selectedPlan!.name,
        'startAt': _startDate!.millisecondsSinceEpoch,
        'expiryAt': _expiryDate!.millisecondsSinceEpoch,
        'autoRenew': _autoRenew,
        'note': _noteCtrl.text.trim(),
        'assignedAt': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<CubitBranchSubscription, StateSubscription>(
          listener: (context, state) {
            if (state.status == SubscriptionCubitStatus.success) {
              showToast(context,
                  message: 'Plan assigned successfully!', status: 'success');
              context.go('/brands/${widget.brandId}/branches/${widget.branchId}');
            }
            if (state.status == SubscriptionCubitStatus.error) {
              showToast(context,
                  message: state.errorMessage ?? 'Assignment failed',
                  status: 'error');
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Assign Plan to Branch'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(
                '/brands/${widget.brandId}/branches/${widget.branchId}'),
          ),
        ),
        body: BlocBuilder<CubitBranchSubscription, StateSubscription>(
          builder: (context, subState) {
            return BlocBuilder<CubitPlan, StatePlan>(
              builder: (context, planState) {
                if (planState.status == PlanStatus.loading &&
                    planState.plans.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Left: Plan selection ───────────────────────────
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSpacing.md),
                            color: cs.surfaceContainerHighest,
                            width: double.infinity,
                            child: Text(
                              'Select a Plan',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            child: planState.plans.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.layers_outlined,
                                            size: 48, color: cs.outline),
                                        SizedBox(height: AppSpacing.sm),
                                        Text('No plans available',
                                            style: TextStyle(
                                                color: cs.outline)),
                                        SizedBox(height: AppSpacing.sm),
                                        FilledButton.icon(
                                          onPressed: () =>
                                              context.go('/plans/create'),
                                          icon: const Icon(Icons.add,
                                              size: 16),
                                          label: const Text('Create Plan'),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding:
                                        EdgeInsets.all(AppSpacing.md),
                                    itemCount: planState.plans
                                        .where((p) => p.isActive)
                                        .length,
                                    itemBuilder: (context, index) {
                                      final activePlans = planState.plans
                                          .where((p) => p.isActive)
                                          .toList();
                                      final plan = activePlans[index];
                                      return _PlanSelectionCard(
                                        plan: plan,
                                        isSelected:
                                            _selectedPlan?.id == plan.id,
                                        onTap: () =>
                                            _onPlanSelected(plan),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    VerticalDivider(
                        width: 1, color: cs.outlineVariant),

                    // ── Right: Assignment config ───────────────────────
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Active subscription banner
                            if (subState.activeSubscription != null)
                              _ActiveSubBanner(
                                  subscription:
                                      subState.activeSubscription!),

                            // Selected plan preview
                            if (_selectedPlan != null)
                              _SelectedPlanPreview(plan: _selectedPlan!),

                            if (_selectedPlan != null)
                              SizedBox(height: AppSpacing.lg),

                            // Billing cycle
                            _SectionLabel(
                                icon: Icons.sync,
                                title: 'Billing Cycle'),
                            SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: _CycleOption(
                                    label: 'Monthly',
                                    subLabel: _selectedPlan != null
                                        ? '₹${_selectedPlan!.monthlyPrice.toStringAsFixed(0)}'
                                        : '',
                                    selected:
                                        _billingCycle == 'monthly',
                                    onTap: () {
                                      setState(() =>
                                          _billingCycle = 'monthly');
                                      _updateExpiryFromCycle();
                                    },
                                  ),
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _CycleOption(
                                    label: 'Yearly',
                                    subLabel: _selectedPlan != null
                                        ? '₹${_selectedPlan!.yearlyPrice.toStringAsFixed(0)}'
                                        : '',
                                    selected:
                                        _billingCycle == 'yearly',
                                    onTap: () {
                                      setState(() =>
                                          _billingCycle = 'yearly');
                                      _updateExpiryFromCycle();
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: AppSpacing.lg),

                            // Dates
                            _SectionLabel(
                                icon: Icons.date_range,
                                title: 'Subscription Period'),
                            SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: _DatePickerField(
                                    label: 'Start Date',
                                    date: _startDate,
                                    onPick: (date) {
                                      setState(() => _startDate = date);
                                      _updateExpiryFromCycle();
                                    },
                                  ),
                                ),
                                SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: _DatePickerField(
                                    label: 'Expiry Date',
                                    date: _expiryDate,
                                    isExpiry: true,
                                    onPick: (date) =>
                                        setState(() => _expiryDate = date),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: AppSpacing.lg),

                            // Options
                            SwitchListTile(
                              value: _autoRenew,
                              onChanged: (v) =>
                                  setState(() => _autoRenew = v),
                              title: const Text('Auto Renew'),
                              subtitle: const Text(
                                  'Automatically renew before expiry'),
                              secondary: Icon(
                                Icons.autorenew,
                                color: _autoRenew
                                    ? Colors.green
                                    : cs.outline,
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),

                            SizedBox(height: AppSpacing.md),

                            // Note
                            _SectionLabel(
                                icon: Icons.note_outlined, title: 'Note'),
                            SizedBox(height: AppSpacing.sm),
                            TextFormField(
                              controller: _noteCtrl,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText:
                                    'Optional note about this assignment...',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),

                            SizedBox(height: AppSpacing.xl),

                            // Submit
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: subState.status ==
                                        SubscriptionCubitStatus.loading
                                    ? null
                                    : _assignPlan,
                                icon: subState.status ==
                                        SubscriptionCubitStatus.loading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Icon(Icons.assignment_turned_in),
                                label: const Text('Assign Plan'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ── Supporting Widgets ────────────────────────────────────────────────────────

class _PlanSelectionCard extends StatelessWidget {
  final PlanModel plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanSelectionCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: cs.primary, width: 2)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Radio indicator
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? cs.primary : cs.outline,
                    width: 2,
                  ),
                  color: isSelected
                      ? cs.primary.withOpacity(0.15)
                      : Colors.transparent,
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: cs.primary),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: AppSpacing.md),
              // Plan info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(plan.name,
                            style: tt.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        if (plan.isPopular) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('Popular',
                                style: TextStyle(
                                    color: Colors.amber.shade800,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${plan.monthlyPrice.toStringAsFixed(0)}/mo  ·  '
                      '${plan.maxUsers} users  ·  '
                      '${plan.maxPosDevices} POS',
                      style: tt.bodySmall?.copyWith(color: cs.outline),
                    ),
                    if (plan.features.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: plan.features
                            .take(3)
                            .map((f) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer
                                        .withOpacity(0.5),
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    PlanFeatures.label(f),
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: cs.onPrimaryContainer),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              // Price
              Text(
                '₹${plan.monthlyPrice.toStringAsFixed(0)}',
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveSubBanner extends StatelessWidget {
  final BranchSubscriptionModel subscription;

  const _ActiveSubBanner({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isExp = subscription.isExpired;
    final color = isExp ? cs.errorContainer : Colors.green.shade50;
    final borderColor = isExp ? cs.error : Colors.green;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.lg),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExp ? Icons.warning_amber_rounded : Icons.check_circle,
                color: isExp ? cs.error : Colors.green.shade700,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isExp
                    ? 'Subscription Expired'
                    : 'Current Active Subscription',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isExp ? cs.error : Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Plan: ${subscription.planName}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            'Expires: ${DateFormat('dd MMM yyyy').format(subscription.expiryDate)}  '
            '(${isExp ? 'Expired' : '${subscription.remainingDays} days remaining'})',
            style: TextStyle(
                fontSize: 12, color: isExp ? cs.error : Colors.green.shade800),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Assigning a new plan will replace the current subscription.',
            style: TextStyle(
                fontSize: 11, color: isExp ? cs.error : Colors.green.shade700),
          ),
        ],
      ),
    );
  }
}

class _SelectedPlanPreview extends StatelessWidget {
  final PlanModel plan;

  const _SelectedPlanPreview({required this.plan});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.3),
        border: Border.all(color: cs.primary.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected: ${plan.name}',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: cs.primary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '${plan.maxUsers} users · ${plan.maxPosDevices} POS · ${plan.features.length} features',
            style: TextStyle(fontSize: 12, color: cs.outline),
          ),
        ],
      ),
    );
  }
}

class _CycleOption extends StatelessWidget {
  final String label;
  final String subLabel;
  final bool selected;
  final VoidCallback onTap;

  const _CycleOption({
    required this.label,
    required this.subLabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? cs.primary : cs.onSurface,
              ),
            ),
            if (subLabel.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subLabel,
                style: TextStyle(
                    fontSize: 11,
                    color: selected ? cs.primary : cs.outline),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isExpiry;
  final ValueChanged<DateTime> onPick;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onPick,
    this.isExpiry = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isExp = isExpiry &&
        date != null &&
        date!.isBefore(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) onPick(picked);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                  color: isExp ? cs.error : cs.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: isExp ? cs.error : cs.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? DateFormat('dd MMM yyyy').format(date!)
                      : 'Select date',
                  style: TextStyle(
                    color: date != null
                        ? (isExp ? cs.error : cs.onSurface)
                        : cs.outline,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
