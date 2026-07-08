import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class SupplierInvoiceItemModel {
  final String id;
  final String? invoiceId;
  final String rawMaterialId;
  final String unitId;
  final double qty;
  final double rate;
  final String? taxId;
  final double taxPercent;
  final double taxAmount;
  final double lineTotal;
  final String? remark;

  SupplierInvoiceItemModel({
    required this.id,
    this.invoiceId,
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

  factory SupplierInvoiceItemModel.fromMap(Map<String, dynamic> map) {
    return SupplierInvoiceItemModel(
      id: map['id']?.toString() ?? map['_id']?.toString() ?? '',
      invoiceId: map['invoice_id']?.toString(),
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
      'invoice_id': invoiceId,
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

class SupplierInvoiceModel {
  final String id;
  final String invoiceNo;
  final DateTime invoiceDate;
  final String? grnId;
  final String? purchaseOrderId;
  final String vendorId;
  final String status; // 'draft', 'posted'
  final double amount;
  final double taxAmount;
  final double totalWithTax;
  final String? remark;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<SupplierInvoiceItemModel> items;

  SupplierInvoiceModel({
    required this.id,
    required this.invoiceNo,
    required this.invoiceDate,
    this.grnId,
    this.purchaseOrderId,
    required this.vendorId,
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

  factory SupplierInvoiceModel.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final itemList = rawItems.map((item) => SupplierInvoiceItemModel.fromMap(item as Map<String, dynamic>)).toList();

    return SupplierInvoiceModel(
      id: map['_id'] is ObjectId
          ? (map['_id'] as ObjectId).toHexString()
          : map['id']?.toString() ?? map['_id']?.toString() ?? '',
      invoiceNo: map['invoice_no']?.toString() ?? '',
      invoiceDate: map['invoice_date'] is DateTime
          ? map['invoice_date'] as DateTime
          : DateTime.tryParse(map['invoice_date']?.toString() ?? '') ?? DateTime.now(),
      grnId: map['grn_id'] is ObjectId
          ? (map['grn_id'] as ObjectId).toHexString()
          : map['grn_id']?.toString(),
      purchaseOrderId: map['purchase_order_id'] is ObjectId
          ? (map['purchase_order_id'] as ObjectId).toHexString()
          : map['purchase_order_id']?.toString(),
      vendorId: map['vendor_id'] is ObjectId
          ? (map['vendor_id'] as ObjectId).toHexString()
          : map['vendor_id']?.toString() ?? '',
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
      'invoice_no': invoiceNo,
      'invoice_date': invoiceDate,
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
    if (grnId != null && grnId!.isNotEmpty) {
      try {
        map['grn_id'] = ObjectId.fromHexString(grnId!);
      } catch (_) {
        map['grn_id'] = grnId;
      }
    } else {
      map['grn_id'] = null;
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
    return map;
  }

  SupplierInvoiceModel copyWith({
    String? id,
    String? invoiceNo,
    DateTime? invoiceDate,
    String? grnId,
    String? purchaseOrderId,
    String? vendorId,
    String? status,
    double? amount,
    double? taxAmount,
    double? totalWithTax,
    String? remark,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SupplierInvoiceItemModel>? items,
  }) {
    return SupplierInvoiceModel(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      grnId: grnId ?? this.grnId,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      vendorId: vendorId ?? this.vendorId,
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
