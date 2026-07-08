import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/inventory/stock_adjustment_model.dart';
import 'package:back_office/data/repositories/inventory/stock_adjustment_repository.dart';
import 'package:back_office/data/repositories/inventory/item_repository_mock_impl.dart';
import 'package:back_office/utils/utils.dart';

class StockAdjustmentRepositoryMockImpl implements StockAdjustmentRepository {
  static final List<StockAdjustmentModel> _store = [
    StockAdjustmentModel(
      id: 'adj-1',
      brandId: 'mock-brand',
      referenceNo: 'ADJ-2026-001',
      warehouseId: 'wh-2',
      warehouseName: 'Cold Storage',
      items: const [
        StockAdjustmentItem(
          itemId: 'item-2',
          itemName: 'Chicken Breast',
          unitCode: 'kg',
          quantity: -2.0, // wasted/spoiled
          reason: 'Spoilage',
        ),
      ],
      adjustmentDate: 1700000000000,
      notes: 'Weekly waste audit',
      createdAt: 1700000000000,
    ),
    StockAdjustmentModel(
      id: 'adj-2',
      brandId: 'mock-brand',
      referenceNo: 'ADJ-2026-002',
      warehouseId: 'wh-3',
      warehouseName: 'Dry Store',
      items: const [
        StockAdjustmentItem(
          itemId: 'item-1',
          itemName: 'Basmati Rice',
          unitCode: 'kg',
          quantity: 10.0, // extra bag found
          reason: 'Stock Audit Variance',
        ),
      ],
      adjustmentDate: 1700000010000,
      notes: 'Physical audit correction',
      createdAt: 1700000010000,
    ),
  ];

  static int _idCounter = 100;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 300));

  @override
  FutureEither<ListResponse<StockAdjustmentModel>> getAdjustments(
    String brandId, {
    int page = 1,
    int limit = 50,
  }) async {
    return runTask(() async {
      await _delay();
      return ListResponse<StockAdjustmentModel>(
        items: _store,
        meta: MetaData(
          page: 1,
          pageSize: _store.length,
          totalItems: _store.length,
          totalPages: 1,
        ),
      );
    });
  }

  @override
  FutureEither<StockAdjustmentModel> createAdjustment(
    String brandId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      await _delay();
      final itemsRaw = data['items'] as List<dynamic>;
      final parsedItems = itemsRaw
          .map((i) => StockAdjustmentItem.fromJson(i as Map<String, dynamic>))
          .toList();

      final newAdjustment = StockAdjustmentModel(
        id: 'adj-${++_idCounter}',
        brandId: brandId,
        referenceNo: data['referenceNo'] as String? ?? 'ADJ-${DateTime.now().year}-${_idCounter}',
        warehouseId: data['warehouseId'] as String,
        warehouseName: data['warehouseName'] as String,
        items: parsedItems,
        adjustmentDate: data['adjustmentDate'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        notes: data['notes'] as String?,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Perform stock mutation: Add the quantity offset (could be + or -) to currentStock
      for (final item in parsedItems) {
        ItemRepositoryMockImpl.adjustStock(item.itemId, item.quantity);
      }

      _store.add(newAdjustment);
      return newAdjustment;
    });
  }
}
