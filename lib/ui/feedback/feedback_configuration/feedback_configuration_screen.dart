import 'package:go_router/go_router.dart';

import '../../../imports/core_imports.dart';
import '../../../data/models/feedback_configuration_model.dart';

/// Screen for creating / editing a feedback configuration.
///
/// This is the first step of the feedback creation wizard. It collects the
/// "General Information" fields and exposes Cancel / Next buttons.
class FeedbackConfigurationScreen extends StatefulWidget {
  final FeedbackConfigurationModel? config;

  const FeedbackConfigurationScreen({super.key, this.config});

  static FeedbackConfigurationModel getDummyConfigById(String id) {
    final now = DateTime.now();
    String branchId = 'branch_kp';
    String title = 'Post-Dine Experience Survey';
    String status = 'ACTIVE';
    String sendMethod = 'WHATSAPP';

    if (id == 'fbc_002') {
      branchId = 'branch_baner';
      title = 'Delivery Order Feedback';
      status = 'ACTIVE';
      sendMethod = 'SMS';
    } else if (id == 'fbc_003') {
      branchId = 'branch_vn';
      title = 'Table Service Quality Check';
      status = 'DRAFT';
      sendMethod = 'DISABLED';
    } else if (id == 'fbc_004') {
      branchId = 'branch_wakad';
      title = 'QR Table Feedback';
      status = 'ACTIVE';
      sendMethod = 'QR_CODE';
    } else if (id == 'fbc_005') {
      branchId = 'branch_kp';
      title = 'Loyalty Program Feedback';
      status = 'INACTIVE';
      sendMethod = 'ALL';
    } else if (id == 'fbc_006') {
      branchId = 'branch_baner';
      title = 'Legacy Feedback Form';
      status = 'ARCHIVED';
      sendMethod = 'DISABLED';
    }

    return FeedbackConfigurationModel(
      id: id,
      brandId: 'brand_001',
      branchId: branchId,
      title: title,
      status: status,
      sendMethod: sendMethod,
      delayMinutes: 15,
      minimumOrderAmount: 0,
      createdAt: now.subtract(const Duration(days: 30)).millisecondsSinceEpoch,
      createdBy: 'admin@brand.com',
      updatedAt: now.millisecondsSinceEpoch,
      updatedBy: 'admin@brand.com',
      isActive: true,
    );
  }

  @override
  State<FeedbackConfigurationScreen> createState() =>
      _FeedbackConfigurationScreenState();
}

class _FeedbackConfigurationScreenState
    extends State<FeedbackConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Text Controllers ──────────────────────────────────────────────────────
  late final TextEditingController _titleController;
  late final TextEditingController _googleFormUrlController;
  late final TextEditingController _delayController;
  late final TextEditingController _minOrderAmountController;

  // ── Dropdown values ───────────────────────────────────────────────────────
  String? _selectedBranch;
  late String _selectedStatus;
  late String _selectedSendMethod;

  // ── Switches ──────────────────────────────────────────────────────────────
  late bool _isDefaultFeedback;
  late bool _isLoyaltyEnabled;

  // ── Static options (mirrors FeedbackListScreen) ───────────────────────────
  static const List<String> _branchOptions = [
    'Koregaon Park',
    'Baner',
    'Viman Nagar',
    'Wakad',
  ];

  static const List<Map<String, String>> _statusOptions = [
    {'value': 'DRAFT', 'label': 'Draft'},
    {'value': 'ACTIVE', 'label': 'Active'},
    {'value': 'INACTIVE', 'label': 'Inactive'},
  ];

  static const List<Map<String, String>> _sendMethodOptions = [
    {'value': 'DISABLED', 'label': 'Disabled'},
    {'value': 'SMS', 'label': 'SMS'},
    {'value': 'WHATSAPP', 'label': 'WhatsApp'},
    {'value': 'QR_CODE', 'label': 'QR Code'},
    {'value': 'ALL', 'label': 'All'},
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.config;

    _titleController = TextEditingController(text: c?.title ?? '');
    _googleFormUrlController = TextEditingController(text: c?.googleFormUrl ?? '');
    _delayController = TextEditingController(text: '${c?.delayMinutes ?? 0}');

    final minAmount = c?.minimumOrderAmount;
    final minAmountText = minAmount != null 
        ? (minAmount == minAmount.toInt() ? '${minAmount.toInt()}' : '$minAmount')
        : '0';
    _minOrderAmountController = TextEditingController(text: minAmountText);

    _selectedBranch = _getBranchName(c?.branchId ?? '');
    _selectedStatus = c?.status ?? 'DRAFT';
    _selectedSendMethod = c?.sendMethod ?? 'DISABLED';

    _isDefaultFeedback = c?.isDefault ?? false;
    _isLoyaltyEnabled = c?.loyaltyEnabled ?? false;
  }

  String? _getBranchName(String branchId) {
    switch (branchId) {
      case 'branch_kp':
      case 'Koregaon Park':
        return 'Koregaon Park';
      case 'branch_baner':
      case 'Baner':
        return 'Baner';
      case 'branch_vn':
      case 'Viman Nagar':
        return 'Viman Nagar';
      case 'branch_wakad':
      case 'Wakad':
        return 'Wakad';
      default:
        return _branchOptions.contains(branchId) ? branchId : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _googleFormUrlController.dispose();
    _delayController.dispose();
    _minOrderAmountController.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _goBack() => context.pop();

  void _onCancel() => context.pop();

  void _onNext() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (widget.config != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );
    }
    context.push(AppRoutes.feedbackQuestionBuilder);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top bar: back + title + subtitle ────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _goBack,
                    tooltip: 'Back',
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.config != null ? 'Edit Feedback' : 'Create Feedback',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.config != null
                              ? 'Modify customer feedback form details'
                              : 'Configure a customer feedback form',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Scrollable form body ────────────────────────────────────────
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(AppSpacing.md),
                  children: [
                    // ── Section header ──────────────────────────────────────
                    _SectionHeader(
                      icon: Icons.info_outline,
                      title: 'General Information',
                      color: cs.primary,
                    ),
                    SizedBox(height: AppSpacing.sm),

                    // ── General Information Card ────────────────────────────
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Feedback Title
                          AppTextField(
                            controller: _titleController,
                            label: 'Feedback Title',
                            hint: 'e.g. Post-Dine Experience Survey',
                            prefixIcon: const Icon(Icons.title),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Title is required'
                                : null,
                          ),
                          SizedBox(height: AppSpacing.md),

                          // Branch
                          AppDropdownField<String>(
                            label: 'Branch',
                            hint: 'Select a branch',
                            value: _selectedBranch,
                            items: _branchOptions
                                .map((b) => DropdownMenuItem(
                                      value: b,
                                      child: Text(b),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedBranch = v),
                            validator: (v) =>
                                v == null ? 'Branch is required' : null,
                          ),
                          SizedBox(height: AppSpacing.md),

                          // Status
                          AppDropdownField<String>(
                            label: 'Status',
                            value: _selectedStatus,
                            items: _statusOptions
                                .map((o) => DropdownMenuItem(
                                      value: o['value'],
                                      child: Text(o['label']!),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(
                                () => _selectedStatus = v ?? 'DRAFT'),
                          ),
                          SizedBox(height: AppSpacing.md),

                          // Google Form URL
                          AppTextField(
                            controller: _googleFormUrlController,
                            label: 'Google Form URL',
                            hint: 'https://docs.google.com/forms/...',
                            prefixIcon: const Icon(Icons.link),
                            keyboardType: TextInputType.url,
                          ),
                          SizedBox(height: AppSpacing.md),

                          // Send Method
                          AppDropdownField<String>(
                            label: 'Send Method',
                            value: _selectedSendMethod,
                            items: _sendMethodOptions
                                .map((o) => DropdownMenuItem(
                                      value: o['value'],
                                      child: Text(o['label']!),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(
                                () => _selectedSendMethod = v ?? 'DISABLED'),
                          ),
                          SizedBox(height: AppSpacing.md),

                          // Delay & Minimum Order Amount — side by side
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _delayController,
                                  label: 'Delay (Minutes)',
                                  hint: '0',
                                  prefixIcon: const Icon(Icons.timer_outlined),
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v != null && v.isNotEmpty) {
                                      final n = int.tryParse(v);
                                      if (n == null || n < 0) {
                                        return 'Enter a valid number';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: AppTextField(
                                  controller: _minOrderAmountController,
                                  label: 'Minimum Order Amount',
                                  hint: '0',
                                  prefixIcon:
                                      const Icon(Icons.currency_rupee),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator: (v) {
                                    if (v != null && v.isNotEmpty) {
                                      final n = double.tryParse(v);
                                      if (n == null || n < 0) {
                                        return 'Enter a valid amount';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.lg),

                          // Default Feedback switch
                          AppSwitchField(
                            label: 'Default Feedback',
                            description:
                                'Use this form as the default for the selected branch',
                            value: _isDefaultFeedback,
                            onChanged: (v) =>
                                setState(() => _isDefaultFeedback = v),
                          ),
                          SizedBox(height: AppSpacing.md),

                          // Loyalty Enabled switch
                          AppSwitchField(
                            label: 'Loyalty Enabled',
                            description:
                                'Award loyalty points when this feedback is submitted',
                            value: _isLoyaltyEnabled,
                            onChanged: (v) =>
                                setState(() => _isLoyaltyEnabled = v),
                          ),
                        ],
                      ),
                    ),

                    // Extra bottom spacing so buttons don't feel cramped
                    SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // ── Bottom action bar: Cancel / Next ────────────────────────────
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.ms,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Cancel',
                    variant: ButtonVariant.outline,
                    onPressed: _onCancel,
                  ),
                  SizedBox(width: AppSpacing.ms),
                  AppButton(
                    label: widget.config != null ? 'Save Changes' : 'Next',
                    variant: ButtonVariant.primary,
                    suffixIcon: widget.config != null
                        ? const Icon(Icons.check, size: 18)
                        : const Icon(Icons.arrow_forward, size: 18),
                    onPressed: _onNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable section header (same pattern as ScreenBrandForm)
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
