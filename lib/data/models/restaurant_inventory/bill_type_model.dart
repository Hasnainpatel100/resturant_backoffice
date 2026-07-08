import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class BillTypeModel {
  final String id;
  final String billTypeName;
  final String? remark;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BillTypeModel({
    required this.id,
    required this.billTypeName,
    this.remark,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory BillTypeModel.fromMap(Map<String, dynamic> map) {
    return BillTypeModel(
      id: map['_id'] is ObjectId
          ? (map['_id'] as ObjectId).toHexString()
          : map['id']?.toString() ?? map['_id']?.toString() ?? '',
      billTypeName: map['bill_type_name']?.toString() ?? '',
      remark: map['remark']?.toString(),
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
      'bill_type_name': billTypeName,
      'remark': remark,
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

  BillTypeModel copyWith({
    String? id,
    String? billTypeName,
    String? remark,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillTypeModel(
      id: id ?? this.id,
      billTypeName: billTypeName ?? this.billTypeName,
      remark: remark ?? this.remark,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayLabel => billTypeName;
}
