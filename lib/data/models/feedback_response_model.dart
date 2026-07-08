import '../../imports/imports.dart';
import 'feedback_answer.dart';

enum FeedbackSource {
  qrCode,
  sms,
  whatsApp,
  manualLink,
  googleForm,
  unknown,
}

enum FeedbackResponseStatus {
  pending,
  submitted,
  expired,
  unknown,
}

class FeedbackResponseModel extends Equatable {
  final String id;
  final String brandId;
  final String branchId;
  final String feedbackConfigurationId;
  final String? orderId;
  final String? customerId;
  final String? customerPhone;
  final String source;
  final String status;
  final int? submittedAt;
  final List<FeedbackAnswer> answers;
  final int createdAt;
  final bool isActive;

  const FeedbackResponseModel({
    required this.id,
    required this.brandId,
    required this.branchId,
    required this.feedbackConfigurationId,
    this.orderId,
    this.customerId,
    this.customerPhone,
    this.source = 'MANUAL_LINK',
    this.status = 'PENDING',
    this.submittedAt,
    this.answers = const [],
    required this.createdAt,
    this.isActive = true,
  });

  factory FeedbackResponseModel.fromJson(Map<String, dynamic> json) {
    return FeedbackResponseModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      feedbackConfigurationId: json['feedbackConfigurationId'] as String? ?? '',
      orderId: json['orderId'] as String?,
      customerId: json['customerId'] as String?,
      customerPhone: json['customerPhone'] as String?,
      source: json['source'] as String? ?? 'MANUAL_LINK',
      status: json['status'] as String? ?? 'PENDING',
      submittedAt:(json['submittedAt'] as num?)?.toInt(),
      answers: (json['answers'] as List<dynamic>?)
          ?.map((e) => FeedbackAnswer.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      createdAt: json['createdAt'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'brandId': brandId,
    'branchId': branchId,
    'feedbackConfigurationId': feedbackConfigurationId,
    if (orderId != null) 'orderId': orderId,
    if (customerId != null) 'customerId': customerId,
    if (customerPhone != null) 'customerPhone': customerPhone,
    'source': source,
    'status': status,
    'submittedAt': submittedAt,
    'answers': answers.map((a) => a.toJson()).toList(),
    'createdAt': createdAt,
    'isActive': isActive,
  };

  FeedbackResponseModel copyWith({
    String? id,
    String? brandId,
    String? branchId,
    String? feedbackConfigurationId,
    String? orderId,
    String? customerId,
    String? customerPhone,
    String? source,
    String? status,
    int? submittedAt,
    List<FeedbackAnswer>? answers,
    int? createdAt,
    bool? isActive,
  }) =>
      FeedbackResponseModel(
        id: id ?? this.id,
        brandId: brandId ?? this.brandId,
        branchId: branchId ?? this.branchId,
        feedbackConfigurationId: feedbackConfigurationId ?? this.feedbackConfigurationId,
        orderId: orderId ?? this.orderId,
        customerId: customerId ?? this.customerId,
        customerPhone: customerPhone ?? this.customerPhone,
        source: source ?? this.source,
        status: status ?? this.status,
        submittedAt: submittedAt ?? this.submittedAt,
        answers: answers ?? this.answers,
        createdAt: createdAt ?? this.createdAt,
        isActive: isActive ?? this.isActive,
      );

  bool get isQrCode => source == 'QR_CODE';

  bool get isSms => source == 'SMS';

  bool get isWhatsApp => source == 'WHATSAPP';

  bool get isManualLink => source == 'MANUAL_LINK';

  bool get isGoogleForm => source == 'GOOGLE_FORM';

  FeedbackSource get feedbackSource {
    switch (source) {
      case 'QR_CODE':
        return FeedbackSource.qrCode;
      case 'SMS':
        return FeedbackSource.sms;
      case 'WHATSAPP':
        return FeedbackSource.whatsApp;
      case 'MANUAL_LINK':
        return FeedbackSource.manualLink;
      case 'GOOGLE_FORM':
        return FeedbackSource.googleForm;
      default:
        return FeedbackSource.unknown;
    }
  }

  bool get isPending => status == 'PENDING';

  bool get isSubmitted => status == 'SUBMITTED';

  bool get isExpired => status == 'EXPIRED';

  FeedbackResponseStatus get feedbackResponseStatus {
    switch (status) {
      case 'PENDING':
        return FeedbackResponseStatus.pending;
      case 'SUBMITTED':
        return FeedbackResponseStatus.submitted;
      case 'EXPIRED':
        return FeedbackResponseStatus.expired;
      default:
        return FeedbackResponseStatus.unknown;
    }
  }

  // UI helpers for dummy data / display
  String get customerName => customerId ?? 'Guest Customer';
  String get branchName => branchId;

  double get rating {
    for (final a in answers) {
      if (a.questionId == 'rating') {
        if (a.answer is num) {
          return (a.answer as num).toDouble();
        }
      }
    }
    return 0;
  }

  DateTime get submittedDateTime => DateTime.fromMillisecondsSinceEpoch(submittedAt ?? createdAt);

  @override
  List<Object?> get props => [
    id,
    brandId,
    branchId,
    feedbackConfigurationId,
    orderId,
    customerId,
    customerPhone,
    source,
    status,
    submittedAt,
    answers,
    createdAt,
    isActive,
  ];
}
