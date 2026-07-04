import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class VendorModel {
  final String id;
  final String vendorCode;
  final String vendorName;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxNumber;
  final int creditDays;
  final double openingBalance;
  final String balanceType; // e.g. 'debit', 'credit'
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VendorModel({
    required this.id,
    required this.vendorCode,
    required this.vendorName,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.taxNumber,
    this.creditDays = 0,
    this.openingBalance = 0.0,
    this.balanceType = 'credit',
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory VendorModel.fromMap(Map<String, dynamic> map) {
    return VendorModel(
      id: map['_id'] is ObjectId
          ? (map['_id'] as ObjectId).toHexString()
          : map['id']?.toString() ?? map['_id']?.toString() ?? '',
      vendorCode: map['vendor_code']?.toString() ?? '',
      vendorName: map['vendor_name']?.toString() ?? '',
      contactPerson: map['contact_person']?.toString(),
      phone: map['phone']?.toString(),
      email: map['email']?.toString(),
      address: map['address']?.toString(),
      taxNumber: map['tax_number']?.toString(),
      creditDays: map['credit_days'] as int? ?? 0,
      openingBalance: (map['opening_balance'] as num?)?.toDouble() ?? 0.0,
      balanceType: map['balance_type']?.toString() ?? 'credit',
      isActive: map['is_active'] as bool? ?? true,
      createdAt: map['created_at'] is DateTime
          ? map['created_at'] as DateTime
          : DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: map['updated_at'] is DateTime
          ? map['updated_at'] as DateTime
          : DateTime.tryParse(map['updated_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'vendor_code': vendorCode,
      'vendor_name': vendorName,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'tax_number': taxNumber,
      'credit_days': creditDays,
      'opening_balance': openingBalance,
      'balance_type': balanceType,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
    if (id.isNotEmpty) {
      try {
        map['_id'] = ObjectId.fromHexString(id);
      } catch (_) {
        map['id'] = id;
      }
    }
    return map;
  }

  VendorModel copyWith({
    String? id,
    String? vendorCode,
    String? vendorName,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? taxNumber,
    int? creditDays,
    double? openingBalance,
    String? balanceType,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VendorModel(
      id: id ?? this.id,
      vendorCode: vendorCode ?? this.vendorCode,
      vendorName: vendorName ?? this.vendorName,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      creditDays: creditDays ?? this.creditDays,
      openingBalance: openingBalance ?? this.openingBalance,
      balanceType: balanceType ?? this.balanceType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayLabel => '$vendorName ($vendorCode)';
}
