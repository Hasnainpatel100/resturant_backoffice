import 'package:equatable/equatable.dart';

class SupplierModel extends Equatable {
  final String id;
  final String brandId;
  final String name;
  final String? contactPerson;
  final String? email;
  final String? phone;
  final String? address;
  final double openingBalance;
  final double currentBalance; // Balance payable to supplier
  final bool isActive;
  final int createdAt;
  final int? updatedAt;

  const SupplierModel({
    required this.id,
    required this.brandId,
    required this.name,
    this.contactPerson,
    this.email,
    this.phone,
    this.address,
    this.openingBalance = 0.0,
    this.currentBalance = 0.0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      contactPerson: json['contactPerson'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'name': name,
        'contactPerson': contactPerson,
        'email': email,
        'phone': phone,
        'address': address,
        'openingBalance': openingBalance,
        'currentBalance': currentBalance,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  SupplierModel copyWith({
    String? id,
    String? brandId,
    String? name,
    String? contactPerson,
    String? email,
    String? phone,
    String? address,
    double? openingBalance,
    double? currentBalance,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, brandId, name, phone, currentBalance, isActive];
}
