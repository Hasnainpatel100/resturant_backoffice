import 'package:equatable/equatable.dart';

class PurchaseItem extends Equatable {
  final String itemId;
  final String itemName;
  final String? unitCode;
  final double quantity;
  final double costPrice;
  final double total;

  const PurchaseItem({
    required this.itemId,
    required this.itemName,
    this.unitCode,
    required this.quantity,
    required this.costPrice,
    required this.total,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      itemId: json['itemId'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      unitCode: json['unitCode'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemName': itemName,
        'unitCode': unitCode,
        'quantity': quantity,
        'costPrice': costPrice,
        'total': total,
      };

  @override
  List<Object?> get props => [itemId, itemName, quantity, costPrice, total];
}

class PurchaseModel extends Equatable {
  final String id;
  final String brandId;
  final String referenceNo;
  final String supplierId;
  final String supplierName;
  final String warehouseId;
  final String warehouseName;
  final List<PurchaseItem> items;
  final double subTotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String paymentStatus; // Paid, Unpaid, Partial
  final String? notes;
  final int purchaseDate;
  final int createdAt;

  const PurchaseModel({
    required this.id,
    required this.brandId,
    required this.referenceNo,
    required this.supplierId,
    required this.supplierName,
    required this.warehouseId,
    required this.warehouseName,
    required this.items,
    this.subTotal = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    required this.totalAmount,
    this.paymentStatus = 'Paid',
    this.notes,
    required this.purchaseDate,
    required this.createdAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      referenceNo: json['referenceNo'] as String? ?? '',
      supplierId: json['supplierId'] as String? ?? '',
      supplierName: json['supplierName'] as String? ?? '',
      warehouseId: json['warehouseId'] as String? ?? '',
      warehouseName: json['warehouseName'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => PurchaseItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus'] as String? ?? 'Paid',
      notes: json['notes'] as String?,
      purchaseDate: json['purchaseDate'] as int? ?? 0,
      createdAt: json['createdAt'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'referenceNo': referenceNo,
        'supplierId': supplierId,
        'supplierName': supplierName,
        'warehouseId': warehouseId,
        'warehouseName': warehouseName,
        'items': items.map((item) => item.toJson()).toList(),
        'subTotal': subTotal,
        'taxAmount': taxAmount,
        'discountAmount': discountAmount,
        'totalAmount': totalAmount,
        'paymentStatus': paymentStatus,
        'notes': notes,
        'purchaseDate': purchaseDate,
        'createdAt': createdAt,
      };

  PurchaseModel copyWith({
    String? id,
    String? brandId,
    String? referenceNo,
    String? supplierId,
    String? supplierName,
    String? warehouseId,
    String? warehouseName,
    List<PurchaseItem>? items,
    double? subTotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    String? paymentStatus,
    String? notes,
    int? purchaseDate,
    int? createdAt,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      referenceNo: referenceNo ?? this.referenceNo,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        brandId,
        referenceNo,
        supplierName,
        totalAmount,
        paymentStatus,
        purchaseDate
      ];
}
