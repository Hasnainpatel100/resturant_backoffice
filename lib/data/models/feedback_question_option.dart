import '../../imports/imports.dart';
class FeedbackQuestionOption extends Equatable {
  final String text;
  final String value;
  final int displayOrder;

  const FeedbackQuestionOption({
    required this.text,
    required this.value,
    this.displayOrder = 0,
  });

  factory FeedbackQuestionOption.fromJson(Map<String, dynamic> json) =>
      FeedbackQuestionOption(
        text: json['text'] as String? ?? '',
        value: json['value'] as String? ?? '',
        displayOrder:(json['displayOrder'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'text': text,
    'value': value,
    'displayOrder': displayOrder,
  };

  FeedbackQuestionOption copyWith({
    String? text,
    String? value,
    int? displayOrder,
  }) =>
      FeedbackQuestionOption(
        text: text ?? this.text,
        value: value ?? this.value,
        displayOrder: displayOrder ?? this.displayOrder,
      );

  @override
  List<Object?> get props => [text, value, displayOrder];
}
