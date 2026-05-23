import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String brandId;
  final String? parentId;
  final String name;
  final String? description;
  final int displayOrder;
  final String imageUrl;
  final bool isActive;
  final int createdAt;
  final String createdBy;
  final int? updatedAt;
  final String? updatedBy;

  const CategoryModel({
    required this.id,
    required this.brandId,
    this.parentId,
    required this.name,
    this.description,
    this.displayOrder = 0,
    this.imageUrl = '',
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      parentId: json['parentId'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as int? ?? 0,
      createdBy: json['createdBy'] as String? ?? '',
      updatedAt: json['updatedAt'] as int?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'parentId': parentId,
        'name': name,
        'description': description,
        'displayOrder': displayOrder,
        'imageUrl': imageUrl,
        'isActive': isActive,
        'createdAt': createdAt,
        'createdBy': createdBy,
        'updatedAt': updatedAt,
        'updatedBy': updatedBy,
      };

  @override
  List<Object?> get props => [id, brandId, name, displayOrder, isActive];
}

class MenuItemResponse extends Equatable {
  final String id;
  final String brandId;
  final String categoryId;
  final String name;
  final String? description;
  final double basePrice;
  final String currency;
  final List<SizePrice> sizePrices;
  final List<String> allergenInfo;
  final String foodType;
  final String spiceLevel;
  final String kitchenStation;
  final String status;
  final bool isAvailable;
  final String imageUrl;
  final String? notes;
  final int createdAt;
  final String createdBy;
  final int? updatedAt;
  final String? updatedBy;

  const MenuItemResponse({
    required this.id,
    required this.brandId,
    required this.categoryId,
    required this.name,
    this.description,
    this.basePrice = 0.0,
    this.currency = 'INR',
    this.sizePrices = const [],
    this.allergenInfo = const [],
    this.foodType = '',
    this.spiceLevel = '',
    this.kitchenStation = '',
    this.status = 'ACTIVE',
    this.isAvailable = true,
    this.imageUrl = '',
    this.notes,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory MenuItemResponse.fromJson(Map<String, dynamic> json) {
    return MenuItemResponse(
      id: json['id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      sizePrices: (json['sizePrices'] as List<dynamic>?)?.map((e) => SizePrice.fromJson(e)).toList() ?? [],
      allergenInfo: (json['allergenInfo'] as List<dynamic>?)?.cast<String>() ?? [],
      foodType: json['foodType'] as String? ?? '',
      spiceLevel: json['spiceLevel'] as String? ?? '',
      kitchenStation: json['kitchenStation'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      isAvailable: json['isAvailable'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String? ?? '',
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as int? ?? 0,
      createdBy: json['createdBy'] as String? ?? '',
      updatedAt: json['updatedAt'] as int?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'categoryId': categoryId,
        'name': name,
        'description': description,
        'basePrice': basePrice,
        'currency': currency,
        'sizePrices': sizePrices.map((e) => e.toJson()).toList(),
        'allergenInfo': allergenInfo,
        'foodType': foodType,
        'spiceLevel': spiceLevel,
        'kitchenStation': kitchenStation,
        'status': status,
        'isAvailable': isAvailable,
        'imageUrl': imageUrl,
        'notes': notes,
        'createdAt': createdAt,
        'createdBy': createdBy,
        'updatedAt': updatedAt,
        'updatedBy': updatedBy,
      };

  @override
  List<Object?> get props => [id, brandId, categoryId, name, basePrice, isAvailable];
}

class SizePrice extends Equatable {
  final String size;
  final double price;

  const SizePrice({
    this.size = '',
    this.price = 0.0,
  });

  factory SizePrice.fromJson(Map<String, dynamic> json) {
    return SizePrice(
      size: json['size'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'size': size,
        'price': price,
      };

  @override
  List<Object?> get props => [size, price];
}
