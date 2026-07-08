import '../../data/models/feedback_question_model.dart';
import '../../data/models/feedback_question_option.dart';
import '../../data/models/feedback_question_settings.dart';
import '../../imports/core_imports.dart';

/// A reusable Material 3 dialog for adding or editing a feedback question.
///
/// Usage:
/// ```dart
/// // Create mode
/// final result = await FeedbackQuestionDialog.show(context);
///
/// // Edit mode — pre-fills all fields from the existing question
/// final result = await FeedbackQuestionDialog.show(context, question: existing);
/// ```
///
/// Returns a [FeedbackQuestionModel] on save, or `null` on cancel.
class FeedbackQuestionDialog extends StatefulWidget {
  /// When non-null the dialog opens in **edit** mode and pre-fills all fields.
  final FeedbackQuestionModel? question;

  const FeedbackQuestionDialog._({this.question});

  /// Convenience launcher.  Returns the saved [FeedbackQuestionModel] or
  /// `null` if the user cancelled.
  static Future<FeedbackQuestionModel?> show(
    BuildContext context, {
    FeedbackQuestionModel? question,
  }) {
    return showDialog<FeedbackQuestionModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => FeedbackQuestionDialog._(question: question),
    );
  }

  @override
  State<FeedbackQuestionDialog> createState() => _FeedbackQuestionDialogState();
}

class _FeedbackQuestionDialogState extends State<FeedbackQuestionDialog> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ─────────────────────────────────────────────────────────
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  // Rating
  late final TextEditingController _maxRatingController;

  // Scale
  late final TextEditingController _scaleMinController;
  late final TextEditingController _scaleMaxController;

  // Input Text
  late final TextEditingController _placeholderController;

  // Welcome / Thank-You
  late final TextEditingController _buttonTextController;

  // ── State ───────────────────────────────────────────────────────────────
  late String _selectedType;
  late bool _isRequired;
  late List<_OptionEntry> _options;

  bool get _isEditing => widget.question != null;

  // ── Question type metadata ──────────────────────────────────────────────

  static const List<Map<String, String>> _typeOptions = [
    {'value': 'WELCOME_SCREEN', 'label': 'Welcome Screen'},
    {'value': 'PHONE_NUMBER', 'label': 'Phone Number'},
    {'value': 'RATING', 'label': 'Rating'},
    {'value': 'MULTIPLE_CHOICE', 'label': 'Multiple Choice'},
    {'value': 'INPUT_TEXT', 'label': 'Input Text'},
    {'value': 'SCALE', 'label': 'Scale'},
    {'value': 'YES_NO', 'label': 'Yes / No'},
    {'value': 'ORDER_ITEMS', 'label': 'Order Items'},
    {'value': 'THANK_YOU_SCREEN', 'label': 'Thank You Screen'},
  ];

  // ── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final q = widget.question;

    _selectedType = q?.type ?? 'RATING';
    _isRequired = q?.isRequired ?? false;

    _titleController = TextEditingController(text: q?.title ?? '');
    _descriptionController = TextEditingController(text: q?.description ?? '');

    _maxRatingController = TextEditingController(
      text: '${q?.settings.maxRating ?? 5}',
    );
    _scaleMinController = TextEditingController(
      text: '${q?.settings.min ?? 0}',
    );
    _scaleMaxController = TextEditingController(
      text: '${q?.settings.max ?? 10}',
    );
    _placeholderController = TextEditingController(
      text: q?.settings.placeholder ?? '',
    );
    _buttonTextController = TextEditingController(
      text: q?.settings.buttonText ?? '',
    );

    _options = q != null && q.options.isNotEmpty
        ? q.options
            .map((o) => _OptionEntry(TextEditingController(text: o.text)))
            .toList()
        : [_OptionEntry(TextEditingController(text: 'Option 1'))];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxRatingController.dispose();
    _scaleMinController.dispose();
    _scaleMaxController.dispose();
    _placeholderController.dispose();
    _buttonTextController.dispose();
    for (final o in _options) {
      o.controller.dispose();
    }
    super.dispose();
  }

  // ── Save ────────────────────────────────────────────────────────────────

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = widget.question;

    final settings = _buildSettings();
    final options = _selectedType == 'MULTIPLE_CHOICE' ? _buildOptions() : <FeedbackQuestionOption>[];

    final model = FeedbackQuestionModel(
      id: existing?.id ?? 'q_$now',
      brandId: existing?.brandId ?? 'brand_001',
      branchId: existing?.branchId ?? 'branch_kp',
      feedbackConfigurationId: existing?.feedbackConfigurationId ?? 'fbc_001',
      type: _selectedType,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      isRequired: _isRequired,
      displayOrder: existing?.displayOrder ?? 0,
      settings: settings,
      options: options,
      createdAt: existing?.createdAt ?? now,
      createdBy: existing?.createdBy ?? 'admin@brand.com',
      updatedAt: now,
      updatedBy: 'admin@brand.com',
      isActive: existing?.isActive ?? true,
    );

    Navigator.of(context).pop(model);
  }

  FeedbackQuestionSettings _buildSettings() {
    switch (_selectedType) {
      case 'RATING':
        return FeedbackQuestionSettings(
          maxRating: int.tryParse(_maxRatingController.text) ?? 5,
        );
      case 'SCALE':
        return FeedbackQuestionSettings(
          min: int.tryParse(_scaleMinController.text) ?? 0,
          max: int.tryParse(_scaleMaxController.text) ?? 10,
        );
      case 'INPUT_TEXT':
        return FeedbackQuestionSettings(
          placeholder: _placeholderController.text.trim().isEmpty
              ? null
              : _placeholderController.text.trim(),
        );
      case 'WELCOME_SCREEN':
      case 'THANK_YOU_SCREEN':
        return FeedbackQuestionSettings(
          buttonText: _buttonTextController.text.trim().isEmpty
              ? null
              : _buttonTextController.text.trim(),
        );
      default:
        return const FeedbackQuestionSettings();
    }
  }

  List<FeedbackQuestionOption> _buildOptions() {
    return _options.asMap().entries.map((e) {
      final text = e.value.controller.text.trim();
      return FeedbackQuestionOption(
        text: text.isEmpty ? 'Option ${e.key + 1}' : text,
        value: text.toLowerCase().replaceAll(RegExp(r'\s+'), '_'),
        displayOrder: e.key,
      );
    }).toList();
  }

  // ── Option helpers ──────────────────────────────────────────────────────

  void _addOption() {
    setState(() {
      _options.add(
        _OptionEntry(
          TextEditingController(text: 'Option ${_options.length + 1}'),
        ),
      );
    });
  }

  void _removeOption(int index) {
    if (_options.length <= 1) return;
    setState(() {
      _options[index].controller.dispose();
      _options.removeAt(index);
    });
  }

  // ── Icon for type ───────────────────────────────────────────────────────

  IconData _iconForType(String type) {
    switch (type) {
      case 'WELCOME_SCREEN':
        return Icons.waving_hand_outlined;
      case 'PHONE_NUMBER':
        return Icons.phone_outlined;
      case 'RATING':
        return Icons.star_outline;
      case 'MULTIPLE_CHOICE':
        return Icons.check_box_outlined;
      case 'INPUT_TEXT':
        return Icons.text_fields;
      case 'SCALE':
        return Icons.linear_scale;
      case 'YES_NO':
        return Icons.thumbs_up_down_outlined;
      case 'ORDER_ITEMS':
        return Icons.receipt_long_outlined;
      case 'THANK_YOU_SCREEN':
        return Icons.celebration_outlined;
      default:
        return Icons.help_outline;
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.xl),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────────────────────
            _buildDialogHeader(cs, tt),

            const Divider(height: 1),

            // ── Body ─────────────────────────────────────────────────────
            Flexible(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  shrinkWrap: true,
                  children: [
                    // Question Type
                    AppDropdownField<String>(
                      label: 'Question Type',
                      value: _selectedType,
                      items: _typeOptions
                          .map(
                            (o) => DropdownMenuItem(
                              value: o['value'],
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _iconForType(o['value']!),
                                    size: 18,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(o['label']!),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedType = v);
                      },
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Question Title
                    AppTextField(
                      controller: _titleController,
                      label: 'Question Title',
                      hint: 'e.g. How was your experience?',
                      prefixIcon: const Icon(Icons.title),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Title is required'
                          : null,
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Description (optional)
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Description (optional)',
                      hint: 'Add a short helper text...',
                      prefixIcon: const Icon(Icons.notes),
                      maxLines: 2,
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Required switch
                    AppSwitchField(
                      label: 'Required',
                      description: 'User must answer this question',
                      value: _isRequired,
                      onChanged: (v) => setState(() => _isRequired = v),
                    ),

                    // ── Dynamic fields per type ──────────────────────────
                    ..._buildDynamicFields(cs, tt),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // ── Footer ───────────────────────────────────────────────────
            _buildDialogFooter(),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildDialogHeader(ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.ms,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isEditing ? Icons.edit_outlined : Icons.add_circle_outline,
              color: cs.primary,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.ms),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Question' : 'Add Question',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEditing
                      ? 'Update the question details below.'
                      : 'Configure a new question for your form.',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  // ── Footer ──────────────────────────────────────────────────────────────

  Widget _buildDialogFooter() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.ms,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppButton(
            label: 'Cancel',
            variant: ButtonVariant.outline,
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: AppSpacing.ms),
          AppButton(
            label: _isEditing ? 'Save Changes' : 'Save',
            variant: ButtonVariant.primary,
            prefixIcon: Icon(
              _isEditing ? Icons.check : Icons.add,
              size: 18,
            ),
            onPressed: _onSave,
          ),
        ],
      ),
    );
  }

  // ── Dynamic fields ──────────────────────────────────────────────────────

  List<Widget> _buildDynamicFields(ColorScheme cs, TextTheme tt) {
    final spacer = SizedBox(height: AppSpacing.md);

    switch (_selectedType) {
      case 'RATING':
        return [
          spacer,
          const _DynamicSectionLabel(label: 'Rating Settings', icon: Icons.star_outline),
          SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: _maxRatingController,
            label: 'Maximum Rating',
            hint: '5',
            prefixIcon: const Icon(Icons.star_half),
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              final n = int.tryParse(v);
              if (n == null || n < 1 || n > 10) return 'Enter 1–10';
              return null;
            },
          ),
        ];

      case 'SCALE':
        return [
          spacer,
          const _DynamicSectionLabel(label: 'Scale Settings', icon: Icons.linear_scale),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _scaleMinController,
                  label: 'Minimum Value',
                  hint: '0',
                  prefixIcon: const Icon(Icons.first_page),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (int.tryParse(v) == null) return 'Invalid';
                    return null;
                  },
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  controller: _scaleMaxController,
                  label: 'Maximum Value',
                  hint: '10',
                  prefixIcon: const Icon(Icons.last_page),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (int.tryParse(v) == null) return 'Invalid';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ];

      case 'INPUT_TEXT':
        return [
          spacer,
          const _DynamicSectionLabel(label: 'Text Field Settings', icon: Icons.text_fields),
          SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: _placeholderController,
            label: 'Placeholder',
            hint: 'e.g. Write your thoughts here...',
            prefixIcon: const Icon(Icons.short_text),
          ),
        ];

      case 'MULTIPLE_CHOICE':
        return [
          spacer,
          const _DynamicSectionLabel(label: 'Options', icon: Icons.check_box_outlined),
          SizedBox(height: AppSpacing.sm),
          ..._options.asMap().entries.map((e) {
            final idx = e.key;
            final entry = e.value;
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.radio_button_off, size: 18, color: cs.outlineVariant),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: entry.controller,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Option ${idx + 1}',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      size: 20,
                      color: _options.length > 1 ? cs.error : cs.outlineVariant,
                    ),
                    onPressed: _options.length > 1 ? () => _removeOption(idx) : null,
                    tooltip: 'Remove option',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            );
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Option'),
            ),
          ),
        ];

      case 'WELCOME_SCREEN':
      case 'THANK_YOU_SCREEN':
        final typeLabel = _selectedType == 'WELCOME_SCREEN'
            ? 'Welcome Screen'
            : 'Thank You Screen';
        return [
          spacer,
          _DynamicSectionLabel(
            label: '$typeLabel Settings',
            icon: _selectedType == 'WELCOME_SCREEN'
                ? Icons.waving_hand_outlined
                : Icons.celebration_outlined,
          ),
          SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: _buttonTextController,
            label: 'Button Text',
            hint: _selectedType == 'WELCOME_SCREEN' ? 'e.g. Start' : 'e.g. Done',
            prefixIcon: const Icon(Icons.smart_button),
          ),
        ];

      // YES_NO, PHONE_NUMBER, ORDER_ITEMS — no extra settings
      default:
        return [];
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Holds a [TextEditingController] for each option in a Multiple Choice
/// question so option text survives rebuilds.
class _OptionEntry {
  final TextEditingController controller;
  _OptionEntry(this.controller);
}

/// Small section label used inside the dynamic-fields area.
class _DynamicSectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _DynamicSectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: cs.primary),
        SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: tt.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.primary,
          ),
        ),
      ],
    );
  }
}
