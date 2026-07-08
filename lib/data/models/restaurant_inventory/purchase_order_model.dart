import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class PurchaseOrderItemModel {
  final String id;
  final String? poId;
  final String rawMaterialId;
  final String unitId;
  final double qty;
  final double rate;
  final String? taxId;
  final double taxPercent;
  final double taxAmount;
  final double lineTotal;
  final String? remark;

  PurchaseOrderItemModel({
    required this.id,
    this.poId,
    required this.rawMaterialId,
    required this.unitId,
    required this.qty,
    required this.rate,
    this.taxId,
    this.taxPercent = 0.0,
    this.taxAmount = 0.0,
    required this.lineTotal,
    this.remark,
  });

  factory PurchaseOrderItemModel.fromMap(Map<String, dynamic> map) {
    return PurchaseOrderItemModel(
      id: map['id']?.toString() ?? map['_id']?.toString() ?? '',
      poId: map['po_id']?.toString(),
      rawMaterialId: map['raw_material_id'] is ObjectId
          ? (map['raw_material_id'] as ObjectId).toHexString()
          : map['raw_material_id']?.toString() ?? '',
      unitId: map['unit_id'] is ObjectId
          ? (map['unit_id'] as ObjectId).toHexString()
          : map['unit_id']?.toString() ?? '',
      qty: (map['qty'] as num?)?.toDouble() ?? 0.0,
      rate: (map['rate'] as num?)?.toDouble() ?? 0.0,
      taxId: map['tax_id'] is ObjectId
          ? (map['tax_id'] as ObjectId).toHexString()
          : map['tax_id']?.toString(),
      taxPercent: (map['tax_percent'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map['tax_amount'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (map['line_total'] as num?)?.toDouble() ?? 0.0,
      remark: map['remark']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'po_id': poId,
      'qty': qty,
      'rate': rate,
      'tax_percent': taxPercent,
      'tax_amount': taxAmount,
      'line_total': lineTotal,
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
    if (taxId != null && taxId!.isNotEmpty) {
      try {
        map['tax_id'] = ObjectId.fromHexString(taxId!);
      } catch (_) {
        map['tax_id'] = taxId;
      }
    } else {
      map['tax_id'] = null;
    }
    return map;
  }
}

class PurchaseOrderModel {
  final String id;
  final String poNo;
  final DateTime poDate;
  final String vendorId;
  final DateTime deliveryDate;
  final String deliveryAddress;
  final String status; // 'draft', 'submitted', 'received', 'cancelled'
  final double amount;
  final double taxAmount;
  final double totalWithTax;
  final String? remark;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<PurchaseOrderItemModel> items;

  PurchaseOrderModel({
    required this.id,
    required this.poNo,
    required this.poDate,
    required this.vendorId,
    required this.deliveryDate,
    required this.deliveryAddress,
    this.status = 'draft',
    this.amount = 0.0,
    this.taxAmount = 0.0,
    this.totalWithTax = 0.0,
    this.remark,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory PurchaseOrderModel.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final itemList = rawItems.map((item) => PurchaseOrderItemModel.fromMap(item as Map<String, dynamic>)).toList();

    return PurchaseOrderModel(
      id: map['_id'] is ObjectId
          ? (map['_id'] as ObjectId).toHexString()
          : map['id']?.toString() ?? map['_id']?.toString() ?? '',
      poNo: map['po_no']?.toString() ?? '',
      poDate: map['po_date'] is DateTime
          ? map['po_date'] as DateTime
          : DateTime.tryParse(map['po_date']?.toString() ?? '') ?? DateTime.now(),
      vendorId: map['vendor_id'] is ObjectId
          ? (map['vendor_id'] as ObjectId).toHexString()
          : map['vendor_id']?.toString() ?? '',
      deliveryDate: map['delivery_date'] is DateTime
          ? map['delivery_date'] as DateTime
          : DateTime.tryParse(map['delivery_date']?.toString() ?? '') ?? DateTime.now(),
      deliveryAddress: map['delivery_address']?.toString() ?? '',
      status: map['status']?.toString() ?? 'draft',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map['tax_amount'] as num?)?.toDouble() ?? 0.0,
      totalWithTax: (map['total_with_tax'] as num?)?.toDouble() ?? 0.0,
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
      'po_no': poNo,
      'po_date': poDate,
      'delivery_date': deliveryDate,
      'delivery_address': deliveryAddress,
      'status': status,
      'amount': amount,
      'tax_amount': taxAmount,
      'total_with_tax': totalWithTax,
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
      map['vendor_id'] = ObjectId.fromHexString(vendorId);
    } catch (_) {
      map['vendor_id'] = vendorId;
    }
    return map;
  }

  PurchaseOrderModel copyWith({
    String? id,
    String? poNo,
    DateTime? poDate,
    String? vendorId,
    DateTime? deliveryDate,
    String? deliveryAddress,
    String? status,
    double? amount,
    double? taxAmount,
    double? totalWithTax,
    String? remark,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PurchaseOrderItemModel>? items,
  }) {
    return PurchaseOrderModel(
      id: id ?? this.id,
      poNo: poNo ?? this.poNo,
      poDate: poDate ?? this.poDate,
      vendorId: vendorId ?? this.vendorId,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalWithTax: totalWithTax ?? this.totalWithTax,
      remark: remark ?? this.remark,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}
