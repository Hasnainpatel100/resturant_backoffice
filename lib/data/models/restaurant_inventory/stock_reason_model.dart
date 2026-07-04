import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class StockReasonModel {
  final String id;
  final String reasonName;
  final String reasonType; // e.g., 'wastage', 'theft', 'manual_adjustment', 'transfer'
  final bool isActive;

  StockReasonModel({
    required this.id,
    required this.reasonName,
    required this.reasonType,
    this.isActive = true,
  });

  factory StockReasonModel.fromMap(Map<String, dynamic> map) {
    return StockReasonModel(
      id: map['_id'] is ObjectId
          ? (map['_id'] as ObjectId).toHexString()
          : map['id']?.toString() ?? map['_id']?.toString() ?? '',
      reasonName: map['reason_name']?.toString() ?? '',
      reasonType: map['reason_type']?.toString() ?? 'manual_adjustment',
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'reason_name': reasonName,
      'reason_type': reasonType,
      'is_active': isActive,
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

  StockReasonModel copyWith({
    String? id,
    String? reasonName,
    String? reasonType,
    bool? isActive,
  }) {
    return StockReasonModel(
      id: id ?? this.id,
      reasonName: reasonName ?? this.reasonName,
      reasonType: reasonType ?? this.reasonType,
      isActive: isActive ?? this.isActive,
    );
  }

  String get displayLabel => '$reasonName ($reasonType)';
}
