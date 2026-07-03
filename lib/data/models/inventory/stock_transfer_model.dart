import 'package:equatable/equatable.dart';

class StockTransferItem extends Equatable {
  final String itemId;
  final String itemName;
  final String? unitCode;
  final double quantity;

  const StockTransferItem({
    required this.itemId,
    required this.itemName,
    this.unitCode,
    required this.quantity,
  });

  factory StockTransferItem.fromJson(Map<String, dynamic> json) {
    return StockTransferItem(
      itemId: json['itemId'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      unitCode: json['unitCode'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemName': itemName,
        'unitCode': unitCode,
        'quantity': quantity,
      };

  @override
  List<Object?> get props => [itemId, itemName, quantity];
}

class StockTransferModel extends Equatable {
  final String id;
  final String brandId;
  final String referenceNo;
  final String fromWarehouseId;
  final String fromWarehouseName;
  final String toWarehouseId;
  final String toWarehouseName;
  final List<StockTransferItem> items;
  final String status; // Pending, Completed, Cancelled
  final int transferDate;
  final String? notes;
  final int createdAt;

  const StockTransferModel({
    required this.id,
    required this.brandId,
    required this.referenceNo,
    required this.fromWarehouseId,
    required this.fromWarehouseName,
    required this.toWarehouseId,
    required this.toWarehouseName,
    required this.items,
    this.status = 'Completed',
    required this.transferDate,
    this.notes,
    required this.createdAt,
  });

  factory StockTransferModel.fromJson(Map<String, dynamic> json) {
    return StockTransferModel(
      id: json['id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      referenceNo: json['referenceNo'] as String? ?? '',
      fromWarehouseId: json['fromWarehouseId'] as String? ?? '',
      fromWarehouseName: json['fromWarehouseName'] as String? ?? '',
      toWarehouseId: json['toWarehouseId'] as String? ?? '',
      toWarehouseName: json['toWarehouseName'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) =>
                  StockTransferItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      status: json['status'] as String? ?? 'Completed',
      transferDate: json['transferDate'] as int? ?? 0,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'referenceNo': referenceNo,
        'fromWarehouseId': fromWarehouseId,
        'fromWarehouseName': fromWarehouseName,
        'toWarehouseId': toWarehouseId,
        'toWarehouseName': toWarehouseName,
        'items': items.map((item) => item.toJson()).toList(),
        'status': status,
        'transferDate': transferDate,
        'notes': notes,
        'createdAt': createdAt,
      };

  StockTransferModel copyWith({
    String? id,
    String? brandId,
    String? referenceNo,
    String? fromWarehouseId,
    String? fromWarehouseName,
    String? toWarehouseId,
    String? toWarehouseName,
    List<StockTransferItem>? items,
    String? status,
    int? transferDate,
    String? notes,
    int? createdAt,
  }) {
    return StockTransferModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      referenceNo: referenceNo ?? this.referenceNo,
      fromWarehouseId: fromWarehouseId ?? this.fromWarehouseId,
      fromWarehouseName: fromWarehouseName ?? this.fromWarehouseName,
      toWarehouseId: toWarehouseId ?? this.toWarehouseId,
      toWarehouseName: toWarehouseName ?? this.toWarehouseName,
      items: items ?? this.items,
      status: status ?? this.status,
      transferDate: transferDate ?? this.transferDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        brandId,
        referenceNo,
        fromWarehouseName,
        toWarehouseName,
        status,
        transferDate
      ];
}
