import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Category
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Supporting Models
// ─────────────────────────────────────────────────────────────────────────────

/// Room-type specific pricing  {roomTypeId, price}
class RoomPrice extends Equatable {
  final String roomTypeId;
  final double price;

  const RoomPrice({required this.roomTypeId, required this.price});

  factory RoomPrice.fromJson(Map<String, dynamic> json) => RoomPrice(
        roomTypeId: json['roomTypeId'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'roomTypeId': roomTypeId,
        'price': price,
      };

  RoomPrice copyWith({String? roomTypeId, double? price}) =>
      RoomPrice(roomTypeId: roomTypeId ?? this.roomTypeId, price: price ?? this.price);

  @override
  List<Object?> get props => [roomTypeId, price];
}

/// Size variant  {name, price}
class MenuSize extends Equatable {
  final String name;
  final double price;

  const MenuSize({required this.name, required this.price});

  factory MenuSize.fromJson(Map<String, dynamic> json) => MenuSize(
        // API sends "name" in create/update; legacy "size" in GET response
        name: json['name'] as String? ?? json['size'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
      };

  MenuSize copyWith({String? name, double? price}) =>
      MenuSize(name: name ?? this.name, price: price ?? this.price);

  @override
  List<Object?> get props => [name, price];
}

/// Individual modifier choice  {name, price}
class ModifierOption extends Equatable {
  final String name;
  final double price;

  const ModifierOption({required this.name, required this.price});

  factory ModifierOption.fromJson(Map<String, dynamic> json) => ModifierOption(
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {'name': name, 'price': price};

  ModifierOption copyWith({String? name, double? price}) =>
      ModifierOption(name: name ?? this.name, price: price ?? this.price);

  @override
  List<Object?> get props => [name, price];
}

/// Modifier group  {name, min, max, options[]}
class MenuModifier extends Equatable {
  final String name;
  final int min;
  final int max;
  final List<ModifierOption> options;

  const MenuModifier({
    required this.name,
    this.min = 0,
    this.max = 1,
    this.options = const [],
  });

  factory MenuModifier.fromJson(Map<String, dynamic> json) => MenuModifier(
        name: json['name'] as String? ?? '',
        min: json['min'] as int? ?? 0,
        max: json['max'] as int? ?? 1,
        options: (json['options'] as List<dynamic>?)
                ?.map((e) => ModifierOption.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'min': min,
        'max': max,
        'options': options.map((o) => o.toJson()).toList(),
      };

  MenuModifier copyWith({String? name, int? min, int? max, List<ModifierOption>? options}) =>
      MenuModifier(
        name: name ?? this.name,
        min: min ?? this.min,
        max: max ?? this.max,
        options: options ?? this.options,
      );

  @override
  List<Object?> get props => [name, min, max, options];
}

// ─────────────────────────────────────────────────────────────────────────────
// Menu Item Response  (matches full API JSON)
// ─────────────────────────────────────────────────────────────────────────────

class MenuItemResponse extends Equatable {
  final String id;
  final String brandId;
  final String branchId;
  final String categoryId;
  final String name;
  final String? code;
  final String? description;
  final double basePrice;
  final List<RoomPrice> roomPrices;
  final List<MenuSize> sizes;
  final List<MenuModifier> modifiers;
  final List<String> images;
  final bool isVeg;
  final String foodType;
  final double taxPercentage;
  final String status;
  final bool isAvailable;
  final int displayOrder;
  final String currency;
  final List<String> allergenInfo;
  final String spiceLevel;
  final String kitchenStation;
  final String? notes;
  final int createdAt;
  final String createdBy;
  final int? updatedAt;
  final String? updatedBy;

  const MenuItemResponse({
    required this.id,
    this.brandId = '',
    this.branchId = '',
    required this.categoryId,
    required this.name,
    this.code,
    this.description,
    this.basePrice = 0.0,
    this.roomPrices = const [],
    this.sizes = const [],
    this.modifiers = const [],
    this.images = const [],
    this.isVeg = true,
    this.foodType = '',
    this.taxPercentage = 0.0,
    this.status = 'ACTIVE',
    this.isAvailable = true,
    this.displayOrder = 0,
    this.currency = 'INR',
    this.allergenInfo = const [],
    this.spiceLevel = '',
    this.kitchenStation = '',
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
      branchId: json['branchId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      description: json['description'] as String?,
      // Accept both "basePrice" (canonical) and "price" (legacy)
      basePrice:
          (json['basePrice'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0,
      roomPrices: (json['roomPrices'] as List<dynamic>?)
              ?.map((e) => RoomPrice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map((e) => MenuSize.fromJson(e as Map<String, dynamic>))
              .toList() ??
          // fallback: old "sizePrices" field
          (json['sizePrices'] as List<dynamic>?)
              ?.map((e) => MenuSize.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      modifiers: (json['modifiers'] as List<dynamic>?)
              ?.map((e) => MenuModifier.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      isVeg: json['isVeg'] as bool? ?? true,
      foodType: json['foodType'] as String? ?? '',
      taxPercentage: (json['taxPercentage'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'ACTIVE',
      isAvailable: json['isAvailable'] as bool? ?? true,
      displayOrder: json['displayOrder'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      allergenInfo: (json['allergenInfo'] as List<dynamic>?)?.cast<String>() ?? [],
      spiceLevel: json['spiceLevel'] as String? ?? '',
      kitchenStation: json['kitchenStation'] as String? ?? '',
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
        'branchId': branchId,
        'categoryId': categoryId,
        'name': name,
        if (code != null) 'code': code,
        if (description != null) 'description': description,
        'basePrice': basePrice,
        'roomPrices': roomPrices.map((e) => e.toJson()).toList(),
        'sizes': sizes.map((e) => e.toJson()).toList(),
        'modifiers': modifiers.map((e) => e.toJson()).toList(),
        'images': images,
        'isVeg': isVeg,
        'foodType': foodType,
        'taxPercentage': taxPercentage,
        'status': status,
        'isAvailable': isAvailable,
        'displayOrder': displayOrder,
        'currency': currency,
        'allergenInfo': allergenInfo,
        'spiceLevel': spiceLevel,
        'kitchenStation': kitchenStation,
        if (notes != null) 'notes': notes,
        'createdAt': createdAt,
        'createdBy': createdBy,
        'updatedAt': updatedAt,
        'updatedBy': updatedBy,
      };

  @override
  List<Object?> get props =>
      [id, brandId, categoryId, name, basePrice, isAvailable, status, displayOrder];
}

// ─────────────────────────────────────────────────────────────────────────────
// Legacy SizePrice  (kept for backwards compat – mapped to MenuSize in fromJson)
// ─────────────────────────────────────────────────────────────────────────────

class SizePrice extends Equatable {
  final String size;
  final double price;

  const SizePrice({this.size = '', this.price = 0.0});

  factory SizePrice.fromJson(Map<String, dynamic> json) => SizePrice(
        size: json['size'] as String? ?? json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {'size': size, 'price': price};

  @override
  List<Object?> get props => [size, price];
}
