import 'package:equatable/equatable.dart';

/// Represents a unit of measurement (e.g., kg, litre, piece).
class UnitModel extends Equatable {
  final String id;
  final String brandId;
  final String name;
  final String code;
  final bool isActive;
  final int createdAt;
  final int? updatedAt;

  const UnitModel({
    required this.id,
    required this.brandId,
    required this.name,
    required this.code,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'name': name,
        'code': code,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  UnitModel copyWith({
    String? id,
    String? brandId,
    String? name,
    String? code,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return UnitModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      code: code ?? this.code,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Display label shown in dropdowns and lists (e.g. "Kilogram (kg)")
  String get displayLabel => '$name ($code)';

  @override
  List<Object?> get props => [id, brandId, name, code, isActive];
}
