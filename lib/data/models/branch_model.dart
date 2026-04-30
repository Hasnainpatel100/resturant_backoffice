import 'package:equatable/equatable.dart';
import 'brand_model.dart';

class BranchName extends Equatable {
  final String en;

  const BranchName({this.en = ''});

  factory BranchName.fromJson(Map<String, dynamic> json) {
    return BranchName(en: json['en'] as String? ?? '');
  }

  Map<String, dynamic> toJson() => {'en': en};

  @override
  List<Object?> get props => [en];
}

class BranchPhones extends Equatable {
  final String primary;
  final String alternate;
  final String whatsapp;

  const BranchPhones({
    this.primary = '',
    this.alternate = '',
    this.whatsapp = '',
  });

  factory BranchPhones.fromJson(Map<String, dynamic> json) {
    return BranchPhones(
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

class BranchContact extends Equatable {
  final BranchPhones phones;
  final String email;

  const BranchContact({
    this.phones = const BranchPhones(),
    this.email = '',
  });

  factory BranchContact.fromJson(Map<String, dynamic> json) {
    return BranchContact(
      phones: json['phones'] != null ? BranchPhones.fromJson(json['phones']) : const BranchPhones(),
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'phones': phones.toJson(),
        'email': email,
      };

  @override
  List<Object?> get props => [phones, email];
}

class BranchAddress extends Equatable {
  final String full;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final double latitude;
  final double longitude;
  final String gMapUrl;
  final String gMapPlaceId;

  const BranchAddress({
    this.full = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.zipCode = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.gMapUrl = '',
    this.gMapPlaceId = '',
  });

  factory BranchAddress.fromJson(Map<String, dynamic> json) {
    return BranchAddress(
      full: json['full'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? '',
      zipCode: json['zipCode'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      gMapUrl: json['gMapUrl'] as String? ?? '',
      gMapPlaceId: json['gMapPlaceId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'full': full,
        'city': city,
        'state': state,
        'country': country,
        'zipCode': zipCode,
        'latitude': latitude,
        'longitude': longitude,
        'gMapUrl': gMapUrl,
        'gMapPlaceId': gMapPlaceId,
      };

  @override
  List<Object?> get props => [full, city, state, country, zipCode, latitude, longitude];
}

class BranchRegistration extends Equatable {
  final String gstNo;
  final String gstType;
  final String gstRegistrationDate;
  final String fssaiNo;
  final String fssaiExpiryDate;
  final String cin;

  const BranchRegistration({
    this.gstNo = '',
    this.gstType = '',
    this.gstRegistrationDate = '',
    this.fssaiNo = '',
    this.fssaiExpiryDate = '',
    this.cin = '',
  });

  factory BranchRegistration.fromJson(Map<String, dynamic> json) {
    return BranchRegistration(
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

class BranchSettings extends Equatable {
  final bool isMasterBranch;
  final String open;
  final String close;

  const BranchSettings({
    this.isMasterBranch = false,
    this.open = '',
    this.close = '',
  });

  factory BranchSettings.fromJson(Map<String, dynamic> json) {
    return BranchSettings(
      isMasterBranch: json['isMasterBranch'] as bool? ?? false,
      open: json['open'] as String? ?? '',
      close: json['close'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'isMasterBranch': isMasterBranch,
        'open': open,
        'close': close,
      };

  @override
  List<Object?> get props => [isMasterBranch, open, close];
}

class BranchUpi extends Equatable {
  final String upiId;
  final String qrImage;

  const BranchUpi({
    this.upiId = '',
    this.qrImage = '',
  });

  factory BranchUpi.fromJson(Map<String, dynamic> json) {
    return BranchUpi(
      upiId: json['upiId'] as String? ?? '',
      qrImage: json['qrImage'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'upiId': upiId,
        'qrImage': qrImage,
      };

  @override
  List<Object?> get props => [upiId, qrImage];
}

class BranchBank extends Equatable {
  final String bankName;
  final String branchName;
  final String ifsc;
  final String accountNumber;
  final String beneficiaryName;

  const BranchBank({
    this.bankName = '',
    this.branchName = '',
    this.ifsc = '',
    this.accountNumber = '',
    this.beneficiaryName = '',
  });

  factory BranchBank.fromJson(Map<String, dynamic> json) {
    return BranchBank(
      bankName: json['bankName'] as String? ?? '',
      branchName: json['branchName'] as String? ?? '',
      ifsc: json['ifsc'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      beneficiaryName: json['beneficiaryName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'bankName': bankName,
        'branchName': branchName,
        'ifsc': ifsc,
        'accountNumber': accountNumber,
        'beneficiaryName': beneficiaryName,
      };

  @override
  List<Object?> get props => [bankName, branchName, ifsc, accountNumber, beneficiaryName];
}

class BranchPayment extends Equatable {
  final List<String> supportedPaymentModes;
  final BranchUpi upi;
  final BranchBank bank;
  final String pan;

  const BranchPayment({
    this.supportedPaymentModes = const [],
    this.upi = const BranchUpi(),
    this.bank = const BranchBank(),
    this.pan = '',
  });

  factory BranchPayment.fromJson(Map<String, dynamic> json) {
    return BranchPayment(
      supportedPaymentModes: (json['supportedPaymentModes'] as List<dynamic>?)?.cast<String>() ?? [],
      upi: json['upi'] != null ? BranchUpi.fromJson(json['upi']) : const BranchUpi(),
      bank: json['bank'] != null ? BranchBank.fromJson(json['bank']) : const BranchBank(),
      pan: json['pan'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'supportedPaymentModes': supportedPaymentModes,
        'upi': upi.toJson(),
        'bank': bank.toJson(),
        'pan': pan,
      };

  @override
  List<Object?> get props => [supportedPaymentModes, upi, bank, pan];
}

class BranchPlanDetails extends Equatable {
  final String note;
  final int maxUsers;
  final int maxPosDevices;
  final int expiryAt;
  final String assignedBy;
  final int assignedAt;

  const BranchPlanDetails({
    this.note = '',
    this.maxUsers = 0,
    this.maxPosDevices = 0,
    required this.expiryAt,
    this.assignedBy = '',
    this.assignedAt = 0,
  });

  factory BranchPlanDetails.fromJson(Map<String, dynamic> json) {
    return BranchPlanDetails(
      note: json['note'] as String? ?? '',
      maxUsers: json['maxUsers'] as int? ?? 0,
      maxPosDevices: json['maxPosDevices'] as int? ?? 0,
      expiryAt: json['expiryAt'] as int? ?? 0,
      assignedBy: json['assignedBy'] as String? ?? '',
      assignedAt: json['assignedAt'] as int? ?? 0,
    );
  }

  DateTime? get expiryDate => expiryAt > 0 ? DateTime.fromMillisecondsSinceEpoch(expiryAt) : null;
  bool get isExpired => expiryAt > 0 && DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(expiryAt));

  Map<String, dynamic> toJson() => {
        'note': note,
        'maxUsers': maxUsers,
        'maxPosDevices': maxPosDevices,
        'expiryAt': expiryAt,
        'assignedBy': assignedBy,
        'assignedAt': assignedAt,
      };

  @override
  List<Object?> get props => [note, maxUsers, maxPosDevices, expiryAt, assignedBy, assignedAt];
}

class BranchModel extends Equatable {
  final String id;
  final String brandId;
  final String branchCode;
  final BranchName name;
  final BranchContact contact;
  final BranchAddress address;
  final BranchRegistration registration;
  final BranchSettings settings;
  final List<String> serviceTypes;
  final BranchPayment payment;
  final BranchPlanDetails? planDetails;
  final AccountStatus status;
  final bool isActive;
  final int createdAt;
  final String createdBy;
  final int? updatedAt;
  final String? updatedBy;

  const BranchModel({
    required this.id,
    required this.brandId,
    this.branchCode = '',
    this.name = const BranchName(),
    this.contact = const BranchContact(),
    this.address = const BranchAddress(),
    this.registration = const BranchRegistration(),
    this.settings = const BranchSettings(),
    this.serviceTypes = const [],
    this.payment = const BranchPayment(),
    this.planDetails,
    this.status = AccountStatus.active,
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as String,
      brandId: json['brandId'] as String? ?? '',
      branchCode: json['branchCode'] as String? ?? '',
      name: json['name'] != null ? BranchName.fromJson(json['name']) : const BranchName(),
      contact: json['contact'] != null ? BranchContact.fromJson(json['contact']) : const BranchContact(),
      address: json['address'] != null ? BranchAddress.fromJson(json['address']) : const BranchAddress(),
      registration: json['registration'] != null ? BranchRegistration.fromJson(json['registration']) : const BranchRegistration(),
      settings: json['settings'] != null ? BranchSettings.fromJson(json['settings']) : const BranchSettings(),
      serviceTypes: (json['serviceTypes'] as List<dynamic>?)?.cast<String>() ?? [],
      payment: json['payment'] != null ? BranchPayment.fromJson(json['payment']) : const BranchPayment(),
      planDetails: json['planDetails'] != null ? BranchPlanDetails.fromJson(json['planDetails']) : null,
      status: AccountStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'active'),
        orElse: () => AccountStatus.active,
      ),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as int? ?? 0,
      createdBy: json['createdBy'] as String? ?? '',
      updatedAt: json['updatedAt'] as int?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'branchCode': branchCode,
        'name': name.toJson(),
        'contact': contact.toJson(),
        'address': address.toJson(),
        'registration': registration.toJson(),
        'settings': settings.toJson(),
        'serviceTypes': serviceTypes,
        'payment': payment.toJson(),
        'planDetails': planDetails?.toJson(),
        'status': status.name,
        'isActive': isActive,
        'createdAt': createdAt,
        'createdBy': createdBy,
        'updatedAt': updatedAt,
        'updatedBy': updatedBy,
      };

  String get displayName => name.en.isNotEmpty ? name.en : 'Branch $branchCode';
  String get city => address.city;

  @override
  List<Object?> get props => [id, brandId, branchCode, name, contact, address, settings, serviceTypes, payment, status, isActive];
}

class BranchBasicModel extends Equatable {
  final String id;
  final BranchName name;
  final String city;
  final bool isActive;

  const BranchBasicModel({
    required this.id,
    this.name = const BranchName(),
    this.city = '',
    this.isActive = true,
  });

  factory BranchBasicModel.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return BranchBasicModel(
      id: json['id'] as String,
      name: json['name'] != null ? BranchName.fromJson(json['name']) : const BranchName(),
      city: address?['city'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  String get displayName => name.en.isNotEmpty ? name.en : 'Branch $id';

  @override
  List<Object?> get props => [id, name, city, isActive];
}
