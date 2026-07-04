import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class UnitModel {
  final String id;
  final String unitName;
  final String shortName;
  final bool decimalAllowed;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UnitModel({
    required this.id,
    required this.unitName,
    required this.shortName,
    this.decimalAllowed = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory UnitModel.fromMap(Map<String, dynamic> map) {
    return UnitModel(
      id: map['_id'] is ObjectId
          ? (map['_id'] as ObjectId).toHexString()
          : map['id']?.toString() ?? map['_id']?.toString() ?? '',
      unitName: map['unit_name']?.toString() ?? '',
      shortName: map['short_name']?.toString() ?? '',
      decimalAllowed: map['decimal_allowed'] as bool? ?? false,
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
      'unit_name': unitName,
      'short_name': shortName,
      'decimal_allowed': decimalAllowed,
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

  UnitModel copyWith({
    String? id,
    String? unitName,
    String? shortName,
    bool? decimalAllowed,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UnitModel(
      id: id ?? this.id,
      unitName: unitName ?? this.unitName,
      shortName: shortName ?? this.shortName,
      decimalAllowed: decimalAllowed ?? this.decimalAllowed,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayLabel => '$unitName ($shortName)';
}
