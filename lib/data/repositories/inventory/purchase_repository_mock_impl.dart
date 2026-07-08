import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/inventory/purchase_model.dart';
import 'package:back_office/data/repositories/inventory/purchase_repository.dart';
import 'package:back_office/data/repositories/inventory/item_repository_mock_impl.dart';
import 'package:back_office/utils/utils.dart';

class PurchaseRepositoryMockImpl implements PurchaseRepository {
  static final List<PurchaseModel> _store = [
    PurchaseModel(
      id: 'pur-1',
      brandId: 'mock-brand',
      referenceNo: 'PO-2026-001',
      supplierId: 'supp-1',
      supplierName: 'Metro Cash & Carry',
      warehouseId: 'wh-3',
      warehouseName: 'Dry Store',
      items: const [
        PurchaseItem(
          itemId: 'item-1',
          itemName: 'Basmati Rice',
          unitCode: 'kg',
          quantity: 100.0,
          costPrice: 120.0,
          total: 12000.0,
        ),
        PurchaseItem(
          itemId: 'item-3',
          itemName: 'Olive Oil',
          unitCode: 'L',
          quantity: 10.0,
          costPrice: 450.0,
          total: 4500.0,
        ),
      ],
      subTotal: 16500.0,
      taxAmount: 825.0,
      discountAmount: 325.0,
      totalAmount: 17000.0,
      paymentStatus: 'Paid',
      notes: 'Initial stock load',
      purchaseDate: 1700000000000,
      createdAt: 1700000000000,
    ),
    PurchaseModel(
      id: 'pur-2',
      brandId: 'mock-brand',
      referenceNo: 'PO-2026-002',
      supplierId: 'supp-2',
      supplierName: 'Supreme Dairy Products',
      warehouseId: 'wh-2',
      warehouseName: 'Cold Storage',
      items: const [
        PurchaseItem(
          itemId: 'item-4',
          itemName: 'Mozzarella Cheese',
          unitCode: 'kg',
          quantity: 5.0,
          costPrice: 600.0,
          total: 3000.0,
        ),
      ],
      subTotal: 3000.0,
      taxAmount: 150.0,
      discountAmount: 0.0,
      totalAmount: 3150.0,
      paymentStatus: 'Partial',
      notes: 'Weekly cheese stock-in',
      purchaseDate: 1700000005000,
      createdAt: 1700000005000,
    ),
  ];

  static int _idCounter = 100;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 300));

  @override
  FutureEither<ListResponse<PurchaseModel>> getPurchases(
    String brandId, {
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    return runTask(() async {
      await _delay();
      var results = _store.toList();

      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        results = results
            .where((p) =>
                p.referenceNo.toLowerCase().contains(q) ||
                p.supplierName.toLowerCase().contains(q) ||
                p.warehouseName.toLowerCase().contains(q))
            .toList();
      }

      return ListResponse<PurchaseModel>(
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
  FutureEither<PurchaseModel> getPurchase(
    String brandId,
    String purchaseId,
  ) async {
    return runTask(() async {
      await _delay();
      return _store.firstWhere(
        (p) => p.id == purchaseId,
        orElse: () => throw Exception('Purchase not found'),
      );
    });
  }

  @override
  FutureEither<PurchaseModel> createPurchase(
    String brandId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      await _delay();
      final itemsRaw = data['items'] as List<dynamic>;
      final parsedItems = itemsRaw
          .map((i) => PurchaseItem.fromJson(i as Map<String, dynamic>))
          .toList();

      final newPurchase = PurchaseModel(
        id: 'pur-${++_idCounter}',
        brandId: brandId,
        referenceNo: data['referenceNo'] as String? ?? 'PO-${DateTime.now().year}-${_idCounter}',
        supplierId: data['supplierId'] as String,
        supplierName: data['supplierName'] as String,
        warehouseId: data['warehouseId'] as String,
        warehouseName: data['warehouseName'] as String,
        items: parsedItems,
        subTotal: (data['subTotal'] as num?)?.toDouble() ?? 0.0,
        taxAmount: (data['taxAmount'] as num?)?.toDouble() ?? 0.0,
        discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (data['totalAmount'] as num).toDouble(),
        paymentStatus: data['paymentStatus'] as String? ?? 'Paid',
        notes: data['notes'] as String?,
        purchaseDate: data['purchaseDate'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Perform stock mutation: Add to currentStock of each item
      for (final item in parsedItems) {
        ItemRepositoryMockImpl.adjustStock(item.itemId, item.quantity);
      }

      _store.add(newPurchase);
      return newPurchase;
    });
  }
}
