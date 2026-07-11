// import 'package:back_office/utils/utils.dart';
//
// import '../datasources/feedback/feedback_local_data_source.dart';
// import '../models/feedback_configuration_model.dart';
// import '../models/feedback_question_model.dart';
// import 'feedback_repository.dart';
//
// class FeedbackRepositoryLocalImpl implements FeedbackRepository {
//   final FeedbackLocalDataSource _localDataSource;
//
//   FeedbackRepositoryLocalImpl({
//     required FeedbackLocalDataSource localDataSource,
//   }) : _localDataSource = localDataSource;
//
//   @override
//   FutureEither<List<FeedbackConfigurationModel>> getFeedbackConfigurations(
//       String brandId,
//       String branchId,
//       ) async {
//     return runTask(() async {
//       return _localDataSource.getFeedbackConfigurations(
//         brandId,
//         branchId,
//       );
//     });
//   }
//
//   @override
//   FutureEither<FeedbackConfigurationModel> getFeedbackConfiguration(
//       String feedbackConfigurationId,
//       ) async {
//     return runTask(() async {
//       final configuration =
//       await _localDataSource.getFeedbackConfiguration(
//         feedbackConfigurationId,
//       );
//
//       if (configuration == null) {
//         throw Exception(
//           'Feedback configuration not found: $feedbackConfigurationId',
//         );
//       }
//
//       return configuration;
//     });
//   }
//
//   @override
//   FutureEither<List<FeedbackQuestionModel>> getFeedbackQuestions(
//       String feedbackConfigurationId,
//       ) async {
//     return runTask(() async {
//       return _localDataSource.getFeedbackQuestions(
//         feedbackConfigurationId,
//       );
//     });
//   }
//
//   @override
//   FutureEither<FeedbackConfigurationModel> createFeedback(
//       String brandId,
//       Map<String, dynamic> data,
//       ) async {
//     return runTask(() async {
//       final configurationJson =
//       Map<String, dynamic>.from(data['configuration'] as Map);
//
//       final configuration = FeedbackConfigurationModel.fromJson({
//         ...configurationJson,
//         'brandId': brandId,
//       });
//
//       final questionsJson =
//       (data['questions'] as List<dynamic>? ?? const []);
//
//       final questions = questionsJson
//           .map(
//             (item) => FeedbackQuestionModel.fromJson(
//           Map<String, dynamic>.from(item as Map),
//         ),
//       )
//           .toList();
//
//       return _localDataSource.createFeedback(
//         configuration: configuration,
//         questions: questions,
//       );
//     });
//   }
//
//   @override
//   FutureEither<FeedbackConfigurationModel> updateFeedback(
//       String feedbackConfigurationId,
//       Map<String, dynamic> data,
//       ) async {
//     return runTask(() async {
//       final configurationJson =
//       Map<String, dynamic>.from(data['configuration'] as Map);
//
//       final configuration = FeedbackConfigurationModel.fromJson({
//         ...configurationJson,
//         'id': feedbackConfigurationId,
//       });
//
//       final questionsJson =
//       (data['questions'] as List<dynamic>? ?? const []);
//
//       final questions = questionsJson
//           .map(
//             (item) => FeedbackQuestionModel.fromJson(
//           Map<String, dynamic>.from(item as Map),
//         ),
//       )
//           .toList();
//
//       return _localDataSource.updateFeedback(
//         configuration: configuration,
//         questions: questions,
//       );
//     });
//   }
//
//   @override
//   FutureEither<void> deleteFeedback(
//       String feedbackConfigurationId,
//       ) async {
//     return runTask(() async {
//       await _localDataSource.deleteFeedback(
//         feedbackConfigurationId,
//       );
//     });
//   }
// }