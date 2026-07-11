
import '../../../data/models/feedback_configuration_model.dart';
import '../../../data/models/feedback_question_model.dart';
import '../../../imports/imports.dart';

enum FeedbackBuilderStatus {
  initial,
  editing,
  saving,
  success,
  failure,
}

class FeedbackBuilderState extends Equatable {
  final FeedbackBuilderStatus status;
  final FeedbackConfigurationModel? configuration;
  final List<FeedbackQuestionModel> questions;
  final String? errorMessage;

  const FeedbackBuilderState({
    this.status = FeedbackBuilderStatus.initial,
    this.configuration,
    this.questions = const [],
    this.errorMessage,
  });

  bool get isEditMode => configuration?.id.isNotEmpty ?? false;

  bool get isSaving => status == FeedbackBuilderStatus.saving;

  bool get hasConfiguration => configuration != null;

  bool get hasQuestions => questions.isNotEmpty;

  FeedbackBuilderState copyWith({
    FeedbackBuilderStatus? status,
    FeedbackConfigurationModel? configuration,
    List<FeedbackQuestionModel>? questions,
    String? errorMessage,
  }) {
    return FeedbackBuilderState(
      status: status ?? this.status,
      configuration: configuration ?? this.configuration,
      questions: questions ?? this.questions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    configuration,
    questions,
    errorMessage,
  ];
}