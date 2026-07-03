import 'package:equatable/equatable.dart';

/// The inventory item / product master record.
class ItemModel extends Equatable {
  final String id;
  final String brandId;

  // Core identification
  final String name;
  final String? sku;           // Stock-keeping unit / item code
  final String? barcode;

  // Classification
  final String? categoryId;
  final String? categoryName;  // Denormalised for display
  final String? unitId;
  final String? unitName;      // Denormalised for display
  final String? unitCode;      // e.g. "kg"

  // Pricing
  final double costPrice;
  final double sellingPrice;

  // Stock
  final double currentStock;
  final double alertQty;       // Low-stock threshold

  // Optional metadata
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final int createdAt;
  final int? updatedAt;

  const ItemModel({
    required this.id,
    required this.brandId,
    required this.name,
    this.sku,
    this.barcode,
    this.categoryId,
    this.categoryName,
    this.unitId,
    this.unitName,
    this.unitCode,
    this.costPrice = 0.0,
    this.sellingPrice = 0.0,
    this.currentStock = 0.0,
    this.alertQty = 0.0,
    this.description,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      unitId: json['unitId'] as String?,
      unitName: json['unitName'] as String?,
      unitCode: json['unitCode'] as String?,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      currentStock: (json['currentStock'] as num?)?.toDouble() ?? 0.0,
      alertQty: (json['alertQty'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'name': name,
        'sku': sku,
        'barcode': barcode,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'unitId': unitId,
        'unitName': unitName,
        'unitCode': unitCode,
        'costPrice': costPrice,
        'sellingPrice': sellingPrice,
        'currentStock': currentStock,
        'alertQty': alertQty,
        'description': description,
        'imageUrl': imageUrl,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  ItemModel copyWith({
    String? id,
    String? brandId,
    String? name,
    String? sku,
    String? barcode,
    String? categoryId,
    String? categoryName,
    String? unitId,
    String? unitName,
    String? unitCode,
    double? costPrice,
    double? sellingPrice,
    double? currentStock,
    double? alertQty,
    String? description,
    String? imageUrl,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      unitCode: unitCode ?? this.unitCode,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      currentStock: currentStock ?? this.currentStock,
      alertQty: alertQty ?? this.alertQty,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// True when stock has fallen to or below the alert quantity.
  bool get isLowStock => alertQty > 0 && currentStock <= alertQty;

  /// Profit margin as a percentage.
  double get profitMarginPercent => sellingPrice > 0
      ? ((sellingPrice - costPrice) / sellingPrice) * 100
      : 0;

  @override
  List<Object?> get props =>
      [id, brandId, name, sku, categoryId, unitId, currentStock, isActive];
}
