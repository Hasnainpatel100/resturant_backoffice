import '../../imports/imports.dart';
class FeedbackQuestionSettings extends Equatable {
  final String? placeholder;
  final int? min;
  final int? max;
  final int? maxRating;
  final String? buttonText;

  const FeedbackQuestionSettings({
    this.placeholder,
    this.min,
    this.max,
    this.maxRating,
    this.buttonText,
  });

  factory FeedbackQuestionSettings.fromJson(Map<String, dynamic> json) =>
      FeedbackQuestionSettings(
        placeholder: json['placeholder'] as String?,
        min: (json['min'] as num?)?.toInt(),
        max: (json['max'] as num?)?.toInt(),
        maxRating: (json['maxRating'] as num?)?.toInt(),
        buttonText: json['buttonText'] as String?,
      );

  Map<String, dynamic> toJson() => {
    if (placeholder != null) 'placeholder': placeholder,
    if (min != null) 'min': min,
    if (max != null) 'max': max,
    if (maxRating != null) 'maxRating': maxRating,
    if (buttonText != null) 'buttonText': buttonText,
  };

  FeedbackQuestionSettings copyWith({
    String? placeholder,
    int? min,
    int? max,
    int? maxRating,
    String? buttonText,
  }) =>
      FeedbackQuestionSettings(
        placeholder: placeholder ?? this.placeholder,
        min: min ?? this.min,
        max: max ?? this.max,
        maxRating: maxRating ?? this.maxRating,
        buttonText: buttonText ?? this.buttonText,
      );

  @override
  List<Object?> get props => [placeholder, min, max, maxRating, buttonText];
}
