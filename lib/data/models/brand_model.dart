import 'package:equatable/equatable.dart';

enum AccountStatus { active, inactive, suspended, pending }

class NameData extends Equatable {
  final String en;

  const NameData({this.en = ''});

  factory NameData.fromJson(Map<String, dynamic> json) {
    return NameData(en: json['en'] as String? ?? '');
  }

  Map<String, dynamic> toJson() => {'en': en};

  @override
  List<Object?> get props => [en];
}

class RegistrationData extends Equatable {
  final String gstNo;
  final String gstType;
  final String gstRegistrationDate;
  final String fssaiNo;
  final String fssaiExpiryDate;
  final String cin;

  const RegistrationData({
    this.gstNo = '',
    this.gstType = '',
    this.gstRegistrationDate = '',
    this.fssaiNo = '',
    this.fssaiExpiryDate = '',
    this.cin = '',
  });

  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      gstNo: json['gstNo'] as String? ?? '',
      gstType: json['gstType'] as String? ?? '',
      gstRegistrationDate: json['gstRegistrationDate'] as String? ?? '',
      fssaiNo: json['fssaiNo'] as String? ?? '',
      fssaiExpiryDate: json['fssaiExpiryDate'] as String? ?? '',
      cin: json['cin'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'gstNo': gstNo,
        'gstType': gstType,
        'gstRegistrationDate': gstRegistrationDate,
        'fssaiNo': fssaiNo,
        'fssaiExpiryDate': fssaiExpiryDate,
        'cin': cin,
      };

  @override
  List<Object?> get props => [gstNo, gstType, gstRegistrationDate, fssaiNo, fssaiExpiryDate, cin];
}

class PhonesData extends Equatable {
  final String primary;
  final String alternate;
  final String whatsapp;

  const PhonesData({
    this.primary = '',
    this.alternate = '',
    this.whatsapp = '',
  });

  factory PhonesData.fromJson(Map<String, dynamic> json) {
    return PhonesData(
      primary: json['primary'] as String? ?? '',
      alternate: json['alternate'] as String? ?? '',
      whatsapp: json['whatsapp'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'primary': primary,
        'alternate': alternate,
        'whatsapp': whatsapp,
      };

  @override
  List<Object?> get props => [primary, alternate, whatsapp];
}

class ContactData extends Equatable {
  final PhonesData phones;
  final String email;
  final String website;

  const ContactData({
    this.phones = const PhonesData(),
    this.email = '',
    this.website = '',
  });

  factory ContactData.fromJson(Map<String, dynamic> json) {
    return ContactData(
      phones: json['phones'] != null ? PhonesData.fromJson(json['phones']) : const PhonesData(),
      email: json['email'] as String? ?? '',
      website: json['website'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'phones': phones.toJson(),
        'email': email,
        'website': website,
      };

  @override
  List<Object?> get props => [phones, email, website];
}

class BillingData extends Equatable {
  final int billResetDays;
  final int kotResetDays;

  const BillingData({
    this.billResetDays = 0,
    this.kotResetDays = 0,
  });

  factory BillingData.fromJson(Map<String, dynamic> json) {
    return BillingData(
      billResetDays: json['billResetDays'] as int? ?? 0,
      kotResetDays: json['kotResetDays'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'billResetDays': billResetDays,
        'kotResetDays': kotResetDays,
      };

  @override
  List<Object?> get props => [billResetDays, kotResetDays];
}

class InvoiceData extends Equatable {
  final bool showGstBreakup;
  final bool showFssaiNo;
  final String footerText;

  const InvoiceData({
    this.showGstBreakup = false,
    this.showFssaiNo = false,
    this.footerText = '',
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      showGstBreakup: json['showGstBreakup'] as bool? ?? false,
      showFssaiNo: json['showFssaiNo'] as bool? ?? false,
      footerText: json['footerText'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'showGstBreakup': showGstBreakup,
        'showFssaiNo': showFssaiNo,
        'footerText': footerText,
      };

  @override
  List<Object?> get props => [showGstBreakup, showFssaiNo, footerText];
}

class SettingsData extends Equatable {
  final String currency;
  final String timezone;
  final String theme;
  final BillingData billing;
  final InvoiceData invoice;

  const SettingsData({
    this.currency = '',
    this.timezone = '',
    this.theme = '',
    this.billing = const BillingData(),
    this.invoice = const InvoiceData(),
  });

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      currency: json['currency'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
      theme: json['theme'] as String? ?? '',
      billing: json['billing'] != null ? BillingData.fromJson(json['billing']) : const BillingData(),
      invoice: json['invoice'] != null ? InvoiceData.fromJson(json['invoice']) : const InvoiceData(),
    );
  }

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'timezone': timezone,
        'theme': theme,
        'billing': billing.toJson(),
        'invoice': invoice.toJson(),
      };

  @override
  List<Object?> get props => [currency, timezone, theme, billing, invoice];
}

class BrandModel extends Equatable {
  final String id;
  final String? ownerId;
  final String branchCode;
  final NameData name;
  final RegistrationData registration;
  final ContactData contact;
  final SettingsData settings;
  final AccountStatus status;
  final String statusReason;
  final int createdAt;
  final String createdBy;
  final int? updatedAt;
  final String? updatedBy;

  const BrandModel({
    required this.id,
    this.ownerId,
    this.branchCode = '',
    this.name = const NameData(),
    this.registration = const RegistrationData(),
    this.contact = const ContactData(),
    this.settings = const SettingsData(),
    this.status = AccountStatus.active,
    this.statusReason = '',
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String?,
      branchCode: json['branchCode'] as String? ?? '',
      name: json['name'] != null ? NameData.fromJson(json['name']) : const NameData(),
      registration: json['registration'] != null ? RegistrationData.fromJson(json['registration']) : const RegistrationData(),
      contact: json['contact'] != null ? ContactData.fromJson(json['contact']) : const ContactData(),
      settings: json['settings'] != null ? SettingsData.fromJson(json['settings']) : const SettingsData(),
      status: AccountStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'active'),
        orElse: () => AccountStatus.active,
      ),
      statusReason: json['statusReason'] as String? ?? '',
      createdAt: json['createdAt'] as int? ?? 0,
      createdBy: json['createdBy'] as String? ?? '',
      updatedAt: json['updatedAt'] as int?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'branchCode': branchCode,
        'name': name.toJson(),
        'registration': registration.toJson(),
        'contact': contact.toJson(),
        'settings': settings.toJson(),
        'status': status.name,
        'statusReason': statusReason,
        'createdAt': createdAt,
        'createdBy': createdBy,
        'updatedAt': updatedAt,
        'updatedBy': updatedBy,
      };

  String get displayName => name.en.isNotEmpty ? name.en : 'Brand $id';

  @override
  List<Object?> get props => [id, ownerId, branchCode, name, registration, contact, settings, status];
}

class BrandBasicModel extends Equatable {
  final String id;
  final NameData name;
  final AccountStatus status;

  const BrandBasicModel({
    required this.id,
    this.name = const NameData(),
    this.status = AccountStatus.active,
  });

  factory BrandBasicModel.fromJson(Map<String, dynamic> json) {
    return BrandBasicModel(
      id: json['id'] as String,
      name: json['name'] != null ? NameData.fromJson(json['name']) : const NameData(),
      status: AccountStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'active'),
        orElse: () => AccountStatus.active,
      ),
    );
  }

  String get displayName => name.en.isNotEmpty ? name.en : 'Brand $id';

  @override
  List<Object?> get props => [id, name, status];
}
