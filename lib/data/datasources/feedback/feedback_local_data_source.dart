// import 'package:hive/hive.dart';
// import '../../models/feedback_configuration_model.dart';
// import '../../models/feedback_question_model.dart';
//
// class FeedbackLocalDataSource {
//   static const String _configurationBoxName =
//       'feedback_configurations';
//
//   static const String _questionsBoxName =
//       'feedback_questions';
//
//   Box<Map>? _configurationBox;
//   Box<Map>? _questionsBox;
//
//   /// Opens the Hive boxes required by Feedback Management.
//   ///
//   /// Safe to call more than once.
//   Future<void> init() async {
//     if (!Hive.isBoxOpen(_configurationBoxName)) {
//       _configurationBox = await Hive.openBox<Map>(
//         _configurationBoxName,
//       );
//     } else {
//       _configurationBox = Hive.box<Map>(
//         _configurationBoxName,
//       );
//     }
//
//     if (!Hive.isBoxOpen(_questionsBoxName)) {
//       _questionsBox = await Hive.openBox<Map>(
//         _questionsBoxName,
//       );
//     } else {
//       _questionsBox = Hive.box<Map>(
//         _questionsBoxName,
//       );
//     }
//   }
//
//   Box<Map> get _configurations {
//     final box = _configurationBox;
//
//     if (box == null || !box.isOpen) {
//       throw StateError(
//         'FeedbackLocalDataSource is not initialized. '
//             'Call init() before using it.',
//       );
//     }
//
//     return box;
//   }
//
//   Box<Map> get _questions {
//     final box = _questionsBox;
//
//     if (box == null || !box.isOpen) {
//       throw StateError(
//         'FeedbackLocalDataSource is not initialized. '
//             'Call init() before using it.',
//       );
//     }
//
//     return box;
//   }
//
//   /// Returns feedback configurations belonging to the given
//   /// brand and branch.
//   Future<List<FeedbackConfigurationModel>> getFeedbackConfigurations(
//       String brandId,
//       String branchId,
//       ) async {
//     final configurations = _configurations.values
//         .map(
//           (data) => FeedbackConfigurationModel.fromJson(
//         Map<String, dynamic>.from(data),
//       ),
//     )
//         .where(
//           (configuration) =>
//       configuration.brandId == brandId &&
//           configuration.branchId == branchId,
//     )
//         .toList();
//
//     configurations.sort(
//           (a, b) => b.createdAt.compareTo(a.createdAt),
//     );
//
//     return configurations;
//   }
//
//   /// Returns one feedback configuration by ID.
//   Future<FeedbackConfigurationModel?> getFeedbackConfiguration(
//       String feedbackConfigurationId,
//       ) async {
//     final data = _configurations.get(feedbackConfigurationId);
//
//     if (data == null) {
//       return null;
//     }
//
//     return FeedbackConfigurationModel.fromJson(
//       Map<String, dynamic>.from(data),
//     );
//   }
//
//   /// Returns all questions belonging to one feedback configuration.
//   Future<List<FeedbackQuestionModel>> getFeedbackQuestions(
//       String feedbackConfigurationId,
//       ) async {
//     final questions = _questions.values
//         .map(
//           (data) => FeedbackQuestionModel.fromJson(
//         Map<String, dynamic>.from(data),
//       ),
//     )
//         .where(
//           (question) =>
//       question.feedbackConfigurationId ==
//           feedbackConfigurationId,
//     )
//         .toList();
//
//     questions.sort(
//           (a, b) => a.displayOrder.compareTo(b.displayOrder),
//     );
//
//     return questions;
//   }
//
//   /// Creates a complete feedback form locally.
//   ///
//   /// Saves the configuration and all its questions.
//   Future<FeedbackConfigurationModel> createFeedback({
//     required FeedbackConfigurationModel configuration,
//     required List<FeedbackQuestionModel> questions,
//   }) async {
//     if (_configurations.containsKey(configuration.id)) {
//       throw StateError(
//         'Feedback configuration with ID ${configuration.id} already exists.',
//       );
//     }
//
//     await _configurations.put(
//       configuration.id,
//       configuration.toJson(),
//     );
//
//     try {
//       for (final question in questions) {
//         await _questions.put(
//           question.id,
//           question.toJson(),
//         );
//       }
//
//       return configuration;
//     } catch (_) {
//       // Roll back the configuration if saving questions fails.
//       await _configurations.delete(configuration.id);
//       rethrow;
//     }
//   }
//
//   /// Updates an existing feedback form locally.
//   ///
//   /// Replaces the configuration and its complete question list.
//   Future<FeedbackConfigurationModel> updateFeedback({
//     required FeedbackConfigurationModel configuration,
//     required List<FeedbackQuestionModel> questions,
//   }) async {
//     if (!_configurations.containsKey(configuration.id)) {
//       throw StateError(
//         'Feedback configuration with ID ${configuration.id} was not found.',
//       );
//     }
//
//     await _configurations.put(
//       configuration.id,
//       configuration.toJson(),
//     );
//
//     final existingQuestionKeys = _questions.keys.where((key) {
//       final data = _questions.get(key);
//
//       if (data == null) {
//         return false;
//       }
//
//       final question = FeedbackQuestionModel.fromJson(
//         Map<String, dynamic>.from(data),
//       );
//
//       return question.feedbackConfigurationId == configuration.id;
//     }).toList();
//
//     await _questions.deleteAll(existingQuestionKeys);
//
//     for (final question in questions) {
//       await _questions.put(
//         question.id,
//         question.toJson(),
//       );
//     }
//
//     return configuration;
//   }
//
//   /// Deletes a configuration and all questions belonging to it.
//   Future<void> deleteFeedback(
//       String feedbackConfigurationId,
//       ) async {
//     await _configurations.delete(feedbackConfigurationId);
//
//     final questionKeys = _questions.keys.where((key) {
//       final data = _questions.get(key);
//
//       if (data == null) {
//         return false;
//       }
//
//       final question = FeedbackQuestionModel.fromJson(
//         Map<String, dynamic>.from(data),
//       );
//
//       return question.feedbackConfigurationId ==
//           feedbackConfigurationId;
//     }).toList();
//
//     await _questions.deleteAll(questionKeys);
//   }
//
//   /// Clears all locally stored Feedback Management data.
//   ///
//   /// Useful for development/testing only.
//   Future<void> clearAll() async {
//     await _configurations.clear();
//     await _questions.clear();
//   }
// }