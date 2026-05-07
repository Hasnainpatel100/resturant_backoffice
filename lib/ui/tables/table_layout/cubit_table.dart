import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/table_repository.dart';
import 'state_table.dart';

class CubitTable extends Cubit<StateTable> {
  final TableRepository _repository;

  // Cache brandId so delete/update can use it without the UI passing it again.
  String? _brandId;

  CubitTable({required TableRepository repository})
      : _repository = repository,
        super(const StateTable());

  Future<void> loadTables(String brandId, String branchId, {String? status}) async {
    _brandId = brandId;

    emit(state.copyWith(status: StateTableStatus.loading, errorMessage: null));
    final result = await _repository.getTables(brandId, branchId, status: status);
    result.fold(
          (failure) => emit(state.copyWith(
        status: StateTableStatus.error,
        errorMessage: failure.message,
      )),
          (response) => emit(state.copyWith(
        status: StateTableStatus.loaded,
        tables: response.items,
        meta: response.meta,
        errorMessage: null,     // ✅ FIX: Clear any prior error on success
      )),
    );
  }

  Future<void> createTables(String brandId, List<Map<String, dynamic>> data) async {
    emit(state.copyWith(status: StateTableStatus.loading, errorMessage: null));
    final result = await _repository.createTables(brandId, data);
    result.fold(
          (failure) => emit(state.copyWith(
        status: StateTableStatus.error,
        errorMessage: failure.message,
      )),
          (response) {
        // ✅ FIX: Append newly created tables to existing state list for instant UI update.
        // Original code used response.items but if ListResponse.fromJsonList wasn't returning
        // items correctly the list would be empty. With unified fromJson this now works.
        emit(state.copyWith(
          status: StateTableStatus.loaded,
          tables: [...state.tables, ...response.items],
          meta: response.meta,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> updateTable(String tableId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: StateTableStatus.loading, errorMessage: null));
    final result = await _repository.updateTable(tableId, data);
    result.fold(
          (failure) => emit(state.copyWith(
        status: StateTableStatus.error,
        errorMessage: failure.message,
      )),
          (updatedTable) {
        // ✅ NO CHANGE: Correct in-place replacement logic.
        final updated = state.tables
            .map((t) => t.id == updatedTable.id ? updatedTable : t)
            .toList();
        emit(state.copyWith(
          status: StateTableStatus.loaded,
          tables: updated,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> deleteTable(String tableId) async {
    if (_brandId == null) {
      emit(state.copyWith(
        status: StateTableStatus.error,
        errorMessage: 'Brand ID not set — call loadTables first',
      ));
      return;
    }
    emit(state.copyWith(status: StateTableStatus.loading, errorMessage: null));
    final result = await _repository.deleteTable(tableId, _brandId!);
    result.fold(
          (failure) => emit(state.copyWith(
        status: StateTableStatus.error,
        errorMessage: failure.message,
      )),
          (_) {
        final updated = state.tables.where((t) => t.id != tableId).toList();
        emit(state.copyWith(
          status: StateTableStatus.loaded,
          tables: updated,
          errorMessage: null,
        ));
      },
    );
  }
}
