import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/inventory/warehouse_model.dart';
import 'package:back_office/data/repositories/inventory/warehouse_repository.dart';
import 'package:back_office/utils/utils.dart';

/// In-memory mock implementation of [WarehouseRepository].
/// Replace with a real API implementation when the backend is ready.
class WarehouseRepositoryMockImpl implements WarehouseRepository {
  // ── Seed data ────────────────────────────────────────────────────────────
  static final List<WarehouseModel> _store = [
    WarehouseModel(
      id: 'wh-1',
      brandId: 'mock-brand',
      name: 'Main Kitchen Store',
      address: 'Ground Floor, Kitchen Block',
      isActive: true,
      createdAt: 1700000000000,
    ),
    WarehouseModel(
      id: 'wh-2',
      brandId: 'mock-brand',
      name: 'Cold Storage',
      address: 'Basement, Cold Room A',
      isActive: true,
      createdAt: 1700000001000,
    ),
    WarehouseModel(
      id: 'wh-3',
      brandId: 'mock-brand',
      name: 'Dry Store',
      address: '1st Floor, Storage Room B',
      isActive: true,
      createdAt: 1700000002000,
    ),
    WarehouseModel(
      id: 'wh-4',
      brandId: 'mock-brand',
      name: 'Packaging Store',
      address: 'Loading Bay, Unit 4',
      isActive: false,
      createdAt: 1700000003000,
    ),
  ];

  static int _idCounter = 100;

  Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 300));

  @override
  FutureEither<ListResponse<WarehouseModel>> getWarehouses(
    String brandId, {
    int page = 1,
    int limit = 50,
  }) async {
    return runTask(() async {
      await _delay();
      return ListResponse<WarehouseModel>(
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
  FutureEither<WarehouseModel> getWarehouse(
    String brandId,
    String warehouseId,
  ) async {
    return runTask(() async {
      await _delay();
      return _store.firstWhere(
        (w) => w.id == warehouseId,
        orElse: () => throw Exception('Warehouse not found'),
      );
    });
  }

  @override
  FutureEither<WarehouseModel> createWarehouse(
    String brandId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      await _delay();
      final newWh = WarehouseModel(
        id: 'wh-${++_idCounter}',
        brandId: brandId,
        name: data['name'] as String,
        address: data['address'] as String?,
        isActive: data['isActive'] as bool? ?? true,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      _store.add(newWh);
      return newWh;
    });
  }

  @override
  FutureEither<WarehouseModel> updateWarehouse(
    String brandId,
    String warehouseId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      await _delay();
      final idx = _store.indexWhere((w) => w.id == warehouseId);
      if (idx == -1) throw Exception('Warehouse not found');
      final updated = _store[idx].copyWith(
        name: data['name'] as String?,
        address: data['address'] as String?,
        isActive: data['isActive'] as bool?,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      _store[idx] = updated;
      return updated;
    });
  }

  @override
  FutureEither<void> deleteWarehouse(
    String brandId,
    String warehouseId,
  ) async {
    return runTask(() async {
      await _delay();
      _store.removeWhere((w) => w.id == warehouseId);
    });
  }
}
