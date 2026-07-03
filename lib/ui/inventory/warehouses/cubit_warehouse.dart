import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/inventory/warehouse_repository.dart';
import 'state_warehouse.dart';

class CubitWarehouse extends Cubit<StateWarehouse> {
  final WarehouseRepository _repository;

  CubitWarehouse({required WarehouseRepository repository})
      : _repository = repository,
        super(const StateWarehouse());

  Future<void> loadWarehouses(String brandId) async {
    emit(state.copyWith(status: WarehouseStatus.loading));
    final result = await _repository.getWarehouses(brandId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: WarehouseStatus.error,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: WarehouseStatus.loaded,
        warehouses: response.items,
        meta: response.meta,
      )),
    );
  }

  Future<void> loadWarehouse(String brandId, String warehouseId) async {
    emit(state.copyWith(status: WarehouseStatus.loading));
    final result = await _repository.getWarehouse(brandId, warehouseId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: WarehouseStatus.error,
        errorMessage: failure.message,
      )),
      (wh) => emit(state.copyWith(
        status: WarehouseStatus.loaded,
        selected: wh,
      )),
    );
  }

  Future<void> createWarehouse(
    String brandId,
    Map<String, dynamic> data,
  ) async {
    emit(state.copyWith(status: WarehouseStatus.loading));
    final result = await _repository.createWarehouse(brandId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: WarehouseStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: WarehouseStatus.success)),
    );
  }

  Future<void> updateWarehouse(
    String brandId,
    String warehouseId,
    Map<String, dynamic> data,
  ) async {
    emit(state.copyWith(status: WarehouseStatus.loading));
    final result =
        await _repository.updateWarehouse(brandId, warehouseId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: WarehouseStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: WarehouseStatus.success)),
    );
  }

  Future<void> deleteWarehouse(String brandId, String warehouseId) async {
    emit(state.copyWith(status: WarehouseStatus.loading));
    final result = await _repository.deleteWarehouse(brandId, warehouseId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: WarehouseStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: WarehouseStatus.success)),
    );
  }
}
