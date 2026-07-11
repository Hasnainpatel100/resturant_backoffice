import 'package:equatable/equatable.dart';

import '../../data/models/feedback_configuration_model.dart';
import '../../data/models/feedback_question_model.dart';

enum FeedbackCubitStatus {
  initial,
  loading,
  loaded,
  saving,
  success,
  error,
}

class StateFeedback extends Equatable {
  /// Current Cubit operation status.
  final FeedbackCubitStatus status;

  /// All saved feedback configurations displayed on the
  /// Feedback Configuration list screen.
  final List<FeedbackConfigurationModel> configurations;

  /// Currently selected feedback configuration.
  ///
  /// Used when viewing or editing an existing feedback form.
  final FeedbackConfigurationModel? selected;

  /// Temporary configuration being created or edited.
  ///
  /// Screen 2 writes to this field before navigating
  /// to the Question Builder.
  final FeedbackConfigurationModel? draftConfiguration;

  /// Temporary questions belonging to the current feedback draft.
  ///
  /// Screen 3 manages this list while adding, editing,
  /// deleting or reordering questions.
  final List<FeedbackQuestionModel> draftQuestions;

  /// Error message from local storage, repository or API operations.
  final String? errorMessage;

  const StateFeedback({
    this.status = FeedbackCubitStatus.initial,
    this.configurations = const [],
    this.selected,
    this.draftConfiguration,
    this.draftQuestions = const [],
    this.errorMessage,
  });

  /// True when an existing feedback configuration is being edited.
  bool get isEditMode => selected != null;

  /// True when a draft configuration currently exists.
  bool get hasDraft => draftConfiguration != null;

  /// True when the current draft contains at least one question.
  bool get hasQuestions => draftQuestions.isNotEmpty;

  /// True while feedback data is initially loading.
  bool get isLoading => status == FeedbackCubitStatus.loading;

  /// True while the complete feedback form is being saved.
  bool get isSaving => status == FeedbackCubitStatus.saving;

  StateFeedback copyWith({
    FeedbackCubitStatus? status,
    List<FeedbackConfigurationModel>? configurations,
    FeedbackConfigurationModel? selected,
    FeedbackConfigurationModel? draftConfiguration,
    List<FeedbackQuestionModel>? draftQuestions,
    String? errorMessage,

    /// Explicitly clears nullable state values.
    bool clearSelected = false,
    bool clearDraftConfiguration = false,
    bool clearErrorMessage = false,
  }) {
    return StateFeedback(
      status: status ?? this.status,
      configurations: configurations ?? this.configurations,
      selected: clearSelected ? null : selected ?? this.selected,
      draftConfiguration: clearDraftConfiguration
          ? null
          : draftConfiguration ?? this.draftConfiguration,
      draftQuestions: draftQuestions ?? this.draftQuestions,
      errorMessage:
      clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    configurations,
    selected,
    draftConfiguration,
    draftQuestions,
    errorMessage,
  ];
}