import 'package:equatable/equatable.dart';

/// Represents a physical storage location (warehouse/store room).
class WarehouseModel extends Equatable {
  final String id;
  final String brandId;
  final String name;
  final String? address;
  final bool isActive;
  final int createdAt;
  final int? updatedAt;

  const WarehouseModel({
    required this.id,
    required this.brandId,
    required this.name,
    this.address,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'name': name,
        'address': address,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  WarehouseModel copyWith({
    String? id,
    String? brandId,
    String? name,
    String? address,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return WarehouseModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, brandId, name, isActive];
}
