import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class RawMaterialTaxModel {
  final String id;
  final String taxName;
  final double taxValue;
  final String taxType; // e.g. 'percentage', 'fixed'
  final String? rawMaterialGroupId;
  final bool isDividable;
  final bool includeInRate;
  final String appliesOn; // e.g. 'purchase', 'sales', 'both'
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RawMaterialTaxModel({
    required this.id,
    required this.taxName,
    required this.taxValue,
    required this.taxType,
    this.rawMaterialGroupId,
    this.isDividable = false,
    this.includeInRate = false,
    required this.appliesOn,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory RawMaterialTaxModel.fromMap(Map<String, dynamic> map) {
    return RawMaterialTaxModel(
      id: map['_id'] is ObjectId
          ? (map['_id'] as ObjectId).toHexString()
          : map['id']?.toString() ?? map['_id']?.toString() ?? '',
      taxName: map['tax_name']?.toString() ?? '',
      taxValue: (map['tax_value'] as num?)?.toDouble() ?? 0.0,
      taxType: map['tax_type']?.toString() ?? 'percentage',
      rawMaterialGroupId: map['raw_material_group_id'] is ObjectId
          ? (map['raw_material_group_id'] as ObjectId).toHexString()
          : map['raw_material_group_id']?.toString(),
      isDividable: map['is_dividable'] as bool? ?? false,
      includeInRate: map['include_in_rate'] as bool? ?? false,
      appliesOn: map['applies_on']?.toString() ?? 'purchase',
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
      'tax_name': taxName,
      'tax_value': taxValue,
      'tax_type': taxType,
      'is_dividable': isDividable,
      'include_in_rate': includeInRate,
      'applies_on': appliesOn,
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
    if (rawMaterialGroupId != null && rawMaterialGroupId!.isNotEmpty) {
      try {
        map['raw_material_group_id'] = ObjectId.fromHexString(rawMaterialGroupId!);
      } catch (_) {
        map['raw_material_group_id'] = rawMaterialGroupId;
      }
    } else {
      map['raw_material_group_id'] = null;
    }
    return map;
  }

  RawMaterialTaxModel copyWith({
    String? id,
    String? taxName,
    double? taxValue,
    String? taxType,
    String? rawMaterialGroupId,
    bool? isDividable,
    bool? includeInRate,
    String? appliesOn,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RawMaterialTaxModel(
      id: id ?? this.id,
      taxName: taxName ?? this.taxName,
      taxValue: taxValue ?? this.taxValue,
      taxType: taxType ?? this.taxType,
      rawMaterialGroupId: rawMaterialGroupId ?? this.rawMaterialGroupId,
      isDividable: isDividable ?? this.isDividable,
      includeInRate: includeInRate ?? this.includeInRate,
      appliesOn: appliesOn ?? this.appliesOn,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayLabel => '$taxName (${taxType == 'percentage' ? '$taxValue%' : '\$$taxValue'})';
}
