import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/inventory/purchase_repository.dart';
import 'package:back_office/data/repositories/inventory/supplier_repository.dart';
import 'package:back_office/data/repositories/inventory/warehouse_repository.dart';
import 'package:back_office/data/repositories/inventory/item_repository.dart';
import 'state_purchase.dart';

class CubitPurchase extends Cubit<StatePurchase> {
  final PurchaseRepository _purchaseRepository;
  final SupplierRepository _supplierRepository;
  final WarehouseRepository _warehouseRepository;
  final ItemRepository _itemRepository;

  CubitPurchase({
    required PurchaseRepository purchaseRepository,
    required SupplierRepository supplierRepository,
    required WarehouseRepository warehouseRepository,
    required ItemRepository itemRepository,
  })  : _purchaseRepository = purchaseRepository,
        _supplierRepository = supplierRepository,
        _warehouseRepository = warehouseRepository,
        _itemRepository = itemRepository,
        super(const StatePurchase());

  Future<void> loadPurchases(String brandId, {String? search}) async {
    emit(state.copyWith(status: PurchaseStatus.loading));
    final result = await _purchaseRepository.getPurchases(brandId, search: search);
    result.fold(
      (failure) => emit(state.copyWith(
        status: PurchaseStatus.error,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: PurchaseStatus.loaded,
        purchases: response.items,
        meta: response.meta,
      )),
    );
  }

  Future<void> loadPurchase(String brandId, String purchaseId) async {
    emit(state.copyWith(status: PurchaseStatus.loading));
    final result = await _purchaseRepository.getPurchase(brandId, purchaseId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: PurchaseStatus.error,
        errorMessage: failure.message,
      )),
      (purchase) => emit(state.copyWith(
        status: PurchaseStatus.loaded,
        selected: purchase,
      )),
    );
  }

  /// Loads all suppliers, warehouses, and items required for placing a new Stock-In purchase order.
  Future<void> loadFormDropdowns(String brandId) async {
    emit(state.copyWith(status: PurchaseStatus.loading));

    final supResult = await _supplierRepository.getSuppliers(brandId);
    final whResult = await _warehouseRepository.getWarehouses(brandId);
    final itemResult = await _itemRepository.getItems(brandId, limit: 100);

    supResult.fold(
      (failure) => emit(state.copyWith(
        status: PurchaseStatus.error,
        errorMessage: failure.message,
      )),
      (supResponse) {
        whResult.fold(
          (failure) => emit(state.copyWith(
            status: PurchaseStatus.error,
            errorMessage: failure.message,
          )),
          (whResponse) {
            itemResult.fold(
              (failure) => emit(state.copyWith(
                status: PurchaseStatus.error,
                errorMessage: failure.message,
              )),
              (itemResponse) {
                emit(state.copyWith(
                  status: PurchaseStatus.loaded,
                  suppliers: supResponse.items,
                  warehouses: whResponse.items,
                  items: itemResponse.items,
                ));
              },
            );
          },
        );
      },
    );
  }

  Future<void> createPurchase(String brandId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: PurchaseStatus.loading));
    final result = await _purchaseRepository.createPurchase(brandId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: PurchaseStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: PurchaseStatus.success)),
    );
  }
}
