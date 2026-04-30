import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/table_repository.dart';
import 'state_table.dart';

class CubitTable extends Cubit<StateTable> {
  final TableRepository _repository;

  CubitTable({required TableRepository repository})
      : _repository = repository,
        super(const StateTable());

  Future<void> loadTables(String brandId, String branchId, {String? status}) async {
    emit(state.copyWith(status: StateTableStatus.loading));
    final result = await _repository.getTables(brandId, branchId, status: status);
    result.fold(
      (failure) => emit(state.copyWith(status: StateTableStatus.error, errorMessage: failure.message)),
      (response) => emit(state.copyWith(
        status: StateTableStatus.loaded,
        tables: response.items,
        meta: response.meta,
      )),
    );
  }

  Future<void> createTables(String brandId, List<Map<String, dynamic>> data) async {
    emit(state.copyWith(status: StateTableStatus.loading));
    final result = await _repository.createTables(brandId, data);
    result.fold(
      (failure) => emit(state.copyWith(status: StateTableStatus.error, errorMessage: failure.message)),
      (response) => emit(state.copyWith(
        status: StateTableStatus.loaded,
        tables: [...state.tables, ...response.items],
        meta: response.meta,
      )),
    );
  }

  Future<void> updateTable(String tableId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: StateTableStatus.loading));
    final result = await _repository.updateTable(tableId, data);
    result.fold(
      (failure) => emit(state.copyWith(status: StateTableStatus.error, errorMessage: failure.message)),
      (table) {
        final updated = state.tables.map((t) => t.id == table.id ? table : t).toList();
        emit(state.copyWith(status: StateTableStatus.loaded, tables: updated));
      },
    );
  }

  Future<void> deleteTable(String tableId) async {
    emit(state.copyWith(status: StateTableStatus.loading));
    final result = await _repository.deleteTable(tableId);
    result.fold(
      (failure) => emit(state.copyWith(status: StateTableStatus.error, errorMessage: failure.message)),
      (_) {
        final updated = state.tables.where((t) => t.id != tableId).toList();
        emit(state.copyWith(status: StateTableStatus.loaded, tables: updated));
      },
    );
  }

  Future<void> loadRoomTypes(String brandId, String branchId) async {
    emit(state.copyWith(status: StateTableStatus.loading));
    final result = await _repository.getRoomTypes(brandId, branchId);
    result.fold(
      (failure) => emit(state.copyWith(status: StateTableStatus.error, errorMessage: failure.message)),
      (response) => emit(state.copyWith(
        status: StateTableStatus.loaded,
        roomTypes: response.items,
        meta: response.meta,
      )),
    );
  }

  Future<void> createRoomTypes(String brandId, List<Map<String, dynamic>> data) async {
    emit(state.copyWith(status: StateTableStatus.loading));
    final result = await _repository.createRoomTypes(brandId, data);
    result.fold(
      (failure) => emit(state.copyWith(status: StateTableStatus.error, errorMessage: failure.message)),
      (response) => emit(state.copyWith(
        status: StateTableStatus.loaded,
        roomTypes: [...state.roomTypes, ...response.items],
        meta: response.meta,
      )),
    );
  }

  Future<void> updateRoomType(String roomTypeId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: StateTableStatus.loading));
    final result = await _repository.updateRoomType(roomTypeId, data);
    result.fold(
      (failure) => emit(state.copyWith(status: StateTableStatus.error, errorMessage: failure.message)),
      (roomType) {
        final updated = state.roomTypes.map((r) => r.id == roomType.id ? roomType : r).toList();
        emit(state.copyWith(status: StateTableStatus.loaded, roomTypes: updated));
      },
    );
  }

  Future<void> deleteRoomType(String roomTypeId) async {
    emit(state.copyWith(status: StateTableStatus.loading));
    final result = await _repository.deleteRoomType(roomTypeId);
    result.fold(
      (failure) => emit(state.copyWith(status: StateTableStatus.error, errorMessage: failure.message)),
      (_) {
        final updated = state.roomTypes.where((r) => r.id != roomTypeId).toList();
        emit(state.copyWith(status: StateTableStatus.loaded, roomTypes: updated));
      },
    );
  }
}