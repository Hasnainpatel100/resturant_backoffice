import 'package:go_router/go_router.dart';

import '../../imports/core_imports.dart';

/// Screen for creating / editing a feedback configuration.
///
/// This is the first step of the feedback creation wizard. It collects the
/// "General Information" fields and exposes Cancel / Next buttons.
class FeedbackConfigurationScreen extends StatefulWidget {
  const FeedbackConfigurationScreen({super.key});

  @override
  State<FeedbackConfigurationScreen> createState() =>
      _FeedbackConfigurationScreenState();
}

class _FeedbackConfigurationScreenState
    extends State<FeedbackConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Text Controllers ──────────────────────────────────────────────────────
  final _titleController = TextEditingController();
  final _googleFormUrlController = TextEditingController();
  final _delayController = TextEditingController(text: '0');
  final _minOrderAmountController = TextEditingController(text: '0');

  // ── Dropdown values ───────────────────────────────────────────────────────
  String? _selectedBranch;
  String _selectedStatus = 'DRAFT';
  String _selectedSendMethod = 'DISABLED';

  // ── Switches ──────────────────────────────────────────────────────────────
  bool _isDefaultFeedback = false;
  bool _isLoyaltyEnabled = false;

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
                          'Create Feedback',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Configure a customer feedback form',
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
                    label: 'Next',
                    variant: ButtonVariant.primary,
                    suffixIcon: const Icon(Icons.arrow_forward, size: 18),
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
