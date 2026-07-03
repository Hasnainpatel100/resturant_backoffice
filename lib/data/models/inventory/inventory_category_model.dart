import 'package:equatable/equatable.dart';

/// Represents a product/item category in the inventory.
class InventoryCategoryModel extends Equatable {
  final String id;
  final String brandId;
  final String name;
  final String? description;
  final bool isActive;
  final int createdAt;
  final int? updatedAt;

  const InventoryCategoryModel({
    required this.id,
    required this.brandId,
    required this.name,
    this.description,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory InventoryCategoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryCategoryModel(
      id: json['id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'name': name,
        'description': description,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  InventoryCategoryModel copyWith({
    String? id,
    String? brandId,
    String? name,
    String? description,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return InventoryCategoryModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, brandId, name, isActive];
}
