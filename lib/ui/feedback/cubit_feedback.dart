import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/feedback_configuration_model.dart';
import '../../data/models/feedback_question_model.dart';
import '../../data/repositories/feedback_repository.dart';
import 'state_feedback.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state_feedback.dart';

class CubitFeedback extends Cubit<StateFeedback> {
  final FeedbackRepository _feedbackRepository;

  CubitFeedback({
    required FeedbackRepository feedbackRepository,
  })  : _feedbackRepository = feedbackRepository,
        super(const StateFeedback());

  /// Loads all feedback configurations for the selected brand and branch.
  Future<void> loadFeedbackConfigurations(
      String brandId,
      String branchId,
      ) async {
    emit(
      state.copyWith(
        status: FeedbackCubitStatus.loading,
        clearErrorMessage: true,
      ),
    );

    final result = await _feedbackRepository.getFeedbackConfigurations(
      brandId,
      branchId,
    );

    result.fold(
          (failure) => emit(
        state.copyWith(
          status: FeedbackCubitStatus.error,
          errorMessage: failure.message,
        ),
      ),
          (configurations) => emit(
        state.copyWith(
          status: FeedbackCubitStatus.loaded,
          configurations: configurations,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  /// Loads one configuration and all its questions.
  ///
  /// Useful for View and Edit workflows.
  Future<void> loadFeedback(
      String feedbackConfigurationId,
      ) async {
    emit(
      state.copyWith(
        status: FeedbackCubitStatus.loading,
        clearErrorMessage: true,
      ),
    );

    final configurationResult =
    await _feedbackRepository.getFeedbackConfiguration(
      feedbackConfigurationId,
    );

    await configurationResult.fold(
          (failure) async {
        emit(
          state.copyWith(
            status: FeedbackCubitStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
          (configuration) async {
        final questionsResult =
        await _feedbackRepository.getFeedbackQuestions(
          feedbackConfigurationId,
        );

        questionsResult.fold(
              (failure) => emit(
            state.copyWith(
              status: FeedbackCubitStatus.error,
              errorMessage: failure.message,
            ),
          ),
              (questions) => emit(
            state.copyWith(
              status: FeedbackCubitStatus.loaded,
              selected: configuration,
              draftQuestions: questions,
              clearErrorMessage: true,
            ),
          ),
        );
      },
    );
  }

  /// Starts a completely new Create Feedback workflow.
  ///
  /// Existing saved configurations remain untouched.
  void startCreate() {
    emit(
      StateFeedback(
        status: FeedbackCubitStatus.initial,
        configurations: state.configurations,
      ),
    );
  }

  /// Starts editing an already loaded feedback configuration.
  void startEdit({
    required FeedbackConfigurationModel configuration,
    required List<FeedbackQuestionModel> questions,
  }) {
    emit(
      StateFeedback(
        status: FeedbackCubitStatus.loaded,
        configurations: state.configurations,
        selected: configuration,
        draftConfiguration: configuration,
        draftQuestions: List<FeedbackQuestionModel>.from(questions),
      ),
    );
  }

  /// Stores configuration data entered on the Create/Edit screen.
  void setDraftConfiguration(
      FeedbackConfigurationModel configuration,
      ) {
    emit(
      state.copyWith(
        status: FeedbackCubitStatus.loaded,
        draftConfiguration: configuration,
        clearErrorMessage: true,
      ),
    );
  }

  /// Replaces all draft questions.
  void setDraftQuestions(
      List<FeedbackQuestionModel> questions,
      ) {
    emit(
      state.copyWith(
        draftQuestions: List<FeedbackQuestionModel>.from(questions),
        clearErrorMessage: true,
      ),
    );
  }

  /// Adds one question to the current draft.
  void addQuestion(FeedbackQuestionModel question) {
    final updatedQuestions = [
      ...state.draftQuestions,
      question,
    ];

    emit(
      state.copyWith(
        draftQuestions: updatedQuestions,
        clearErrorMessage: true,
      ),
    );
  }

  /// Updates a question using its ID.
  void updateQuestion(FeedbackQuestionModel updatedQuestion) {
    final index = state.draftQuestions.indexWhere(
          (question) => question.id == updatedQuestion.id,
    );

    if (index == -1) {
      emit(
        state.copyWith(
          status: FeedbackCubitStatus.error,
          errorMessage: 'Question not found.',
        ),
      );
      return;
    }

    final updatedQuestions =
    List<FeedbackQuestionModel>.from(state.draftQuestions);

    updatedQuestions[index] = updatedQuestion;

    emit(
      state.copyWith(
        status: FeedbackCubitStatus.loaded,
        draftQuestions: updatedQuestions,
        clearErrorMessage: true,
      ),
    );
  }

  /// Deletes one question from the current draft.
  void deleteQuestion(String questionId) {
    final updatedQuestions = state.draftQuestions
        .where((question) => question.id != questionId)
        .toList();

    emit(
      state.copyWith(
        draftQuestions: updatedQuestions,
        clearErrorMessage: true,
      ),
    );
  }

  /// Reorders questions and synchronizes displayOrder.
  void reorderQuestions(int oldIndex, int newIndex) {
    final updatedQuestions =
    List<FeedbackQuestionModel>.from(state.draftQuestions);

    if (oldIndex < 0 ||
        oldIndex >= updatedQuestions.length ||
        newIndex < 0 ||
        newIndex > updatedQuestions.length) {
      return;
    }

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final movedQuestion = updatedQuestions.removeAt(oldIndex);
    updatedQuestions.insert(newIndex, movedQuestion);

    final reorderedQuestions = updatedQuestions
        .asMap()
        .entries
        .map(
          (entry) => entry.value.copyWith(
        displayOrder: entry.key,
      ),
    )
        .toList();

    emit(
      state.copyWith(
        draftQuestions: reorderedQuestions,
        clearErrorMessage: true,
      ),
    );
  }

  /// Saves the complete feedback form.
  ///
  /// Create mode:
  ///   createFeedback()
  ///
  /// Edit mode:
  ///   updateFeedback()
  Future<void> saveFeedback() async {
    final configuration = state.draftConfiguration;

    if (configuration == null) {
      emit(
        state.copyWith(
          status: FeedbackCubitStatus.error,
          errorMessage: 'Feedback configuration is required.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: FeedbackCubitStatus.saving,
        clearErrorMessage: true,
      ),
    );

    final data = <String, dynamic>{
      'configuration': configuration.toJson(),
      'questions': state.draftQuestions
          .map((question) => question.toJson())
          .toList(),
    };

    final isEdit = state.selected != null;

    final result = isEdit
        ? await _feedbackRepository.updateFeedback(
      configuration.id,
      data,
    )
        : await _feedbackRepository.createFeedback(
      configuration.brandId,
      data,
    );

    result.fold(
          (failure) => emit(
        state.copyWith(
          status: FeedbackCubitStatus.error,
          errorMessage: failure.message,
        ),
      ),
          (savedConfiguration) {
        final updatedConfigurations =
        List<FeedbackConfigurationModel>.from(
          state.configurations,
        );

        final existingIndex = updatedConfigurations.indexWhere(
              (item) => item.id == savedConfiguration.id,
        );

        if (existingIndex >= 0) {
          updatedConfigurations[existingIndex] = savedConfiguration;
        } else {
          updatedConfigurations.add(savedConfiguration);
        }

        emit(
          state.copyWith(
            status: FeedbackCubitStatus.success,
            configurations: updatedConfigurations,
            selected: savedConfiguration,
            draftConfiguration: savedConfiguration,
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  /// Deletes a feedback form from local storage.
  Future<void> deleteFeedback(
      String feedbackConfigurationId,
      ) async {
    emit(
      state.copyWith(
        status: FeedbackCubitStatus.loading,
        clearErrorMessage: true,
      ),
    );

    final result = await _feedbackRepository.deleteFeedback(
      feedbackConfigurationId,
    );

    result.fold(
          (failure) => emit(
        state.copyWith(
          status: FeedbackCubitStatus.error,
          errorMessage: failure.message,
        ),
      ),
          (_) {
        final updatedConfigurations = state.configurations
            .where(
              (configuration) =>
          configuration.id != feedbackConfigurationId,
        )
            .toList();

        emit(
          state.copyWith(
            status: FeedbackCubitStatus.success,
            configurations: updatedConfigurations,
            clearSelected: state.selected?.id == feedbackConfigurationId,
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  /// Selects a configuration for the View workflow.
  void selectFeedback(
      FeedbackConfigurationModel configuration,
      ) {
    emit(
      state.copyWith(
        selected: configuration,
        clearErrorMessage: true,
      ),
    );
  }

  /// Clears the currently selected feedback.
  void clearSelection() {
    emit(
      state.copyWith(
        clearSelected: true,
      ),
    );
  }

  /// Clears the Create/Edit draft while preserving the loaded list.
  void clearDraft() {
    emit(
      StateFeedback(
        status: FeedbackCubitStatus.initial,
        configurations: state.configurations,
      ),
    );
  }

  /// Clears the current error.
  void clearError() {
    emit(
      state.copyWith(
        clearErrorMessage: true,
      ),
    );
  }
}