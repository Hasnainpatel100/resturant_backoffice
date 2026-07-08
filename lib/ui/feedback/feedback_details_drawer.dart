import '../../imports/core_imports.dart';
import '../../data/models/feedback_configuration_model.dart';
import '../../data/models/feedback_question_model.dart';

class FeedbackDetailsDrawer extends StatelessWidget {
  final FeedbackConfigurationModel config;
  final String branchName;
  final List<FeedbackQuestionModel> questions;

  const FeedbackDetailsDrawer({
    super.key,
    required this.config,
    required this.branchName,
    required this.questions,
  });

  static List<FeedbackQuestionModel> buildDummyQuestions(String configId, int count) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final List<String> types = [
      'WELCOME_SCREEN',
      'RATING',
      'MULTIPLE_CHOICE',
      'SCALE',
      'YES_NO',
      'INPUT_TEXT',
      'PHONE_NUMBER',
      'THANK_YOU_SCREEN'
    ];
    final List<String> titles = [
      'Welcome to our feedback survey!',
      'How would you rate your overall experience today?',
      'Which of our services did you enjoy the most?',
      'How likely are you to recommend us to friends and family?',
      'Would you like to sign up for our loyalty program?',
      'Any additional comments or suggestions for us?',
      'Provide your phone number for a follow-up call.',
      'Thank you for sharing your valuable feedback!'
    ];

    return List.generate(count, (index) {
      final typeIndex = index % types.length;
      final type = types[typeIndex];
      final title = titles[typeIndex];
      return FeedbackQuestionModel(
        id: 'q_${configId}_${index + 1}',
        brandId: 'brand_001',
        branchId: 'branch_kp',
        feedbackConfigurationId: configId,
        type: type,
        title: title,
        isRequired: index == 1 || index == 2 || index == 3,
        displayOrder: index,
        createdAt: now,
        createdBy: 'admin@brand.com',
      );
    });
  }

  IconData _getQuestionTypeIcon(String type) {
    switch (type) {
      case 'WELCOME_SCREEN':
        return Icons.waving_hand_outlined;
      case 'PHONE_NUMBER':
        return Icons.phone_android_outlined;
      case 'RATING':
        return Icons.star_outline_rounded;
      case 'MULTIPLE_CHOICE':
        return Icons.list_alt_rounded;
      case 'INPUT_TEXT':
        return Icons.edit_note_rounded;
      case 'SCALE':
        return Icons.linear_scale_rounded;
      case 'YES_NO':
        return Icons.thumbs_up_down_outlined;
      case 'ORDER_ITEMS':
        return Icons.receipt_long_outlined;
      case 'THANK_YOU_SCREEN':
        return Icons.favorite_border_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'WELCOME_SCREEN':
        return 'Welcome Screen'.tr();
      case 'PHONE_NUMBER':
        return 'Phone Number'.tr();
      case 'RATING':
        return 'Rating'.tr();
      case 'MULTIPLE_CHOICE':
        return 'Multiple Choice'.tr();
      case 'INPUT_TEXT':
        return 'Input Text'.tr();
      case 'SCALE':
        return 'Scale'.tr();
      case 'YES_NO':
        return 'Yes/No'.tr();
      case 'ORDER_ITEMS':
        return 'Order Items'.tr();
      case 'THANK_YOU_SCREEN':
        return 'Thank You Screen'.tr();
      default:
        return 'Unknown'.tr();
    }
  }

  Color _statusColor(String status, BuildContext context) {
    switch (status) {
      case 'ACTIVE':
        return context.appColors.success;
      case 'DRAFT':
        return Colors.blueGrey;
      case 'INACTIVE':
        return context.appColors.warning;
      case 'ARCHIVED':
        return context.colors.error;
      default:
        return context.colors.onSurfaceVariant;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Active'.tr();
      case 'DRAFT':
        return 'Draft'.tr();
      case 'INACTIVE':
        return 'Inactive'.tr();
      case 'ARCHIVED':
        return 'Archived'.tr();
      default:
        return status;
    }
  }

  String _sendMethodLabel(String method) {
    switch (method) {
      case 'SMS':
        return 'SMS'.tr();
      case 'WHATSAPP':
        return 'WhatsApp'.tr();
      case 'QR_CODE':
        return 'QR Code'.tr();
      case 'ALL':
        return 'All Channels'.tr();
      case 'DISABLED':
        return 'Disabled'.tr();
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final tt = context.textTheme;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final updatedAtMs = config.updatedAt ?? config.createdAt;
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(updatedAtMs);

    final statusColor = _statusColor(config.status, context);

    return Drawer(
      width: 480,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Form Details'.tr(),
                      style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close'.tr(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Body
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: [
                  // Form general info title
                  Text(
                    'General Information'.tr(),
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Metadata Cards
                  AppCard(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          label: 'Title'.tr(),
                          valueWidget: Expanded(
                            child: Text(
                              config.title,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Branch'.tr(),
                          valueText: branchName,
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Status'.tr(),
                          valueWidget: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              _statusLabel(config.status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Google Form URL'.tr(),
                          valueWidget: Expanded(
                            child: Text(
                              config.googleFormUrl ?? 'Not configured'.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: config.googleFormUrl != null
                                    ? cs.primary
                                    : cs.onSurfaceVariant,
                                fontStyle: config.googleFormUrl != null
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Send Method'.tr(),
                          valueText: _sendMethodLabel(config.sendMethod),
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Delay (Minutes)'.tr(),
                          valueText: '${config.delayMinutes}',
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Minimum Order Amount'.tr(),
                          valueText: '${config.minimumOrderAmount}',
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Default Feedback'.tr(),
                          valueWidget: Icon(
                            config.isDefault
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: config.isDefault
                                ? context.appColors.success
                                : cs.error,
                            size: 20,
                          ),
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Loyalty Enabled'.tr(),
                          valueWidget: Icon(
                            config.loyaltyEnabled
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: config.loyaltyEnabled
                                ? context.appColors.success
                                : cs.error,
                            size: 20,
                          ),
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Last Updated'.tr(),
                          valueText: dateFormat.format(updatedAt),
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Question Count'.tr(),
                          valueText: '${questions.length}',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.lg),

                  // Questions Header
                  Row(
                    children: [
                      Text(
                        'Questions'.tr(),
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${questions.length}',
                          style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Questions List
                  if (questions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No questions configured.'.tr(),
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    ...questions.map((question) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: AppCard(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon background container
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cs.secondaryContainer.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getQuestionTypeIcon(question.type),
                                  color: cs.onSecondaryContainer,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      question.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getQuestionTypeLabel(question.type),
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (question.isRequired)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.appColors.warning.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: context.appColors.warning.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    'Required'.tr(),
                                    style: TextStyle(
                                      color: context.appColors.warning,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
            const Divider(height: 1),

            // Footer / Close Button
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text('Close'.tr()),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String? valueText;
  final Widget? valueWidget;

  const _InfoRow({
    required this.label,
    this.valueText,
    this.valueWidget,
  }) : assert(valueText != null || valueWidget != null);

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final tt = context.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        if (valueWidget != null)
          valueWidget!
        else
          Text(
            valueText!,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
