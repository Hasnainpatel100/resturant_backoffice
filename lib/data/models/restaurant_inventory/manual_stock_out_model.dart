import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class ManualStockOutItemModel {
  final String id;
  final String? manualStockOutId;
  final String rawMaterialId;
  final String unitId;
  final double qty;
  final double rate;
  final double lineAmount;
  final String? remark;

  ManualStockOutItemModel({
    required this.id,
    this.manualStockOutId,
    required this.rawMaterialId,
    required this.unitId,
    required this.qty,
    required this.rate,
    required this.lineAmount,
    this.remark,
  });

  factory ManualStockOutItemModel.fromMap(Map<String, dynamic> map) {
    return ManualStockOutItemModel(
      id: map['id']?.toString() ?? map['_id']?.toString() ?? '',
      manualStockOutId: map['manual_stock_out_id']?.toString(),
      rawMaterialId: map['raw_material_id'] is ObjectId
          ? (map['raw_material_id'] as ObjectId).toHexString()
          : map['raw_material_id']?.toString() ?? '',
      unitId: map['unit_id'] is ObjectId
          ? (map['unit_id'] as ObjectId).toHexString()
          : map['unit_id']?.toString() ?? '',
      qty: (map['qty'] as num?)?.toDouble() ?? 0.0,
      rate: (map['rate'] as num?)?.toDouble() ?? 0.0,
      lineAmount: (map['line_amount'] as num?)?.toDouble() ?? 0.0,
      remark: map['remark']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'manual_stock_out_id': manualStockOutId,
      'qty': qty,
      'rate': rate,
      'line_amount': lineAmount,
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

class ManualStockOutModel {
  final String id;
  final String stockOutNo;
  final DateTime stockOutDate;
  final String warehouseId;
  final String reasonId;
  final String status; // 'draft', 'posted'
  final String? remark;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<ManualStockOutItemModel> items;

  ManualStockOutModel({
    required this.id,
    required this.stockOutNo,
    required this.stockOutDate,
    required this.warehouseId,
    required this.reasonId,
    this.status = 'draft',
    this.remark,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory ManualStockOutModel.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final itemList = rawItems.map((item) => ManualStockOutItemModel.fromMap(item as Map<String, dynamic>)).toList();

    return ManualStockOutModel(
      id: map['_id'] is ObjectId
          ? (map['_id'] as ObjectId).toHexString()
          : map['id']?.toString() ?? map['_id']?.toString() ?? '',
      stockOutNo: map['stock_out_no']?.toString() ?? '',
      stockOutDate: map['stock_out_date'] is DateTime
          ? map['stock_out_date'] as DateTime
          : DateTime.tryParse(map['stock_out_date']?.toString() ?? '') ?? DateTime.now(),
      warehouseId: map['warehouse_id'] is ObjectId
          ? (map['warehouse_id'] as ObjectId).toHexString()
          : map['warehouse_id']?.toString() ?? '',
      reasonId: map['reason_id'] is ObjectId
          ? (map['reason_id'] as ObjectId).toHexString()
          : map['reason_id']?.toString() ?? '',
      status: map['status']?.toString() ?? 'draft',
      remark: map['remark']?.toString(),
      createdBy: map['created_by']?.toString(),
      createdAt: map['created_at'] is DateTime
          ? map['created_at'] as DateTime
          : DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: map['updated_at'] is DateTime
          ? map['updated_at'] as DateTime
          : DateTime.tryParse(map['updated_at']?.toString() ?? ''),
      items: itemList,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'stock_out_no': stockOutNo,
      'stock_out_date': stockOutDate,
      'status': status,
      'remark': remark,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'items': items.map((item) => item.toMap()).toList(),
    };
    if (id.isNotEmpty) {
      try {
        map['_id'] = ObjectId.fromHexString(id);
      } catch (_) {
        map['id'] = id;
      }
    }
    try {
      map['warehouse_id'] = ObjectId.fromHexString(warehouseId);
    } catch (_) {
      map['warehouse_id'] = warehouseId;
    }
    try {
      map['reason_id'] = ObjectId.fromHexString(reasonId);
    } catch (_) {
      map['reason_id'] = reasonId;
    }
    return map;
  }

  ManualStockOutModel copyWith({
    String? id,
    String? stockOutNo,
    DateTime? stockOutDate,
    String? warehouseId,
    String? reasonId,
    String? status,
    String? remark,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ManualStockOutItemModel>? items,
  }) {
    return ManualStockOutModel(
      id: id ?? this.id,
      stockOutNo: stockOutNo ?? this.stockOutNo,
      stockOutDate: stockOutDate ?? this.stockOutDate,
      warehouseId: warehouseId ?? this.warehouseId,
      reasonId: reasonId ?? this.reasonId,
      status: status ?? this.status,
      remark: remark ?? this.remark,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}
