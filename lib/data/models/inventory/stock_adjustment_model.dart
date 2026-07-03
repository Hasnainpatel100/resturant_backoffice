import 'package:equatable/equatable.dart';

class StockAdjustmentItem extends Equatable {
  final String itemId;
  final String itemName;
  final String? unitCode;
  final double quantity; // positive for addition, negative for subtraction
  final String reason;

  const StockAdjustmentItem({
    required this.itemId,
    required this.itemName,
    this.unitCode,
    required this.quantity,
    required this.reason,
  });

  factory StockAdjustmentItem.fromJson(Map<String, dynamic> json) {
    return StockAdjustmentItem(
      itemId: json['itemId'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      unitCode: json['unitCode'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemName': itemName,
        'unitCode': unitCode,
        'quantity': quantity,
        'reason': reason,
      };

  @override
  List<Object?> get props => [itemId, itemName, quantity, reason];
}

class StockAdjustmentModel extends Equatable {
  final String id;
  final String brandId;
  final String referenceNo;
  final String warehouseId;
  final String warehouseName;
  final List<StockAdjustmentItem> items;
  final int adjustmentDate;
  final String? notes;
  final int createdAt;

  const StockAdjustmentModel({
    required this.id,
    required this.brandId,
    required this.referenceNo,
    required this.warehouseId,
    required this.warehouseName,
    required this.items,
    required this.adjustmentDate,
    this.notes,
    required this.createdAt,
  });

  factory StockAdjustmentModel.fromJson(Map<String, dynamic> json) {
    return StockAdjustmentModel(
      id: json['id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      referenceNo: json['referenceNo'] as String? ?? '',
      warehouseId: json['warehouseId'] as String? ?? '',
      warehouseName: json['warehouseName'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) =>
                  StockAdjustmentItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      adjustmentDate: json['adjustmentDate'] as int? ?? 0,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'referenceNo': referenceNo,
        'warehouseId': warehouseId,
        'warehouseName': warehouseName,
        'items': items.map((item) => item.toJson()).toList(),
        'adjustmentDate': adjustmentDate,
        'notes': notes,
        'createdAt': createdAt,
      };

  StockAdjustmentModel copyWith({
    String? id,
    String? brandId,
    String? referenceNo,
    String? warehouseId,
    String? warehouseName,
    List<StockAdjustmentItem>? items,
    int? adjustmentDate,
    String? notes,
    int? createdAt,
  }) {
    return StockAdjustmentModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      referenceNo: referenceNo ?? this.referenceNo,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      items: items ?? this.items,
      adjustmentDate: adjustmentDate ?? this.adjustmentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        brandId,
        referenceNo,
        warehouseName,
        items,
        adjustmentDate,
        notes
      ];
}
