import '../../imports/imports.dart';

class FeedbackAnswer extends Equatable {
  final String questionId;
  final dynamic answer;

  const FeedbackAnswer({
    required this.questionId,
    required this.answer,
  });

  factory FeedbackAnswer.fromJson(Map<String, dynamic> json) => FeedbackAnswer(
    questionId: json['questionId'] as String? ?? '',
    answer: json['answer'],
  );

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'answer': answer,
  };

  FeedbackAnswer copyWith({String? questionId, dynamic answer}) => FeedbackAnswer(
    questionId: questionId ?? this.questionId,
    answer: answer ?? this.answer,
  );

  @override
  List<Object?> get props => [questionId, answer];
}
