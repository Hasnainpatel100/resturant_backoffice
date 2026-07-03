import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/inventory/item_model.dart';
import 'package:back_office/data/repositories/inventory/item_repository.dart';
import 'package:back_office/utils/utils.dart';

/// In-memory mock implementation of [ItemRepository].
/// Replace with a real API implementation when the backend is ready.
class ItemRepositoryMockImpl implements ItemRepository {
  // ── Seed data ────────────────────────────────────────────────────────────
  static final List<ItemModel> _store = [
    ItemModel(
      id: 'item-1',
      brandId: 'mock-brand',
      name: 'Basmati Rice',
      sku: 'SKU-001',
      categoryId: 'cat-2',
      categoryName: 'Dry Goods',
      unitId: 'unit-1',
      unitName: 'Kilogram',
      unitCode: 'kg',
      costPrice: 120.0,
      sellingPrice: 150.0,
      currentStock: 250.0,
      alertQty: 20.0,
      description: 'Premium long-grain basmati rice',
      isActive: true,
      createdAt: 1700000000000,
    ),
    ItemModel(
      id: 'item-2',
      brandId: 'mock-brand',
      name: 'Chicken Breast',
      sku: 'SKU-002',
      categoryId: 'cat-3',
      categoryName: 'Meat & Poultry',
      unitId: 'unit-1',
      unitName: 'Kilogram',
      unitCode: 'kg',
      costPrice: 280.0,
      sellingPrice: 350.0,
      currentStock: 15.0,
      alertQty: 10.0,
      description: 'Fresh boneless chicken breast',
      isActive: true,
      createdAt: 1700000001000,
    ),
    ItemModel(
      id: 'item-3',
      brandId: 'mock-brand',
      name: 'Olive Oil',
      sku: 'SKU-003',
      categoryId: 'cat-5',
      categoryName: 'Spices & Condiments',
      unitId: 'unit-3',
      unitName: 'Litre',
      unitCode: 'L',
      costPrice: 450.0,
      sellingPrice: 600.0,
      currentStock: 30.0,
      alertQty: 5.0,
      description: 'Extra virgin olive oil',
      isActive: true,
      createdAt: 1700000002000,
    ),
    ItemModel(
      id: 'item-4',
      brandId: 'mock-brand',
      name: 'Mozzarella Cheese',
      sku: 'SKU-004',
      categoryId: 'cat-4',
      categoryName: 'Dairy',
      unitId: 'unit-1',
      unitName: 'Kilogram',
      unitCode: 'kg',
      costPrice: 600.0,
      sellingPrice: 780.0,
      currentStock: 8.0,
      alertQty: 5.0,
      description: 'Fresh mozzarella cheese block',
      isActive: true,
      createdAt: 1700000003000,
    ),
    ItemModel(
      id: 'item-5',
      brandId: 'mock-brand',
      name: 'Tomato Puree',
      sku: 'SKU-005',
      categoryId: 'cat-5',
      categoryName: 'Spices & Condiments',
      unitId: 'unit-3',
      unitName: 'Litre',
      unitCode: 'L',
      costPrice: 80.0,
      sellingPrice: 110.0,
      currentStock: 3.0,
      alertQty: 5.0,
      description: 'Concentrated tomato puree',
      isActive: true,
      createdAt: 1700000004000,
    ),
    ItemModel(
      id: 'item-6',
      brandId: 'mock-brand',
      name: 'Mineral Water Bottles',
      sku: 'SKU-006',
      categoryId: 'cat-1',
      categoryName: 'Beverages',
      unitId: 'unit-6',
      unitName: 'Box',
      unitCode: 'box',
      costPrice: 220.0,
      sellingPrice: 300.0,
      currentStock: 50.0,
      alertQty: 10.0,
      description: '24 x 500mL water bottles',
      isActive: true,
      createdAt: 1700000005000,
    ),
    ItemModel(
      id: 'item-7',
      brandId: 'mock-brand',
      name: 'Fresh Cream',
      sku: 'SKU-007',
      categoryId: 'cat-4',
      categoryName: 'Dairy',
      unitId: 'unit-3',
      unitName: 'Litre',
      unitCode: 'L',
      costPrice: 160.0,
      sellingPrice: 210.0,
      currentStock: 0.0,
      alertQty: 3.0,
      description: 'Full-fat fresh cream',
      isActive: false,
      createdAt: 1700000006000,
    ),
  ];

  static int _idCounter = 100;

  Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 300));

  @override
  FutureEither<ListResponse<ItemModel>> getItems(
    String brandId, {
    int page = 1,
    int limit = 50,
    String? search,
    String? categoryId,
  }) async {
    return runTask(() async {
      await _delay();
      var results = _store.toList();

      // Filter by search query
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        results = results
            .where((i) =>
                i.name.toLowerCase().contains(q) ||
                (i.sku?.toLowerCase().contains(q) ?? false))
            .toList();
      }

      // Filter by category
      if (categoryId != null && categoryId.isNotEmpty) {
        results = results.where((i) => i.categoryId == categoryId).toList();
      }

      return ListResponse<ItemModel>(
        items: results,
        meta: MetaData(
          page: 1,
          pageSize: results.length,
          totalItems: results.length,
          totalPages: 1,
        ),
      );
    });
  }

  @override
  FutureEither<ItemModel> getItem(String brandId, String itemId) async {
    return runTask(() async {
      await _delay();
      return _store.firstWhere(
        (i) => i.id == itemId,
        orElse: () => throw Exception('Item not found'),
      );
    });
  }

  @override
  FutureEither<ItemModel> createItem(
    String brandId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      await _delay();
      final newItem = ItemModel(
        id: 'item-${++_idCounter}',
        brandId: brandId,
        name: data['name'] as String,
        sku: data['sku'] as String?,
        barcode: data['barcode'] as String?,
        categoryId: data['categoryId'] as String?,
        categoryName: data['categoryName'] as String?,
        unitId: data['unitId'] as String?,
        unitName: data['unitName'] as String?,
        unitCode: data['unitCode'] as String?,
        costPrice: (data['costPrice'] as num?)?.toDouble() ?? 0.0,
        sellingPrice: (data['sellingPrice'] as num?)?.toDouble() ?? 0.0,
        currentStock: (data['currentStock'] as num?)?.toDouble() ?? 0.0,
        alertQty: (data['alertQty'] as num?)?.toDouble() ?? 0.0,
        description: data['description'] as String?,
        isActive: data['isActive'] as bool? ?? true,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      _store.add(newItem);
      return newItem;
    });
  }

  @override
  FutureEither<ItemModel> updateItem(
    String brandId,
    String itemId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      await _delay();
      final idx = _store.indexWhere((i) => i.id == itemId);
      if (idx == -1) throw Exception('Item not found');
      final updated = _store[idx].copyWith(
        name: data['name'] as String?,
        sku: data['sku'] as String?,
        barcode: data['barcode'] as String?,
        categoryId: data['categoryId'] as String?,
        categoryName: data['categoryName'] as String?,
        unitId: data['unitId'] as String?,
        unitName: data['unitName'] as String?,
        unitCode: data['unitCode'] as String?,
        costPrice: (data['costPrice'] as num?)?.toDouble(),
        sellingPrice: (data['sellingPrice'] as num?)?.toDouble(),
        currentStock: (data['currentStock'] as num?)?.toDouble(),
        alertQty: (data['alertQty'] as num?)?.toDouble(),
        description: data['description'] as String?,
        isActive: data['isActive'] as bool?,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      _store[idx] = updated;
      return updated;
    });
  }

  @override
  FutureEither<void> deleteItem(String brandId, String itemId) async {
    return runTask(() async {
      await _delay();
      _store.removeWhere((i) => i.id == itemId);
    });
  }

  /// Helper method for mock mutations to adjust stock
  static void adjustStock(String itemId, double quantityOffset) {
    final idx = _store.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      _store[idx] = _store[idx].copyWith(
        currentStock: _store[idx].currentStock + quantityOffset,
      );
    }
  }
}
