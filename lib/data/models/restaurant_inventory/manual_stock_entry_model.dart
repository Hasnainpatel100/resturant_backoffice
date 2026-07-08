import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class ManualStockEntryItemModel {
  final String id;
  final String? manualStockEntryId;
  final String rawMaterialId;
  final String unitId;
  final double qty;
  final double rate;
  final String? taxId;
  final double taxPercent;
  final double taxAmount;
  final double lineTotal;
  final String? batchNo;
  final DateTime? expiryDate;
  final String? remark;

  ManualStockEntryItemModel({
    required this.id,
    this.manualStockEntryId,
    required this.rawMaterialId,
    required this.unitId,
    required this.qty,
    required this.rate,
    this.taxId,
    this.taxPercent = 0.0,
    this.taxAmount = 0.0,
    required this.lineTotal,
    this.batchNo,
    this.expiryDate,
    this.remark,
  });

  factory ManualStockEntryItemModel.fromMap(Map<String, dynamic> map) {
    return ManualStockEntryItemModel(
      id: map['id']?.toString() ?? map['_id']?.toString() ?? '',
      manualStockEntryId: map['manual_stock_entry_id']?.toString(),
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
      batchNo: map['batch_no']?.toString(),
      expiryDate: map['expiry_date'] is DateTime
          ? map['expiry_date'] as DateTime
          : DateTime.tryParse(map['expiry_date']?.toString() ?? ''),
      remark: map['remark']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'manual_stock_entry_id': manualStockEntryId,
      'qty': qty,
      'rate': rate,
      'tax_percent': taxPercent,
      'tax_amount': taxAmount,
      'line_total': lineTotal,
      'batch_no': batchNo,
      'expiry_date': expiryDate,
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

class ManualStockEntryModel {
  final String id;
  final String entryNo;
  final DateTime entryDate;
  final String warehouseId;
  final String? vendorId;
  final String? purchaseOrderId;
  final String? billTypeId;
  final int noOfRawMaterial;
  final double amount;
  final double taxAmount;
  final double totalWithTax;
  final String status; // 'draft', 'posted'
  final String? remark;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<ManualStockEntryItemModel> items;

  ManualStockEntryModel({
    required this.id,
    required this.entryNo,
    required this.entryDate,
    required this.warehouseId,
    this.vendorId,
    this.purchaseOrderId,
    this.billTypeId,
    this.noOfRawMaterial = 0,
    this.amount = 0.0,
    this.taxAmount = 0.0,
    this.totalWithTax = 0.0,
    this.status = 'draft',
    this.remark,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory ManualStockEntryModel.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final itemList = rawItems.map((item) => ManualStockEntryItemModel.fromMap(item as Map<String, dynamic>)).toList();

    return ManualStockEntryModel(
      id: map['_id'] is ObjectId
          ? (map['_id'] as ObjectId).toHexString()
          : map['id']?.toString() ?? map['_id']?.toString() ?? '',
      entryNo: map['entry_no']?.toString() ?? '',
      entryDate: map['entry_date'] is DateTime
          ? map['entry_date'] as DateTime
          : DateTime.tryParse(map['entry_date']?.toString() ?? '') ?? DateTime.now(),
      warehouseId: map['warehouse_id'] is ObjectId
          ? (map['warehouse_id'] as ObjectId).toHexString()
          : map['warehouse_id']?.toString() ?? '',
      vendorId: map['vendor_id'] is ObjectId
          ? (map['vendor_id'] as ObjectId).toHexString()
          : map['vendor_id']?.toString(),
      purchaseOrderId: map['purchase_order_id'] is ObjectId
          ? (map['purchase_order_id'] as ObjectId).toHexString()
          : map['purchase_order_id']?.toString(),
      billTypeId: map['bill_type_id'] is ObjectId
          ? (map['bill_type_id'] as ObjectId).toHexString()
          : map['bill_type_id']?.toString(),
      noOfRawMaterial: map['no_of_raw_material'] as int? ?? 0,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map['tax_amount'] as num?)?.toDouble() ?? 0.0,
      totalWithTax: (map['total_with_tax'] as num?)?.toDouble() ?? 0.0,
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
      'entry_no': entryNo,
      'entry_date': entryDate,
      'no_of_raw_material': noOfRawMaterial,
      'amount': amount,
      'tax_amount': taxAmount,
      'total_with_tax': totalWithTax,
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
    if (vendorId != null && vendorId!.isNotEmpty) {
      try {
        map['vendor_id'] = ObjectId.fromHexString(vendorId!);
      } catch (_) {
        map['vendor_id'] = vendorId;
      }
    } else {
      map['vendor_id'] = null;
    }
    if (purchaseOrderId != null && purchaseOrderId!.isNotEmpty) {
      try {
        map['purchase_order_id'] = ObjectId.fromHexString(purchaseOrderId!);
      } catch (_) {
        map['purchase_order_id'] = purchaseOrderId;
      }
    } else {
      map['purchase_order_id'] = null;
    }
    if (billTypeId != null && billTypeId!.isNotEmpty) {
      try {
        map['bill_type_id'] = ObjectId.fromHexString(billTypeId!);
      } catch (_) {
        map['bill_type_id'] = billTypeId;
      }
    } else {
      map['bill_type_id'] = null;
    }
    return map;
  }

  ManualStockEntryModel copyWith({
    String? id,
    String? entryNo,
    DateTime? entryDate,
    String? warehouseId,
    String? vendorId,
    String? purchaseOrderId,
    String? billTypeId,
    int? noOfRawMaterial,
    double? amount,
    double? taxAmount,
    double? totalWithTax,
    String? status,
    String? remark,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ManualStockEntryItemModel>? items,
  }) {
    return ManualStockEntryModel(
      id: id ?? this.id,
      entryNo: entryNo ?? this.entryNo,
      entryDate: entryDate ?? this.entryDate,
      warehouseId: warehouseId ?? this.warehouseId,
      vendorId: vendorId ?? this.vendorId,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      billTypeId: billTypeId ?? this.billTypeId,
      noOfRawMaterial: noOfRawMaterial ?? this.noOfRawMaterial,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalWithTax: totalWithTax ?? this.totalWithTax,
      status: status ?? this.status,
      remark: remark ?? this.remark,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}
