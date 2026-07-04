import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class RawMaterialGroupModel {
  final String id;
  final String groupName;
  final String groupCode;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RawMaterialGroupModel({
    required this.id,
    required this.groupName,
    required this.groupCode,
    this.description,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory RawMaterialGroupModel.fromMap(Map<String, dynamic> map) {
    return RawMaterialGroupModel(
      id: map['_id'] is ObjectId
          ? (map['_id'] as ObjectId).toHexString()
          : map['id']?.toString() ?? map['_id']?.toString() ?? '',
      groupName: map['group_name']?.toString() ?? '',
      groupCode: map['group_code']?.toString() ?? '',
      description: map['description']?.toString(),
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
      'group_name': groupName,
      'group_code': groupCode,
      'description': description,
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

  RawMaterialGroupModel copyWith({
    String? id,
    String? groupName,
    String? groupCode,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RawMaterialGroupModel(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      groupCode: groupCode ?? this.groupCode,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayLabel => '$groupName ($groupCode)';
}
