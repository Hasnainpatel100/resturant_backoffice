import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/inventory/category_repository.dart';
import 'state_category.dart';

class CubitCategory extends Cubit<StateCategory> {
  final CategoryRepository _repository;

  CubitCategory({required CategoryRepository repository})
      : _repository = repository,
        super(const StateCategory());

  Future<void> loadCategories(String brandId) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    final result = await _repository.getCategories(brandId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: CategoryStatus.loaded,
        categories: response.items,
        meta: response.meta,
      )),
    );
  }

  Future<void> loadCategory(String brandId, String categoryId) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    final result = await _repository.getCategory(brandId, categoryId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: failure.message,
      )),
      (cat) => emit(state.copyWith(
        status: CategoryStatus.loaded,
        selected: cat,
      )),
    );
  }

  Future<void> createCategory(
    String brandId,
    Map<String, dynamic> data,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    final result = await _repository.createCategory(brandId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: CategoryStatus.success)),
    );
  }

  Future<void> updateCategory(
    String brandId,
    String categoryId,
    Map<String, dynamic> data,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    final result = await _repository.updateCategory(brandId, categoryId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: CategoryStatus.success)),
    );
  }

  Future<void> deleteCategory(String brandId, String categoryId) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    final result = await _repository.deleteCategory(brandId, categoryId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: CategoryStatus.success)),
    );
  }
}
