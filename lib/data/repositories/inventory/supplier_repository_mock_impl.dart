import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/inventory/supplier_model.dart';
import 'package:back_office/data/repositories/inventory/supplier_repository.dart';
import 'package:back_office/utils/utils.dart';

class SupplierRepositoryMockImpl implements SupplierRepository {
  static final List<SupplierModel> _store = [
    SupplierModel(
      id: 'supp-1',
      brandId: 'mock-brand',
      name: 'Metro Cash & Carry',
      contactPerson: 'Rahul Sharma',
      email: 'rahul.metro@example.com',
      phone: '+91 98765 43210',
      address: 'Plot 23, Industrial Area Phase 1, Chandigarh',
      openingBalance: 15000.0,
      currentBalance: 8500.0,
      isActive: true,
      createdAt: 1700000000000,
    ),
    SupplierModel(
      id: 'supp-2',
      brandId: 'mock-brand',
      name: 'Supreme Dairy Products',
      contactPerson: 'Gurpreet Singh',
      email: 'sales@supremedairy.com',
      phone: '+91 98765 88990',
      address: 'SCF 14, Sector 26, Chandigarh',
      openingBalance: 0.0,
      currentBalance: 4200.0,
      isActive: true,
      createdAt: 1700000001000,
    ),
    SupplierModel(
      id: 'supp-3',
      brandId: 'mock-brand',
      name: 'Fresh Farms Vegetables',
      contactPerson: 'Amit Patel',
      email: 'amit.freshfarms@example.com',
      phone: '+91 76543 21098',
      address: 'Sabzi Mandi, Sector 26, Chandigarh',
      openingBalance: 2000.0,
      currentBalance: 0.0,
      isActive: true,
      createdAt: 1700000002000,
    ),
    SupplierModel(
      id: 'supp-4',
      brandId: 'mock-brand',
      name: 'Reliable Packaging Supplies',
      contactPerson: 'Vijay Kapoor',
      email: 'contact@reliablepack.com',
      phone: '+91 88990 11223',
      address: 'Phase 2 Industrial Area, Panchkula',
      openingBalance: 5000.0,
      currentBalance: 5000.0,
      isActive: false,
      createdAt: 1700000003000,
    ),
  ];

  static int _idCounter = 100;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 300));

  @override
  FutureEither<ListResponse<SupplierModel>> getSuppliers(
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
            .where((s) =>
                s.name.toLowerCase().contains(q) ||
                (s.contactPerson?.toLowerCase().contains(q) ?? false) ||
                (s.phone?.toLowerCase().contains(q) ?? false))
            .toList();
      }

      return ListResponse<SupplierModel>(
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
  FutureEither<SupplierModel> getSupplier(
    String brandId,
    String supplierId,
  ) async {
    return runTask(() async {
      await _delay();
      return _store.firstWhere(
        (s) => s.id == supplierId,
        orElse: () => throw Exception('Supplier not found'),
      );
    });
  }

  @override
  FutureEither<SupplierModel> createSupplier(
    String brandId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      await _delay();
      final newSupp = SupplierModel(
        id: 'supp-${++_idCounter}',
        brandId: brandId,
        name: data['name'] as String,
        contactPerson: data['contactPerson'] as String?,
        email: data['email'] as String?,
        phone: data['phone'] as String?,
        address: data['address'] as String?,
        openingBalance: (data['openingBalance'] as num?)?.toDouble() ?? 0.0,
        currentBalance: (data['openingBalance'] as num?)?.toDouble() ?? 0.0,
        isActive: data['isActive'] as bool? ?? true,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      _store.add(newSupp);
      return newSupp;
    });
  }

  @override
  FutureEither<SupplierModel> updateSupplier(
    String brandId,
    String supplierId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      await _delay();
      final idx = _store.indexWhere((s) => s.id == supplierId);
      if (idx == -1) throw Exception('Supplier not found');
      final updated = _store[idx].copyWith(
        name: data['name'] as String?,
        contactPerson: data['contactPerson'] as String?,
        email: data['email'] as String?,
        phone: data['phone'] as String?,
        address: data['address'] as String?,
        isActive: data['isActive'] as bool?,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      _store[idx] = updated;
      return updated;
    });
  }

  @override
  FutureEither<void> deleteSupplier(String brandId, String supplierId) async {
    return runTask(() async {
      await _delay();
      _store.removeWhere((s) => s.id == supplierId);
    });
  }
}
