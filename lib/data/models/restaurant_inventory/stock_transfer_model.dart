import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class StockTransferItemModel {
  final String id;
  final String? transferId;
  final String rawMaterialId;
  final String unitId;
  final double qtyTransfer;
  final String? remark;

  StockTransferItemModel({
    required this.id,
    this.transferId,
    required this.rawMaterialId,
    required this.unitId,
    required this.qtyTransfer,
    this.remark,
  });

  factory StockTransferItemModel.fromMap(Map<String, dynamic> map) {
    return StockTransferItemModel(
      id: map['id']?.toString() ?? map['_id']?.toString() ?? '',
      transferId: map['transfer_id']?.toString(),
      rawMaterialId: map['raw_material_id'] is ObjectId
          ? (map['raw_material_id'] as ObjectId).toHexString()
          : map['raw_material_id']?.toString() ?? '',
      unitId: map['unit_id'] is ObjectId
          ? (map['unit_id'] as ObjectId).toHexString()
          : map['unit_id']?.toString() ?? '',
      qtyTransfer: (map['qty_transfer'] as num?)?.toDouble() ?? 0.0,
      remark: map['remark']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'transfer_id': transferId,
      'qty_transfer': qtyTransfer,
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

class StockTransferModel {
  final String id;
  final String transferNo;
  final DateTime transferDate;
  final String fromWarehouseId; // source location
  final String toWarehouseId;   // destination location
  final String? indentId;       // optional indent reference
  final String status; // 'draft', 'posted', 'cancelled'
  final String? remark;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<StockTransferItemModel> items;

  StockTransferModel({
    required this.id,
    required this.transferNo,
    required this.transferDate,
    required this.fromWarehouseId,
    required this.toWarehouseId,
    this.indentId,
    required this.status,
    this.remark,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    required this.items,
  });

  factory StockTransferModel.fromMap(Map<String, dynamic> map) {
    return StockTransferModel(
      id: map['_id'] is ObjectId
          ? (map['_id'] as ObjectId).toHexString()
          : map['id']?.toString() ?? map['_id']?.toString() ?? '',
      transferNo: map['transfer_no']?.toString() ?? '',
      transferDate: map['transfer_date'] is DateTime
          ? map['transfer_date'] as DateTime
          : DateTime.tryParse(map['transfer_date']?.toString() ?? '') ?? DateTime.now(),
      fromWarehouseId: map['from_warehouse_id'] is ObjectId
          ? (map['from_warehouse_id'] as ObjectId).toHexString()
          : map['from_warehouse_id']?.toString() ?? '',
      toWarehouseId: map['to_warehouse_id'] is ObjectId
          ? (map['to_warehouse_id'] as ObjectId).toHexString()
          : map['to_warehouse_id']?.toString() ?? '',
      indentId: map['indent_id'] is ObjectId
          ? (map['indent_id'] as ObjectId).toHexString()
          : map['indent_id']?.toString(),
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
              ?.map((itemMap) => StockTransferItemModel.fromMap(itemMap as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'transfer_no': transferNo,
      'transfer_date': transferDate,
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
    if (indentId != null && indentId!.isNotEmpty) {
      try {
        map['indent_id'] = ObjectId.fromHexString(indentId!);
      } catch (_) {
        map['indent_id'] = indentId;
      }
    } else {
      map['indent_id'] = null;
    }
    return map;
  }
}
