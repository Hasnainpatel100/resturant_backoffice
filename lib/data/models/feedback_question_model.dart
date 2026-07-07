import '../../imports/imports.dart';
import 'feedback_question_option.dart';
import 'feedback_question_settings.dart';

enum FeedbackQuestionType {
  welcomeScreen,
  phoneNumber,
  rating,
  multipleChoice,
  inputText,
  scale,
  yesNo,
  orderItems,
  thankYouScreen,
  unknown,
}

class FeedbackQuestionModel extends Equatable {
  final String id;
  final String brandId;
  final String branchId;
  final String feedbackConfigurationId;
  final String type;
  final String title;
  final String? description;
  final bool isRequired;
  final int displayOrder;
  final FeedbackQuestionSettings settings;
  final List<FeedbackQuestionOption> options;
  final int createdAt;
  final String createdBy;
  final int? updatedAt;
  final String? updatedBy;
  final bool isActive;

  const FeedbackQuestionModel({
    required this.id,
    required this.brandId,
    required this.branchId,
    required this.feedbackConfigurationId,
    required this.type,
    required this.title,
    this.description,
    this.isRequired = false,
    this.displayOrder = 0,
    this.settings = const FeedbackQuestionSettings(),
    this.options = const [],
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.isActive = true,
  });
  //
  // FeedbackQuestionType get typeEnum => FeedbackQuestionTypeX.fromJson(type);

  factory FeedbackQuestionModel.fromJson(Map<String, dynamic> json) {
    return FeedbackQuestionModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      feedbackConfigurationId: json['feedbackConfigurationId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      isRequired: json['isRequired'] as bool? ?? false,
      displayOrder:
      (json['displayOrder'] as num?)?.toInt() ?? 0,
      settings: json['settings'] != null
          ? FeedbackQuestionSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : const FeedbackQuestionSettings(),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => FeedbackQuestionOption.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      createdAt:
      (json['createdAt'] as num?)?.toInt() ?? 0,
      createdBy: json['createdBy'] as String? ?? '',
      updatedAt:(json['updatedAt'] as num?)?.toInt(),
      updatedBy: json['updatedBy'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'brandId': brandId,
    'branchId': branchId,
    'feedbackConfigurationId': feedbackConfigurationId,
    'type': type,
    'title': title,
    if (description != null) 'description': description,
    'isRequired': isRequired,
    'displayOrder': displayOrder,
    'settings': settings.toJson(),
    'options': options.map((o) => o.toJson()).toList(),
    'createdAt': createdAt,
    'createdBy': createdBy,
    'updatedAt': updatedAt,
    'updatedBy': updatedBy,
    'isActive': isActive,
  };

  FeedbackQuestionModel copyWith({
    String? id,
    String? brandId,
    String? branchId,
    String? feedbackConfigurationId,
    String? type,
    String? title,
    String? description,
    bool? isRequired,
    int? displayOrder,
    FeedbackQuestionSettings? settings,
    List<FeedbackQuestionOption>? options,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    bool? isActive,
  }) =>
      FeedbackQuestionModel(
        id: id ?? this.id,
        brandId: brandId ?? this.brandId,
        branchId: branchId ?? this.branchId,
        feedbackConfigurationId: feedbackConfigurationId ?? this.feedbackConfigurationId,
        type: type ?? this.type,
        title: title ?? this.title,
        description: description ?? this.description,
        isRequired: isRequired ?? this.isRequired,
        displayOrder: displayOrder ?? this.displayOrder,
        settings: settings ?? this.settings,
        options: options ?? this.options,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
        isActive: isActive ?? this.isActive,
      );

  bool get isWelcomeScreen => type == 'WELCOME_SCREEN';

  bool get isPhoneNumber => type == 'PHONE_NUMBER';

  bool get isRating => type == 'RATING';

  bool get isMultipleChoice => type == 'MULTIPLE_CHOICE';

  bool get isInputText => type == 'INPUT_TEXT';

  bool get isScale => type == 'SCALE';

  bool get isYesNo => type == 'YES_NO';

  bool get isOrderItems => type == 'ORDER_ITEMS';

  bool get isThankYouScreen => type == 'THANK_YOU_SCREEN';

  FeedbackQuestionType get questionType {
    switch (type) {
      case 'WELCOME_SCREEN':
        return FeedbackQuestionType.welcomeScreen;
      case 'PHONE_NUMBER':
        return FeedbackQuestionType.phoneNumber;
      case 'RATING':
        return FeedbackQuestionType.rating;
      case 'MULTIPLE_CHOICE':
        return FeedbackQuestionType.multipleChoice;
      case 'INPUT_TEXT':
        return FeedbackQuestionType.inputText;
      case 'SCALE':
        return FeedbackQuestionType.scale;
      case 'YES_NO':
        return FeedbackQuestionType.yesNo;
      case 'ORDER_ITEMS':
        return FeedbackQuestionType.orderItems;
      case 'THANK_YOU_SCREEN':
        return FeedbackQuestionType.thankYouScreen;
      default:
        return FeedbackQuestionType.unknown;
    }
  }

  @override
  List<Object?> get props => [
    id,
    brandId,
    branchId,
    feedbackConfigurationId,
    type,
    title,
    description,
    isRequired,
    displayOrder,
    settings,
    options,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    isActive,
  ];
}
