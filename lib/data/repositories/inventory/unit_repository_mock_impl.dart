import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/inventory/unit_model.dart';
import 'package:back_office/data/repositories/inventory/unit_repository.dart';
import 'package:back_office/utils/utils.dart';

/// In-memory mock implementation of [UnitRepository].
/// Replace with a real API implementation when the backend is ready.
class UnitRepositoryMockImpl implements UnitRepository {
  // ── Seed data ────────────────────────────────────────────────────────────
  static final List<UnitModel> _store = [
    UnitModel(
      id: 'unit-1',
      brandId: 'mock-brand',
      name: 'Kilogram',
      code: 'kg',
      isActive: true,
      createdAt: 1700000000000,
    ),
    UnitModel(
      id: 'unit-2',
      brandId: 'mock-brand',
      name: 'Gram',
      code: 'g',
      isActive: true,
      createdAt: 1700000001000,
    ),
    UnitModel(
      id: 'unit-3',
      brandId: 'mock-brand',
      name: 'Litre',
      code: 'L',
      isActive: true,
      createdAt: 1700000002000,
    ),
    UnitModel(
      id: 'unit-4',
      brandId: 'mock-brand',
      name: 'Millilitre',
      code: 'mL',
      isActive: true,
      createdAt: 1700000003000,
    ),
    UnitModel(
      id: 'unit-5',
      brandId: 'mock-brand',
      name: 'Piece',
      code: 'pc',
      isActive: true,
      createdAt: 1700000004000,
    ),
    UnitModel(
      id: 'unit-6',
      brandId: 'mock-brand',
      name: 'Box',
      code: 'box',
      isActive: true,
      createdAt: 1700000005000,
    ),
    UnitModel(
      id: 'unit-7',
      brandId: 'mock-brand',
      name: 'Dozen',
      code: 'doz',
      isActive: true,
      createdAt: 1700000006000,
    ),
    UnitModel(
      id: 'unit-8',
      brandId: 'mock-brand',
      name: 'Packet',
      code: 'pkt',
      isActive: false,
      createdAt: 1700000007000,
    ),
  ];

  static int _idCounter = 100;

  Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 300));

  @override
  FutureEither<ListResponse<UnitModel>> getUnits(
    String brandId, {
    int page = 1,
    int limit = 50,
  }) async {
    return runTask(() async {
      await _delay();
      return ListResponse<UnitModel>(
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
  FutureEither<UnitModel> getUnit(String brandId, String unitId) async {
    return runTask(() async {
      await _delay();
      return _store.firstWhere(
        (u) => u.id == unitId,
        orElse: () => throw Exception('Unit not found'),
      );
    });
  }

  @override
  FutureEither<UnitModel> createUnit(
    String brandId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      await _delay();
      final newUnit = UnitModel(
        id: 'unit-${++_idCounter}',
        brandId: brandId,
        name: data['name'] as String,
        code: data['code'] as String,
        isActive: data['isActive'] as bool? ?? true,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      _store.add(newUnit);
      return newUnit;
    });
  }

  @override
  FutureEither<UnitModel> updateUnit(
    String brandId,
    String unitId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      await _delay();
      final idx = _store.indexWhere((u) => u.id == unitId);
      if (idx == -1) throw Exception('Unit not found');
      final updated = _store[idx].copyWith(
        name: data['name'] as String?,
        code: data['code'] as String?,
        isActive: data['isActive'] as bool?,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      _store[idx] = updated;
      return updated;
    });
  }

  @override
  FutureEither<void> deleteUnit(String brandId, String unitId) async {
    return runTask(() async {
      await _delay();
      _store.removeWhere((u) => u.id == unitId);
    });
  }
}
