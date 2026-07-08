import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class IndentItemModel {
  final String id;
  final String? indentId;
  final String rawMaterialId;
  final String unitId;
  final double qtyRequest;
  final double qtyApproved;
  final String? remark;

  IndentItemModel({
    required this.id,
    this.indentId,
    required this.rawMaterialId,
    required this.unitId,
    required this.qtyRequest,
    this.qtyApproved = 0.0,
    this.remark,
  });

  factory IndentItemModel.fromMap(Map<String, dynamic> map) {
    return IndentItemModel(
      id: map['id']?.toString() ?? map['_id']?.toString() ?? '',
      indentId: map['indent_id']?.toString(),
      rawMaterialId: map['raw_material_id'] is ObjectId
          ? (map['raw_material_id'] as ObjectId).toHexString()
          : map['raw_material_id']?.toString() ?? '',
      unitId: map['unit_id'] is ObjectId
          ? (map['unit_id'] as ObjectId).toHexString()
          : map['unit_id']?.toString() ?? '',
      qtyRequest: (map['qty_request'] as num?)?.toDouble() ?? 0.0,
      qtyApproved: (map['qty_approved'] as num?)?.toDouble() ?? 0.0,
      remark: map['remark']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'indent_id': indentId,
      'qty_request': qtyRequest,
      'qty_approved': qtyApproved,
      'remark': remark,
    };
    try {
      map['raw_material_id'] = ObjectId.fromHexString(rawMaterialId);
    } catch (_) {
      map['raw_material_id'] = rawMaterialId;
    }
    try {
      map['unit_id'] = ObjectId.fromHexString(unitId);
    } catch (_) {
      map['unit_id'] = unitId;
    }
    return map;
  }
}

class IndentModel {
  final String id;
  final String indentNo;
  final DateTime indentDate;
  final String fromWarehouseId; // requesting kitchen/location
  final String toWarehouseId;   // supplying warehouse/location
  final String status; // 'draft', 'submitted', 'approved', 'cancelled'
  final String? remark;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<IndentItemModel> items;

  IndentModel({
    required this.id,
    required this.indentNo,
    required this.indentDate,
    required this.fromWarehouseId,
    required this.toWarehouseId,
    required this.status,
    this.remark,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    required this.items,
  });

  factory IndentModel.fromMap(Map<String, dynamic> map) {
    return IndentModel(
      id: map['_id'] is ObjectId
          ? (map['_id'] as ObjectId).toHexString()
          : map['id']?.toString() ?? map['_id']?.toString() ?? '',
      indentNo: map['indent_no']?.toString() ?? '',
      indentDate: map['indent_date'] is DateTime
          ? map['indent_date'] as DateTime
          : DateTime.tryParse(map['indent_date']?.toString() ?? '') ?? DateTime.now(),
      fromWarehouseId: map['from_warehouse_id'] is ObjectId
          ? (map['from_warehouse_id'] as ObjectId).toHexString()
          : map['from_warehouse_id']?.toString() ?? '',
      toWarehouseId: map['to_warehouse_id'] is ObjectId
          ? (map['to_warehouse_id'] as ObjectId).toHexString()
          : map['to_warehouse_id']?.toString() ?? '',
      status: map['status']?.toString() ?? 'draft',
      remark: map['remark']?.toString(),
      createdBy: map['created_by']?.toString(),
      createdAt: map['created_at'] is DateTime
          ? map['created_at'] as DateTime
          : DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: map['updated_at'] is DateTime
          ? map['updated_at'] as DateTime
          : DateTime.tryParse(map['updated_at']?.toString() ?? ''),
      items: (map['items'] as List<dynamic>?)
              ?.map((itemMap) => IndentItemModel.fromMap(itemMap as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'indent_no': indentNo,
      'indent_date': indentDate,
      'status': status,
      'remark': remark,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'items': items.map((i) => i.toMap()).toList(),
    };
    if (id.isNotEmpty) {
      try {
        map['_id'] = ObjectId.fromHexString(id);
      } catch (_) {
        map['id'] = id;
      }
    }
    try {
      map['from_warehouse_id'] = ObjectId.fromHexString(fromWarehouseId);
    } catch (_) {
      map['from_warehouse_id'] = fromWarehouseId;
    }
    try {
      map['to_warehouse_id'] = ObjectId.fromHexString(toWarehouseId);
    } catch (_) {
      map['to_warehouse_id'] = toWarehouseId;
    }
    return map;
  }
}
