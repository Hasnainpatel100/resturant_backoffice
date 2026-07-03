import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/inventory/unit_repository.dart';
import 'state_unit.dart';

class CubitUnit extends Cubit<StateUnit> {
  final UnitRepository _repository;

  CubitUnit({required UnitRepository repository})
      : _repository = repository,
        super(const StateUnit());

  Future<void> loadUnits(String brandId) async {
    emit(state.copyWith(status: UnitStatus.loading));
    final result = await _repository.getUnits(brandId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: UnitStatus.error,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: UnitStatus.loaded,
        units: response.items,
        meta: response.meta,
      )),
    );
  }

  Future<void> loadUnit(String brandId, String unitId) async {
    emit(state.copyWith(status: UnitStatus.loading));
    final result = await _repository.getUnit(brandId, unitId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: UnitStatus.error,
        errorMessage: failure.message,
      )),
      (unit) => emit(state.copyWith(
        status: UnitStatus.loaded,
        selected: unit,
      )),
    );
  }

  Future<void> createUnit(String brandId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: UnitStatus.loading));
    final result = await _repository.createUnit(brandId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: UnitStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: UnitStatus.success)),
    );
  }

  Future<void> updateUnit(
    String brandId,
    String unitId,
    Map<String, dynamic> data,
  ) async {
    emit(state.copyWith(status: UnitStatus.loading));
    final result = await _repository.updateUnit(brandId, unitId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: UnitStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: UnitStatus.success)),
    );
  }

  Future<void> deleteUnit(String brandId, String unitId) async {
    emit(state.copyWith(status: UnitStatus.loading));
    final result = await _repository.deleteUnit(brandId, unitId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: UnitStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: UnitStatus.success)),
    );
  }
}
