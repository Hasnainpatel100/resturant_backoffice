import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class RawMaterialModel {
  final String id;
  final String materialCode;
  final String materialName;
  final String shortName;
  final String groupId;
  final String baseUnitId;
  final String? defaultTaxId;
  final double purchaseRate;
  final double lastPurchaseRate;
  final double sellingRate;
  final double reorderLevel;
  final double minimumLevel;
  final double maximumLevel;
  final bool trackInventory;
  final bool hasExpiry;
  final bool isBatchWise;
  final bool isFurnishedItem;
  final bool isSubRecipeItem;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RawMaterialModel({
    required this.id,
    required this.materialCode,
    required this.materialName,
    required this.shortName,
    required this.groupId,
    required this.baseUnitId,
    this.defaultTaxId,
    this.purchaseRate = 0.0,
    this.lastPurchaseRate = 0.0,
    this.sellingRate = 0.0,
    this.reorderLevel = 0.0,
    this.minimumLevel = 0.0,
    this.maximumLevel = 0.0,
    this.trackInventory = true,
    this.hasExpiry = false,
    this.isBatchWise = false,
    this.isFurnishedItem = false,
    this.isSubRecipeItem = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory RawMaterialModel.fromMap(Map<String, dynamic> map) {
    return RawMaterialModel(
      id: map['_id'] is ObjectId
          ? (map['_id'] as ObjectId).toHexString()
          : map['id']?.toString() ?? map['_id']?.toString() ?? '',
      materialCode: map['material_code']?.toString() ?? '',
      materialName: map['material_name']?.toString() ?? '',
      shortName: map['short_name']?.toString() ?? '',
      groupId: map['group_id'] is ObjectId
          ? (map['group_id'] as ObjectId).toHexString()
          : map['group_id']?.toString() ?? '',
      baseUnitId: map['base_unit_id'] is ObjectId
          ? (map['base_unit_id'] as ObjectId).toHexString()
          : map['base_unit_id']?.toString() ?? '',
      defaultTaxId: map['default_tax_id'] is ObjectId
          ? (map['default_tax_id'] as ObjectId).toHexString()
          : map['default_tax_id']?.toString(),
      purchaseRate: (map['purchase_rate'] as num?)?.toDouble() ?? 0.0,
      lastPurchaseRate: (map['last_purchase_rate'] as num?)?.toDouble() ?? 0.0,
      sellingRate: (map['selling_rate'] as num?)?.toDouble() ?? 0.0,
      reorderLevel: (map['reorder_level'] as num?)?.toDouble() ?? 0.0,
      minimumLevel: (map['minimum_level'] as num?)?.toDouble() ?? 0.0,
      maximumLevel: (map['maximum_level'] as num?)?.toDouble() ?? 0.0,
      trackInventory: map['track_inventory'] as bool? ?? true,
      hasExpiry: map['has_expiry'] as bool? ?? false,
      isBatchWise: map['is_batch_wise'] as bool? ?? false,
      isFurnishedItem: map['is_furnished_item'] as bool? ?? false,
      isSubRecipeItem: map['is_sub_recipe_item'] as bool? ?? false,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: map['created_at'] is DateTime
          ? map['created_at'] as DateTime
          : DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: map['updated_at'] is DateTime
          ? map['updated_at'] as DateTime
          : DateTime.tryParse(map['updated_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'material_code': materialCode,
      'material_name': materialName,
      'short_name': shortName,
      'purchase_rate': purchaseRate,
      'last_purchase_rate': lastPurchaseRate,
      'selling_rate': sellingRate,
      'reorder_level': reorderLevel,
      'minimum_level': minimumLevel,
      'maximum_level': maximumLevel,
      'track_inventory': trackInventory,
      'has_expiry': hasExpiry,
      'is_batch_wise': isBatchWise,
      'is_furnished_item': isFurnishedItem,
      'is_sub_recipe_item': isSubRecipeItem,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
    if (id.isNotEmpty) {
      try {
        map['_id'] = ObjectId.fromHexString(id);
      } catch (_) {
        map['id'] = id;
      }
    }
    if (groupId.isNotEmpty) {
      try {
        map['group_id'] = ObjectId.fromHexString(groupId);
      } catch (_) {
        map['group_id'] = groupId;
      }
    }
    if (baseUnitId.isNotEmpty) {
      try {
        map['base_unit_id'] = ObjectId.fromHexString(baseUnitId);
      } catch (_) {
        map['base_unit_id'] = baseUnitId;
      }
    }
    if (defaultTaxId != null && defaultTaxId!.isNotEmpty) {
      try {
        map['default_tax_id'] = ObjectId.fromHexString(defaultTaxId!);
      } catch (_) {
        map['default_tax_id'] = defaultTaxId;
      }
    } else {
      map['default_tax_id'] = null;
    }
    return map;
  }

  RawMaterialModel copyWith({
    String? id,
    String? materialCode,
    String? materialName,
    String? shortName,
    String? groupId,
    String? baseUnitId,
    String? defaultTaxId,
    double? purchaseRate,
    double? lastPurchaseRate,
    double? sellingRate,
    double? reorderLevel,
    double? minimumLevel,
    double? maximumLevel,
    bool? trackInventory,
    bool? hasExpiry,
    bool? isBatchWise,
    bool? isFurnishedItem,
    bool? isSubRecipeItem,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RawMaterialModel(
      id: id ?? this.id,
      materialCode: materialCode ?? this.materialCode,
      materialName: materialName ?? this.materialName,
      shortName: shortName ?? this.shortName,
      groupId: groupId ?? this.groupId,
      baseUnitId: baseUnitId ?? this.baseUnitId,
      defaultTaxId: defaultTaxId ?? this.defaultTaxId,
      purchaseRate: purchaseRate ?? this.purchaseRate,
      lastPurchaseRate: lastPurchaseRate ?? this.lastPurchaseRate,
      sellingRate: sellingRate ?? this.sellingRate,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      minimumLevel: minimumLevel ?? this.minimumLevel,
      maximumLevel: maximumLevel ?? this.maximumLevel,
      trackInventory: trackInventory ?? this.trackInventory,
      hasExpiry: hasExpiry ?? this.hasExpiry,
      isBatchWise: isBatchWise ?? this.isBatchWise,
      isFurnishedItem: isFurnishedItem ?? this.isFurnishedItem,
      isSubRecipeItem: isSubRecipeItem ?? this.isSubRecipeItem,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayLabel => '$materialName ($materialCode)';
}
