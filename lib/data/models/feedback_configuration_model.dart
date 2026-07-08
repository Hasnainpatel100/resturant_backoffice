import '../../imports/imports.dart';

enum FeedbackStatus {
  draft,
  active,
  inactive,
  archived,
  unknown,
}
enum FeedbackSendMethod {
  disabled,
  sms,
  whatsApp,
  qrCode,
  all,
  unknown,
}

class FeedbackConfigurationModel extends Equatable {
  final String id;
  final String brandId;
  final String branchId;
  final String title;
  final String? googleFormId;
  final String? googleFormUrl;
  final String? qrCode;
  final String status;
  final bool isDefault;
  final bool loyaltyEnabled;
  final String sendMethod;
  final int delayMinutes;
  final double minimumOrderAmount;
  final int createdAt;
  final String createdBy;
  final int? updatedAt;
  final String? updatedBy;
  final bool isActive;

  const FeedbackConfigurationModel({
    required this.id,
    required this.brandId,
    required this.branchId,
    required this.title,
    this.googleFormId,
    this.googleFormUrl,
    this.qrCode,
    this.status = 'ACTIVE',
    this.isDefault = false,
    this.loyaltyEnabled = false,
    this.sendMethod = 'DISABLED',
    this.delayMinutes = 0,
    this.minimumOrderAmount = 0.0,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.isActive = true,
  });

  factory FeedbackConfigurationModel.fromJson(Map<String, dynamic> json) {
    return FeedbackConfigurationModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      googleFormId: json['googleFormId'] as String?,
      googleFormUrl: json['googleFormUrl'] as String?,
      qrCode: json['qrCode'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      isDefault: json['isDefault'] as bool? ?? false,
      loyaltyEnabled: json['loyaltyEnabled'] as bool? ?? false,
      sendMethod:
      json['sendMethod'] as String? ?? 'DISABLED',
      delayMinutes:
      (json['delayMinutes'] as num?)?.toInt() ?? 0,
      minimumOrderAmount: (json['minimumOrderAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt:
      (json['createdAt'] as num?)?.toInt() ?? 0,
      createdBy: json['createdBy'] as String? ?? '',
      updatedAt:
      (json['updatedAt'] as num?)?.toInt(),
      updatedBy: json['updatedBy'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'brandId': brandId,
    'branchId': branchId,
    'title': title,
    if (googleFormId != null) 'googleFormId': googleFormId,
    if (googleFormUrl != null) 'googleFormUrl': googleFormUrl,
    if (qrCode != null) 'qrCode': qrCode,
    'status': status,
    'isDefault': isDefault,
    'loyaltyEnabled': loyaltyEnabled,
    'sendMethod': sendMethod,
    'delayMinutes': delayMinutes,
    'minimumOrderAmount': minimumOrderAmount,
    'createdAt': createdAt,
    'createdBy': createdBy,
    'updatedAt': updatedAt,
    'updatedBy': updatedBy,
    'isActive': isActive,
  };

  FeedbackConfigurationModel copyWith({
    String? id,
    String? brandId,
    String? branchId,
    String? title,
    String? googleFormId,
    String? googleFormUrl,
    String? qrCode,
    String? status,
    bool? isDefault,
    bool? loyaltyEnabled,
    String? sendMethod,
    int? delayMinutes,
    double? minimumOrderAmount,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    bool? isActive,
  }) =>
      FeedbackConfigurationModel(
        id: id ?? this.id,
        brandId: brandId ?? this.brandId,
        branchId: branchId ?? this.branchId,
        title: title ?? this.title,
        googleFormId: googleFormId ?? this.googleFormId,
        googleFormUrl: googleFormUrl ?? this.googleFormUrl,
        qrCode: qrCode ?? this.qrCode,
        status: status ?? this.status,
        isDefault: isDefault ?? this.isDefault,
        loyaltyEnabled: loyaltyEnabled ?? this.loyaltyEnabled,
        sendMethod: sendMethod ?? this.sendMethod,
        delayMinutes: delayMinutes ?? this.delayMinutes,
        minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
        isActive: isActive ?? this.isActive,
      );
  bool get isDraft => status == 'DRAFT';

  bool get isActiveStatus => status == 'ACTIVE';

  bool get isInactive => status == 'INACTIVE';

  bool get isArchived => status == 'ARCHIVED';

  FeedbackStatus get feedbackStatus {
    switch (status) {
      case 'ACTIVE':
        return FeedbackStatus.active;
      case 'INACTIVE':
        return FeedbackStatus.inactive;
      case 'ARCHIVED':
        return FeedbackStatus.archived;
      default:
        return FeedbackStatus.unknown;
    }
  }

  bool get isSms => sendMethod == 'SMS';

  bool get isWhatsApp => sendMethod == 'WHATSAPP';

  bool get isQrCode => sendMethod == 'QR_CODE';

  bool get isAll => sendMethod == 'ALL';

  bool get isDisabled => sendMethod == 'DISABLED';

  FeedbackSendMethod get feedbackSendMethod {
    switch (sendMethod) {
      case 'SMS':
        return FeedbackSendMethod.sms;
      case 'WHATSAPP':
        return FeedbackSendMethod.whatsApp;
      case 'QR_CODE':
        return FeedbackSendMethod.qrCode;
      case 'ALL':
        return FeedbackSendMethod.all;
      case 'DISABLED':
        return FeedbackSendMethod.disabled;
      default:
        return FeedbackSendMethod.unknown;
    }
  }

  @override
  List<Object?> get props => [
    id,
    brandId,
    branchId,
    title,
    googleFormId,
    googleFormUrl,
    qrCode,
    status,
    isDefault,
    loyaltyEnabled,
    sendMethod,
    delayMinutes,
    minimumOrderAmount,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    isActive,
  ];
}
