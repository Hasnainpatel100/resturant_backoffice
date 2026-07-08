import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/inventory/inventory_category_model.dart';
import 'package:back_office/data/repositories/inventory/category_repository.dart';
import 'package:back_office/utils/utils.dart';

/// In-memory mock implementation of [CategoryRepository].
/// Replace with a real API implementation when the backend is ready.
class CategoryRepositoryMockImpl implements CategoryRepository {
  // ── Seed data ────────────────────────────────────────────────────────────
  static final List<InventoryCategoryModel> _store = [
    InventoryCategoryModel(
      id: 'cat-1',
      brandId: 'mock-brand',
      name: 'Beverages',
      description: 'All drinks and liquids',
      isActive: true,
      createdAt: 1700000000000,
    ),
    InventoryCategoryModel(
      id: 'cat-2',
      brandId: 'mock-brand',
      name: 'Dry Goods',
      description: 'Rice, flour, pulses, and dry staples',
      isActive: true,
      createdAt: 1700000001000,
    ),
    InventoryCategoryModel(
      id: 'cat-3',
      brandId: 'mock-brand',
      name: 'Meat & Poultry',
      description: 'Fresh and frozen meats',
      isActive: true,
      createdAt: 1700000002000,
    ),
    InventoryCategoryModel(
      id: 'cat-4',
      brandId: 'mock-brand',
      name: 'Dairy',
      description: 'Milk, cheese, butter, and dairy products',
      isActive: true,
      createdAt: 1700000003000,
    ),
    InventoryCategoryModel(
      id: 'cat-5',
      brandId: 'mock-brand',
      name: 'Vegetables',
      description: 'Fresh vegetables and produce',
      isActive: true,
      createdAt: 1700000004000,
    ),
    InventoryCategoryModel(
      id: 'cat-6',
      brandId: 'mock-brand',
      name: 'Spices & Condiments',
      description: 'Spices, herbs, sauces and seasonings',
      isActive: true,
      createdAt: 1700000005000,
    ),
    InventoryCategoryModel(
      id: 'cat-7',
      brandId: 'mock-brand',
      name: 'Packaging',
      description: 'Boxes, bags, containers, and wrapping',
      isActive: false,
      createdAt: 1700000006000,
    ),
  ];

  static int _idCounter = 100;

  // ── Fake network delay ───────────────────────────────────────────────────
  Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 300));

  // ── Repository methods ───────────────────────────────────────────────────

  @override
  FutureEither<ListResponse<InventoryCategoryModel>> getCategories(
    String brandId, {
    int page = 1,
    int limit = 50,
  }) async {
    return runTask(() async {
      await _delay();
      final all = _store;
      return ListResponse<InventoryCategoryModel>(
        items: all,
        meta: MetaData(
          page: 1,
          pageSize: all.length,
          totalItems: all.length,
          totalPages: 1,
        ),
      );
    });
  }

  @override
  FutureEither<InventoryCategoryModel> getCategory(
    String brandId,
    String categoryId,
  ) async {
    return runTask(() async {
      await _delay();
      final cat = _store.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => throw Exception('Category not found'),
      );
      return cat;
    });
  }

  @override
  FutureEither<InventoryCategoryModel> createCategory(
    String brandId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      await _delay();
      final newCat = InventoryCategoryModel(
        id: 'cat-${++_idCounter}',
        brandId: brandId,
        name: data['name'] as String,
        description: data['description'] as String?,
        isActive: data['isActive'] as bool? ?? true,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      _store.add(newCat);
      return newCat;
    });
  }

  @override
  FutureEither<InventoryCategoryModel> updateCategory(
    String brandId,
    String categoryId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      await _delay();
      final idx = _store.indexWhere((c) => c.id == categoryId);
      if (idx == -1) throw Exception('Category not found');
      final updated = _store[idx].copyWith(
        name: data['name'] as String?,
        description: data['description'] as String?,
        isActive: data['isActive'] as bool?,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      _store[idx] = updated;
      return updated;
    });
  }

  @override
  FutureEither<void> deleteCategory(String brandId, String categoryId) async {
    return runTask(() async {
      await _delay();
      _store.removeWhere((c) => c.id == categoryId);
    });
  }
}
