import 'package:equatable/equatable.dart';

class BillItemModel extends Equatable {
  final String id;
  final String itemId;
  final String name;
  final String categoryId;
  final String categoryName;
  final bool isVeg;
  final int quantity;
  final double unitPrice;
  final String? size;
  final List<dynamic> modifiers;
  final double taxPercentage;
  final double taxAmount;
  final double total;

  const BillItemModel({
    required this.id,
    required this.itemId,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    this.isVeg = false,
    this.quantity = 1,
    this.unitPrice = 0.0,
    this.size,
    this.modifiers = const [],
    this.taxPercentage = 0.0,
    this.taxAmount = 0.0,
    this.total = 0.0,
  });

  factory BillItemModel.fromJson(Map<String, dynamic> json) {
    return BillItemModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      itemId: json['itemId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      isVeg: json['isVeg'] as bool? ?? false,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      size: json['size'] as String?,
      modifiers: json['modifiers'] as List<dynamic>? ?? const [],
      taxPercentage: (json['taxPercentage'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'name': name,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'isVeg': isVeg,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'size': size,
        'modifiers': modifiers,
        'taxPercentage': taxPercentage,
        'taxAmount': taxAmount,
        'total': total,
      };

  @override
  List<Object?> get props => [
        id,
        itemId,
        name,
        categoryId,
        categoryName,
        isVeg,
        quantity,
        unitPrice,
        size,
        modifiers,
        taxPercentage,
        taxAmount,
        total,
      ];
}

class BillModel extends Equatable {
  final String id;
  final String billNumber;
  final String branchId;
  final String brandId;
  final String serviceType;
  final String? tableId;
  final String? tableName;
  final List<BillItemModel> items;
  final double subTotal;
  final double taxAmount;
  final double discountAmount;
  final double discountPercent;
  final String? discountReason;
  final double packagingCharges;
  final double deliveryCharges;
  final double tipAmount;
  final double totalAmount;
  final double amountPaid;
  final double changeAmount;
  final String status;
  final String paymentStatus;
  final String paymentMode;
  final String billDate;
  final int printCount;
  final String? waiterName;
  final String createdBy;
  final int createdAt;
  final bool isActive;

  const BillModel({
    required this.id,
    required this.billNumber,
    required this.branchId,
    required this.brandId,
    required this.serviceType,
    this.tableId,
    this.tableName,
    required this.items,
    this.subTotal = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    this.discountPercent = 0.0,
    this.discountReason,
    this.packagingCharges = 0.0,
    this.deliveryCharges = 0.0,
    this.tipAmount = 0.0,
    this.totalAmount = 0.0,
    this.amountPaid = 0.0,
    this.changeAmount = 0.0,
    required this.status,
    required this.paymentStatus,
    required this.paymentMode,
    required this.billDate,
    this.printCount = 0,
    this.waiterName,
    required this.createdBy,
    required this.createdAt,
    this.isActive = true,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      billNumber: json['billNumber'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      serviceType: json['serviceType'] as String? ?? '',
      tableId: json['tableId'] as String?,
      tableName: json['tableName'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => BillItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0.0,
      discountReason: json['discountReason'] as String?,
      packagingCharges: (json['packagingCharges'] as num?)?.toDouble() ?? 0.0,
      deliveryCharges: (json['deliveryCharges'] as num?)?.toDouble() ?? 0.0,
      tipAmount: (json['tipAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      changeAmount: (json['changeAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? '',
      paymentMode: json['paymentMode'] as String? ?? '',
      billDate: json['billDate'] as String? ?? '',
      printCount: (json['printCount'] as num?)?.toInt() ?? 0,
      waiterName: json['waiterName'] as String?,
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'billNumber': billNumber,
        'branchId': branchId,
        'brandId': brandId,
        'serviceType': serviceType,
        'tableId': tableId,
        'tableName': tableName,
        'items': items.map((e) => e.toJson()).toList(),
        'subTotal': subTotal,
        'taxAmount': taxAmount,
        'discountAmount': discountAmount,
        'discountPercent': discountPercent,
        'discountReason': discountReason,
        'packagingCharges': packagingCharges,
        'deliveryCharges': deliveryCharges,
        'tipAmount': tipAmount,
        'totalAmount': totalAmount,
        'amountPaid': amountPaid,
        'changeAmount': changeAmount,
        'status': status,
        'paymentStatus': paymentStatus,
        'paymentMode': paymentMode,
        'billDate': billDate,
        'printCount': printCount,
        'waiterName': waiterName,
        'createdBy': createdBy,
        'createdAt': createdAt,
        'isActive': isActive,
      };

  @override
  List<Object?> get props => [
        id,
        billNumber,
        branchId,
        brandId,
        serviceType,
        tableId,
        tableName,
        items,
        subTotal,
        taxAmount,
        discountAmount,
        discountPercent,
        discountReason,
        packagingCharges,
        deliveryCharges,
        tipAmount,
        totalAmount,
        amountPaid,
        changeAmount,
        status,
        paymentStatus,
        paymentMode,
        billDate,
        printCount,
        waiterName,
        createdBy,
        createdAt,
        isActive,
      ];
}
