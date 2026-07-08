import 'package:go_router/go_router.dart';

import '../../data/models/feedback_question_model.dart';
import '../../data/models/feedback_question_option.dart';
import '../../data/models/feedback_question_settings.dart';
import '../../imports/core_imports.dart';
import 'feedback_question_dialog.dart';

/// Step 2 of the Feedback Management wizard — Question Builder.
///
/// Displays a two-column layout:
///   • Left: reorderable list of questions with edit / delete controls.
///   • Right: live phone-frame preview of the currently selected question.
class FeedbackQuestionBuilderScreen extends StatefulWidget {
  const FeedbackQuestionBuilderScreen({super.key});

  @override
  State<FeedbackQuestionBuilderScreen> createState() =>
      _FeedbackQuestionBuilderScreenState();
}

class _FeedbackQuestionBuilderScreenState
    extends State<FeedbackQuestionBuilderScreen> {
  // ── Dummy data ────────────────────────────────────────────────────────────

  late List<FeedbackQuestionModel> _questions;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _questions = _buildDummyQuestions();
  }

  List<FeedbackQuestionModel> _buildDummyQuestions() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      FeedbackQuestionModel(
        id: 'q_001',
        brandId: 'brand_001',
        branchId: 'branch_kp',
        feedbackConfigurationId: 'fbc_001',
        type: 'WELCOME_SCREEN',
        title: 'Welcome to our feedback!',
        description: 'We value your opinion. Please take a moment to share your experience.',
        isRequired: false,
        displayOrder: 0,
        settings: const FeedbackQuestionSettings(buttonText: 'Start'),
        createdAt: now,
        createdBy: 'admin@brand.com',
      ),
      FeedbackQuestionModel(
        id: 'q_002',
        brandId: 'brand_001',
        branchId: 'branch_kp',
        feedbackConfigurationId: 'fbc_001',
        type: 'RATING',
        title: 'How would you rate your overall experience?',
        isRequired: true,
        displayOrder: 1,
        settings: const FeedbackQuestionSettings(maxRating: 5),
        createdAt: now,
        createdBy: 'admin@brand.com',
      ),
      FeedbackQuestionModel(
        id: 'q_003',
        brandId: 'brand_001',
        branchId: 'branch_kp',
        feedbackConfigurationId: 'fbc_001',
        type: 'MULTIPLE_CHOICE',
        title: 'What did you enjoy the most?',
        isRequired: true,
        displayOrder: 2,
        options: const [
          FeedbackQuestionOption(text: 'Food Quality', value: 'food', displayOrder: 0),
          FeedbackQuestionOption(text: 'Ambience', value: 'ambience', displayOrder: 1),
          FeedbackQuestionOption(text: 'Service', value: 'service', displayOrder: 2),
          FeedbackQuestionOption(text: 'Value for Money', value: 'value', displayOrder: 3),
        ],
        createdAt: now,
        createdBy: 'admin@brand.com',
      ),
      FeedbackQuestionModel(
        id: 'q_004',
        brandId: 'brand_001',
        branchId: 'branch_kp',
        feedbackConfigurationId: 'fbc_001',
        type: 'SCALE',
        title: 'How likely are you to recommend us?',
        description: '0 = Not likely, 10 = Very likely',
        isRequired: true,
        displayOrder: 3,
        settings: const FeedbackQuestionSettings(min: 0, max: 10),
        createdAt: now,
        createdBy: 'admin@brand.com',
      ),
      FeedbackQuestionModel(
        id: 'q_005',
        brandId: 'brand_001',
        branchId: 'branch_kp',
        feedbackConfigurationId: 'fbc_001',
        type: 'YES_NO',
        title: 'Would you visit us again?',
        isRequired: false,
        displayOrder: 4,
        createdAt: now,
        createdBy: 'admin@brand.com',
      ),
      FeedbackQuestionModel(
        id: 'q_006',
        brandId: 'brand_001',
        branchId: 'branch_kp',
        feedbackConfigurationId: 'fbc_001',
        type: 'INPUT_TEXT',
        title: 'Any additional comments?',
        isRequired: false,
        displayOrder: 5,
        settings: const FeedbackQuestionSettings(placeholder: 'Write your thoughts here...'),
        createdAt: now,
        createdBy: 'admin@brand.com',
      ),
      FeedbackQuestionModel(
        id: 'q_007',
        brandId: 'brand_001',
        branchId: 'branch_kp',
        feedbackConfigurationId: 'fbc_001',
        type: 'PHONE_NUMBER',
        title: 'Enter your phone number',
        description: 'We may contact you for a follow-up.',
        isRequired: false,
        displayOrder: 6,
        createdAt: now,
        createdBy: 'admin@brand.com',
      ),
      FeedbackQuestionModel(
        id: 'q_008',
        brandId: 'brand_001',
        branchId: 'branch_kp',
        feedbackConfigurationId: 'fbc_001',
        type: 'THANK_YOU_SCREEN',
        title: 'Thank you for your feedback!',
        description: 'Your response has been recorded.',
        isRequired: false,
        displayOrder: 7,
        settings: const FeedbackQuestionSettings(buttonText: 'Done'),
        createdAt: now,
        createdBy: 'admin@brand.com',
      ),
    ];
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _goBack() => context.pop();

  void _onSaveFeedback() {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Text('Please add at least one question.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            showCloseIcon: true,
            closeIconColor: Theme.of(context).colorScheme.onError,
          ),
        );
      return;
    }

    // Simulate save — no API call.
    _showSaveSuccessDialog();
  }

  void _showSaveSuccessDialog() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: const RoundedRectangleBorder(borderRadius: AppBorders.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 36,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // Title
                Text(
                  'Feedback Saved',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),

                // Message
                Text(
                  'Your feedback form has been saved successfully.',
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                SizedBox(height: AppSpacing.lg),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Stay Here',
                        variant: ButtonVariant.outline,
                        isFullWidth: true,
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ),
                    SizedBox(width: AppSpacing.ms),
                    Expanded(
                      child: AppButton(
                        label: 'Back to Feedback List',
                        variant: ButtonVariant.primary,
                        isFullWidth: true,
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.go('/feedback');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDeleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      if (_selectedIndex >= _questions.length) {
        _selectedIndex = (_questions.length - 1).clamp(0, _questions.length);
      }
    });
  }

  Future<void> _onAddQuestion() async {
    final result = await FeedbackQuestionDialog.show(context);
    if (result != null && mounted) {
      setState(() {
        _questions.add(result.copyWith(displayOrder: _questions.length));
        _selectedIndex = _questions.length - 1;
      });
    }
  }

  Future<void> _onEditQuestion(int index) async {
    final result = await FeedbackQuestionDialog.show(
      context,
      question: _questions[index],
    );
    if (result != null && mounted) {
      setState(() {
        _questions[index] = result.copyWith(displayOrder: index);
      });
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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

  String _labelForType(String type) {
    switch (type) {
      case 'WELCOME_SCREEN':
        return 'Welcome';
      case 'PHONE_NUMBER':
        return 'Phone';
      case 'RATING':
        return 'Rating';
      case 'MULTIPLE_CHOICE':
        return 'Choice';
      case 'INPUT_TEXT':
        return 'Text';
      case 'SCALE':
        return 'Scale';
      case 'YES_NO':
        return 'Yes / No';
      case 'ORDER_ITEMS':
        return 'Order Items';
      case 'THANK_YOU_SCREEN':
        return 'Thank You';
      default:
        return 'Unknown';
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            _buildHeader(cs, tt),
            const Divider(height: 1),

            // ── Step indicator ───────────────────────────────────────────────
            _buildStepIndicator(cs, tt),
            const Divider(height: 1),

            // ── Main two-column content ─────────────────────────────────────
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Collapse to single column below 720 px
                  final isWide = constraints.maxWidth >= 720;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: questions
                        Expanded(flex: 5, child: _buildQuestionsPanel(cs, tt)),
                        VerticalDivider(width: 1, color: cs.outlineVariant),
                        // Right: preview
                        Expanded(flex: 4, child: _buildPreviewPanel(cs, tt)),
                      ],
                    );
                  }
                  // Narrow — only the questions panel
                  return _buildQuestionsPanel(cs, tt);
                },
              ),
            ),

            // ── Bottom action bar ───────────────────────────────────────────
            const Divider(height: 1),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(ColorScheme cs, TextTheme tt) {
    return Padding(
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
                  'Question Builder',
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Build your customer feedback form.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step indicator ──────────────────────────────────────────────────────────

  Widget _buildStepIndicator(ColorScheme cs, TextTheme tt) {
    const steps = ['General Information', 'Questions', 'Preview'];
    const currentStep = 1; // 0-indexed

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.ms,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 2 of 3',
            style: tt.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                // Connector line
                final stepBefore = i ~/ 2;
                final isCompleted = stepBefore < currentStep;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? cs.primary : cs.outlineVariant,
                  ),
                );
              }
              final stepIndex = i ~/ 2;
              final isCompleted = stepIndex < currentStep;
              final isCurrent = stepIndex == currentStep;

              final circleColor = isCompleted
                  ? cs.primary
                  : isCurrent
                      ? cs.primary
                      : cs.outlineVariant;
              final textColor = isCompleted || isCurrent
                  ? cs.onPrimary
                  : cs.onSurfaceVariant;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: isCompleted
                        ? Icon(Icons.check, size: 16, color: textColor)
                        : Text(
                            '${stepIndex + 1}',
                            style: tt.labelSmall?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    steps[stepIndex],
                    style: tt.labelSmall?.copyWith(
                      color: isCurrent ? cs.primary : cs.onSurfaceVariant,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Left panel: Questions ─────────────────────────────────────────────────

  Widget _buildQuestionsPanel(ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header
          _SectionHeader(
            icon: Icons.quiz_outlined,
            title: 'Questions',
            color: cs.primary,
            trailing: Text(
              '${_questions.length} items',
              style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          SizedBox(height: AppSpacing.sm),

          // Question cards
          Expanded(
            child: _questions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 48, color: cs.outlineVariant),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'No questions yet',
                          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _questions.length,
                    separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final q = _questions[index];
                      final isSelected = index == _selectedIndex;
                      return _QuestionCard(
                        question: q,
                        index: index,
                        isSelected: isSelected,
                        icon: _iconForType(q.type),
                        typeLabel: _labelForType(q.type),
                        onTap: () => setState(() => _selectedIndex = index),
                        onEdit: () => _onEditQuestion(index),
                        onDelete: () => _onDeleteQuestion(index),
                      );
                    },
                  ),
          ),

          SizedBox(height: AppSpacing.ms),

          // Add Question button
          AppButton(
            label: 'Add Question',
            variant: ButtonVariant.primary,
            isFullWidth: true,
            prefixIcon: const Icon(Icons.add, size: 18),
            onPressed: _onAddQuestion,
          ),
        ],
      ),
    );
  }

  // ── Right panel: Live preview ─────────────────────────────────────────────

  Widget _buildPreviewPanel(ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            icon: Icons.smartphone,
            title: 'Live Preview',
            color: cs.tertiary,
          ),
          SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Center(
              child: _PhoneMockup(
                question: _questions.isNotEmpty && _selectedIndex < _questions.length
                    ? _questions[_selectedIndex]
                    : null,
                iconForType: _iconForType,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.ms,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppButton(
            label: 'Back',
            variant: ButtonVariant.outline,
            prefixIcon: const Icon(Icons.arrow_back, size: 18),
            onPressed: _goBack,
          ),
          SizedBox(width: AppSpacing.ms),
          AppButton(
            label: 'Save Feedback',
            variant: ButtonVariant.primary,
            prefixIcon: const Icon(Icons.check, size: 18),
            onPressed: _onSaveFeedback,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Reusable section header — same pattern used across Backoffice screens.
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget? trailing;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
    this.trailing,
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
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Question card
// ─────────────────────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final FeedbackQuestionModel question;
  final int index;
  final bool isSelected;
  final IconData icon;
  final String typeLabel;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.isSelected,
    required this.icon,
    required this.typeLabel,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: isSelected ? cs.primaryContainer : cs.surfaceContainerLow,
      borderRadius: AppBorders.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.card,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppBorders.card,
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.ms,
            vertical: AppSpacing.ms,
          ),
          child: Row(
            children: [
              // Drag handle
              Icon(
                Icons.drag_indicator,
                size: 20,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              SizedBox(width: AppSpacing.sm),

              // Type icon chip
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: AppBorders.sm,
                ),
                child: Icon(icon, size: 18, color: cs.primary),
              ),
              SizedBox(width: AppSpacing.ms),

              // Title + type label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          typeLabel,
                          style: tt.labelSmall?.copyWith(
                            color: isSelected
                                ? cs.onPrimaryContainer.withValues(alpha: 0.7)
                                : cs.onSurfaceVariant,
                          ),
                        ),
                        if (question.isRequired) ...[
                          SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cs.error.withValues(alpha: 0.1),
                              borderRadius: AppBorders.xs,
                            ),
                            child: Text(
                              'Required',
                              style: tt.labelSmall?.copyWith(
                                color: cs.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 18, color: cs.onSurfaceVariant),
                onPressed: onEdit,
                tooltip: 'Edit',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
                onPressed: onDelete,
                tooltip: 'Delete',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phone mockup + live preview
// ─────────────────────────────────────────────────────────────────────────────

class _PhoneMockup extends StatelessWidget {
  final FeedbackQuestionModel? question;
  final IconData Function(String type) iconForType;

  const _PhoneMockup({
    required this.question,
    required this.iconForType,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 300,
      height: 560,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: cs.outlineVariant, width: 3),
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        children: [
          // ── Phone notch ──────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 100,
            height: 6,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // ── Status bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '9:41',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.signal_cellular_alt, size: 14, color: cs.onSurface),
                    const SizedBox(width: 4),
                    Icon(Icons.wifi, size: 14, color: cs.onSurface),
                    const SizedBox(width: 4),
                    Icon(Icons.battery_full, size: 14, color: cs.onSurface),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant),

          // ── Preview content ───────────────────────────────────────────────
          Expanded(
            child: question == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_outlined, size: 40, color: cs.outlineVariant),
                        const SizedBox(height: 8),
                        Text(
                          'Select a question\nto preview',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  )
                : _buildQuestionPreview(context, question!),
          ),

          // ── Home indicator ────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(bottom: 8, top: 4),
            width: 120,
            height: 5,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPreview(BuildContext context, FeedbackQuestionModel q) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: AppBorders.full,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconForType(q.type), size: 14, color: cs.onPrimaryContainer),
                const SizedBox(width: 4),
                Text(
                  q.questionType.name.replaceAllMapped(
                    RegExp(r'[A-Z]'),
                    (m) => ' ${m.group(0)}',
                  ),
                  style: tt.labelSmall?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            q.title,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          if (q.description != null && q.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              q.description!,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
          if (q.isRequired) ...[
            const SizedBox(height: 8),
            Text(
              '* Required',
              style: tt.labelSmall?.copyWith(
                color: cs.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Type-specific preview
          _buildTypeSpecificPreview(context, q),
        ],
      ),
    );
  }

  Widget _buildTypeSpecificPreview(BuildContext context, FeedbackQuestionModel q) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    switch (q.questionType) {
      case FeedbackQuestionType.welcomeScreen:
      case FeedbackQuestionType.thankYouScreen:
        final btnLabel = q.settings.buttonText ?? 'Continue';
        return Center(
          child: Column(
            children: [
              Icon(
                q.isWelcomeScreen ? Icons.waving_hand : Icons.celebration,
                size: 48,
                color: cs.primary,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: null,
                  child: Text(btnLabel),
                ),
              ),
            ],
          ),
        );

      case FeedbackQuestionType.rating:
        final maxRating = q.settings.maxRating ?? 5;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            maxRating,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                i < 3 ? Icons.star : Icons.star_border,
                size: 32,
                color: i < 3 ? Colors.amber : cs.outlineVariant,
              ),
            ),
          ),
        );

      case FeedbackQuestionType.multipleChoice:
        return Column(
          children: q.options.map((opt) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: cs.outlineVariant),
                  borderRadius: AppBorders.sm,
                ),
                child: Row(
                  children: [
                    Icon(Icons.radio_button_off, size: 18, color: cs.outlineVariant),
                    const SizedBox(width: 10),
                    Text(opt.text, style: tt.bodyMedium),
                  ],
                ),
              ),
            );
          }).toList(),
        );

      case FeedbackQuestionType.scale:
        final min = q.settings.min ?? 0;
        final max = q.settings.max ?? 10;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$min', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                Text('$max', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: 7,
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: max - min,
                onChanged: null,
              ),
            ),
          ],
        );

      case FeedbackQuestionType.yesNo:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.thumb_up_outlined, size: 18),
                label: const Text('Yes'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.thumb_down_outlined, size: 18),
                label: const Text('No'),
              ),
            ),
          ],
        );

      case FeedbackQuestionType.inputText:
        return Container(
          width: double.infinity,
          height: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outlineVariant),
            borderRadius: AppBorders.sm,
          ),
          child: Text(
            q.settings.placeholder ?? 'Type your answer...',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        );

      case FeedbackQuestionType.phoneNumber:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outlineVariant),
            borderRadius: AppBorders.sm,
          ),
          child: Row(
            children: [
              Icon(Icons.phone_outlined, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 10),
              Text(
                '+91 XXXXX XXXXX',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        );

      case FeedbackQuestionType.orderItems:
        return Column(
          children: List.generate(
            2,
            (i) => Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: i < 1 ? 8 : 0),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: cs.outlineVariant),
                borderRadius: AppBorders.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.fastfood_outlined, size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Text('Order item ${i + 1}', style: tt.bodySmall),
                ],
              ),
            ),
          ),
        );

      case FeedbackQuestionType.unknown:
        return Center(
          child: Text(
            'Unknown question type',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        );
    }
  }
}
