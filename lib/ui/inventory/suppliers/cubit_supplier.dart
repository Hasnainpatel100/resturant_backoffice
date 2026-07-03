import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/inventory/supplier_repository.dart';
import 'state_supplier.dart';

class CubitSupplier extends Cubit<StateSupplier> {
  final SupplierRepository _repository;

  CubitSupplier({required SupplierRepository repository})
      : _repository = repository,
        super(const StateSupplier());

  Future<void> loadSuppliers(String brandId, {String? search}) async {
    emit(state.copyWith(status: SupplierStatus.loading));
    final result = await _repository.getSuppliers(brandId, search: search);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SupplierStatus.error,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: SupplierStatus.loaded,
        suppliers: response.items,
        meta: response.meta,
      )),
    );
  }

  Future<void> loadSupplier(String brandId, String supplierId) async {
    emit(state.copyWith(status: SupplierStatus.loading));
    final result = await _repository.getSupplier(brandId, supplierId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SupplierStatus.error,
        errorMessage: failure.message,
      )),
      (supplier) => emit(state.copyWith(
        status: SupplierStatus.loaded,
        selected: supplier,
      )),
    );
  }

  Future<void> createSupplier(String brandId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: SupplierStatus.loading));
    final result = await _repository.createSupplier(brandId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SupplierStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: SupplierStatus.success)),
    );
  }

  Future<void> updateSupplier(
    String brandId,
    String supplierId,
    Map<String, dynamic> data,
  ) async {
    emit(state.copyWith(status: SupplierStatus.loading));
    final result = await _repository.updateSupplier(brandId, supplierId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SupplierStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: SupplierStatus.success)),
    );
  }

  Future<void> deleteSupplier(String brandId, String supplierId) async {
    emit(state.copyWith(status: SupplierStatus.loading));
    final result = await _repository.deleteSupplier(brandId, supplierId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SupplierStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: SupplierStatus.success)),
    );
  }
}
