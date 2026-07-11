import 'package:back_office/utils/utils.dart';

import '../models/feedback_configuration_model.dart';
import '../models/feedback_question_model.dart';

abstract class FeedbackRepository {
  FutureEither<List<FeedbackConfigurationModel>> getFeedbackConfigurations(
      String brandId,
      String branchId,
      );

  FutureEither<FeedbackConfigurationModel> getFeedbackConfiguration(
      String feedbackConfigurationId,
      );

  FutureEither<List<FeedbackQuestionModel>> getFeedbackQuestions(
      String feedbackConfigurationId
      );

  FutureEither<FeedbackConfigurationModel> createFeedback(
      String brandId,
      Map<String, dynamic> data,
      );

  FutureEither<FeedbackConfigurationModel> updateFeedback(
      String feedbackConfigurationId,
      Map<String, dynamic> data,
      );

  FutureEither<void> deleteFeedback(
      String feedbackConfigurationId,
      );
}