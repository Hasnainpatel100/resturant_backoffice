import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:back_office/data/models/plan_model.dart';
import 'package:back_office/data/repositories/plan_repository_impl.dart';
import 'package:back_office/shared/shared.dart';
import 'cubit_plan.dart';
import 'state_plan.dart';

class ScreenPlanForm extends StatefulWidget {
  /// When non-null the form is in edit mode.
  final String? planId;

  const ScreenPlanForm({super.key, this.planId});

  bool get isEdit => planId != null;

  @override
  State<ScreenPlanForm> createState() => _ScreenPlanFormState();
}

class _ScreenPlanFormState extends State<ScreenPlanForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _monthlyPriceCtrl = TextEditingController();
  final _yearlyPriceCtrl = TextEditingController();
  final _maxUsersCtrl = TextEditingController();
  final _maxPosCtrl = TextEditingController();
  final _maxBranchesCtrl = TextEditingController();

  final Set<String> _selectedFeatures = {};
  bool _isPopular = false;
  bool _isActive = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _monthlyPriceCtrl.dispose();
    _yearlyPriceCtrl.dispose();
    _maxUsersCtrl.dispose();
    _maxPosCtrl.dispose();
    _maxBranchesCtrl.dispose();
    super.dispose();
  }

  void _populate(PlanModel plan) {
    _nameCtrl.text = plan.name;
    _descCtrl.text = plan.description;
    _monthlyPriceCtrl.text = plan.monthlyPrice.toStringAsFixed(0);
    _yearlyPriceCtrl.text = plan.yearlyPrice.toStringAsFixed(0);
    _maxUsersCtrl.text = plan.maxUsers.toString();
    _maxPosCtrl.text = plan.maxPosDevices.toString();
    _maxBranchesCtrl.text = plan.maxBranches.toString();
    setState(() {
      _selectedFeatures
        ..clear()
        ..addAll(plan.features);
      _isPopular = plan.isPopular;
      _isActive = plan.isActive;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'monthlyPrice': double.tryParse(_monthlyPriceCtrl.text.trim()) ?? 0,
      'yearlyPrice': double.tryParse(_yearlyPriceCtrl.text.trim()) ?? 0,
      'features': _selectedFeatures.toList(),
      'maxUsers': int.tryParse(_maxUsersCtrl.text.trim()) ?? 0,
      'maxPosDevices': int.tryParse(_maxPosCtrl.text.trim()) ?? 0,
      'maxBranches': int.tryParse(_maxBranchesCtrl.text.trim()) ?? 0,
      'isPopular': _isPopular,
      'isActive': _isActive,
    };

    final cubit = context.read<CubitPlan>();
    if (widget.isEdit) {
      cubit.updatePlan(widget.planId!, data);
    } else {
      cubit.createPlan(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = CubitPlan(repository: PlanRepositoryImpl());
        if (widget.isEdit) cubit.getPlan(widget.planId!);
        return cubit;
      },
      child: BlocConsumer<CubitPlan, StatePlan>(
        listener: (context, state) {
          if (state.status == PlanStatus.loaded &&
              widget.isEdit &&
              state.selectedPlan != null) {
            _populate(state.selectedPlan!);
          }
          if (state.status == PlanStatus.success) {
            showToast(context,
                message: widget.isEdit
                    ? 'Plan updated successfully'
                    : 'Plan created successfully',
                status: 'success');
            context.go('/plans');
          }
          if (state.status == PlanStatus.error) {
            showToast(context,
                message: state.errorMessage ?? 'An error occurred',
                status: 'error');
          }
        },
        builder: (context, state) {
          final isLoading = state.status == PlanStatus.loading;
          final cs = Theme.of(context).colorScheme;

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.isEdit ? 'Edit Plan' : 'Create Plan'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/plans'),
              ),
              actions: [
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: Icon(
                        widget.isEdit ? Icons.save_outlined : Icons.add,
                        size: 18),
                    label: Text(widget.isEdit ? 'Save Changes' : 'Create Plan'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                const SizedBox(width: 12),
              ],
            ),
            body: widget.isEdit && state.status == PlanStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Basic Info ────────────────────────────────
                            _SectionHeader(
                              icon: Icons.info_outline,
                              title: 'Plan Details',
                              color: cs.primary,
                            ),
                            SizedBox(height: AppSpacing.md),
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(AppSpacing.lg),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _FormField(
                                            label: 'Plan Name *',
                                            controller: _nameCtrl,
                                            hint: 'e.g. Basic, Pro, Enterprise',
                                            validator: (v) =>
                                                (v == null || v.isEmpty)
                                                    ? 'Name is required'
                                                    : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: AppSpacing.md),
                                    _FormField(
                                      label: 'Description',
                                      controller: _descCtrl,
                                      hint: 'Brief description of this plan',
                                      maxLines: 3,
                                    ),
                                    SizedBox(height: AppSpacing.md),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SwitchListTile(
                                            value: _isPopular,
                                            onChanged: (v) =>
                                                setState(() => _isPopular = v),
                                            title: const Text('Mark as Popular'),
                                            subtitle: const Text(
                                                'Highlighted on plan selection'),
                                            secondary: Icon(Icons.star,
                                                color: _isPopular
                                                    ? Colors.amber
                                                    : cs.outline),
                                          ),
                                        ),
                                        Expanded(
                                          child: SwitchListTile(
                                            value: _isActive,
                                            onChanged: (v) =>
                                                setState(() => _isActive = v),
                                            title: const Text('Active'),
                                            subtitle: const Text(
                                                'Inactive plans can\'t be assigned'),
                                            secondary: Icon(
                                              Icons.toggle_on_outlined,
                                              color: _isActive
                                                  ? Colors.green
                                                  : cs.outline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: AppSpacing.lg),

                            // ── Pricing ───────────────────────────────────
                            _SectionHeader(
                              icon: Icons.currency_rupee,
                              title: 'Pricing',
                              color: Colors.green.shade700,
                            ),
                            SizedBox(height: AppSpacing.md),
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(AppSpacing.lg),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _FormField(
                                        label: 'Monthly Price (₹) *',
                                        controller: _monthlyPriceCtrl,
                                        hint: '999',
                                        keyboardType:
                                            TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly
                                        ],
                                        validator: (v) =>
                                            (v == null || v.isEmpty)
                                                ? 'Required'
                                                : null,
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: _FormField(
                                        label: 'Yearly Price (₹)',
                                        controller: _yearlyPriceCtrl,
                                        hint: '9999',
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: AppSpacing.lg),

                            // ── Limits ────────────────────────────────────
                            _SectionHeader(
                              icon: Icons.tune,
                              title: 'Usage Limits',
                              color: Colors.orange.shade700,
                            ),
                            SizedBox(height: AppSpacing.md),
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(AppSpacing.lg),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _FormField(
                                        label: 'Max Users *',
                                        controller: _maxUsersCtrl,
                                        hint: '5',
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly
                                        ],
                                        prefixIcon:
                                            const Icon(Icons.people, size: 18),
                                        validator: (v) =>
                                            (v == null || v.isEmpty)
                                                ? 'Required'
                                                : null,
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: _FormField(
                                        label: 'Max POS Devices *',
                                        controller: _maxPosCtrl,
                                        hint: '2',
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly
                                        ],
                                        prefixIcon: const Icon(
                                            Icons.point_of_sale,
                                            size: 18),
                                        validator: (v) =>
                                            (v == null || v.isEmpty)
                                                ? 'Required'
                                                : null,
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: _FormField(
                                        label: 'Max Branches',
                                        controller: _maxBranchesCtrl,
                                        hint: '1',
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly
                                        ],
                                        prefixIcon: const Icon(Icons.store,
                                            size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: AppSpacing.lg),

                            // ── Features ──────────────────────────────────
                            _SectionHeader(
                              icon: Icons.extension,
                              title: 'Features',
                              color: Colors.indigo.shade700,
                            ),
                            SizedBox(height: AppSpacing.md),
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(AppSpacing.lg),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Select features included in this plan:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: cs.outline),
                                    ),
                                    SizedBox(height: AppSpacing.md),
                                    Wrap(
                                      spacing: AppSpacing.sm,
                                      runSpacing: AppSpacing.sm,
                                      children: PlanFeatures.all
                                          .map((feature) =>
                                              _FeatureToggleChip(
                                                featureKey: feature,
                                                selected: _selectedFeatures
                                                    .contains(feature),
                                                onToggle: (selected) {
                                                  setState(() {
                                                    if (selected) {
                                                      _selectedFeatures
                                                          .add(feature);
                                                    } else {
                                                      _selectedFeatures
                                                          .remove(feature);
                                                    }
                                                  });
                                                },
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader(
      {required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _FeatureToggleChip extends StatelessWidget {
  final String featureKey;
  final bool selected;
  final ValueChanged<bool> onToggle;

  const _FeatureToggleChip({
    required this.featureKey,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilterChip(
      selected: selected,
      label: Text(PlanFeatures.label(featureKey)),
      onSelected: onToggle,
      checkmarkColor: cs.onPrimary,
      selectedColor: cs.primary,
      labelStyle: TextStyle(
        color: selected ? cs.onPrimary : cs.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
