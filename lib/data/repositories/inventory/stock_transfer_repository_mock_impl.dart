import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/inventory/stock_transfer_model.dart';
import 'package:back_office/data/repositories/inventory/stock_transfer_repository.dart';
import 'package:back_office/utils/utils.dart';

class StockTransferRepositoryMockImpl implements StockTransferRepository {
  static final List<StockTransferModel> _store = [
    StockTransferModel(
      id: 'trans-1',
      brandId: 'mock-brand',
      referenceNo: 'TR-2026-001',
      fromWarehouseId: 'wh-3',
      fromWarehouseName: 'Dry Store',
      toWarehouseId: 'wh-1',
      toWarehouseName: 'Main Kitchen Store',
      items: const [
        StockTransferItem(
          itemId: 'item-1',
          itemName: 'Basmati Rice',
          unitCode: 'kg',
          quantity: 20.0,
        ),
      ],
      status: 'Completed',
      transferDate: 1700000000000,
      notes: 'Transfer rice for daily prep kitchen',
      createdAt: 1700000000000,
    ),
  ];

  static int _idCounter = 100;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 300));

  @override
  FutureEither<ListResponse<StockTransferModel>> getTransfers(
    String brandId, {
    int page = 1,
    int limit = 50,
  }) async {
    return runTask(() async {
      await _delay();
      return ListResponse<StockTransferModel>(
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
  FutureEither<StockTransferModel> createTransfer(
    String brandId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      await _delay();
      final itemsRaw = data['items'] as List<dynamic>;
      final parsedItems = itemsRaw
          .map((i) => StockTransferItem.fromJson(i as Map<String, dynamic>))
          .toList();

      final newTransfer = StockTransferModel(
        id: 'trans-${++_idCounter}',
        brandId: brandId,
        referenceNo: data['referenceNo'] as String? ?? 'TR-${DateTime.now().year}-${_idCounter}',
        fromWarehouseId: data['fromWarehouseId'] as String,
        fromWarehouseName: data['fromWarehouseName'] as String,
        toWarehouseId: data['toWarehouseId'] as String,
        toWarehouseName: data['toWarehouseName'] as String,
        items: parsedItems,
        status: data['status'] as String? ?? 'Completed',
        transferDate: data['transferDate'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        notes: data['notes'] as String?,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // (Note: In a local-first system with multi-warehouse tables, this would subtract
      // fromWarehouse balance and add toWarehouse balance of specific items. Since item details
      // represent global balances currently, the net sum remains identical. We log the audit transfer.)

      _store.add(newTransfer);
      return newTransfer;
    });
  }
}
