import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/inventory/item_repository.dart';
import 'package:back_office/data/repositories/inventory/category_repository.dart';
import 'package:back_office/data/repositories/inventory/unit_repository.dart';
import 'state_item.dart';

class CubitItem extends Cubit<StateItem> {
  final ItemRepository _itemRepository;
  final CategoryRepository _categoryRepository;
  final UnitRepository _unitRepository;

  CubitItem({
    required ItemRepository itemRepository,
    required CategoryRepository categoryRepository,
    required UnitRepository unitRepository,
  })  : _itemRepository = itemRepository,
        _categoryRepository = categoryRepository,
        _unitRepository = unitRepository,
        super(const StateItem());

  /// Load items list + categories + units in parallel.
  Future<void> loadAll(
    String brandId, {
    String? search,
    String? categoryId,
  }) async {
    emit(state.copyWith(status: ItemStatus.loading));

    // Load supporting dropdown data
    final catResult = await _categoryRepository.getCategories(brandId);
    final unitResult = await _unitRepository.getUnits(brandId);
    final itemResult = await _itemRepository.getItems(
      brandId,
      search: search,
      categoryId: categoryId,
    );

    itemResult.fold(
      (failure) => emit(state.copyWith(
        status: ItemStatus.error,
        errorMessage: failure.message,
      )),
      (response) {
        emit(state.copyWith(
          status: ItemStatus.loaded,
          items: response.items,
          meta: response.meta,
          categories: catResult.fold((_) => state.categories, (r) => r.items),
          units: unitResult.fold((_) => state.units, (r) => r.items),
        ));
      },
    );
  }

  Future<void> loadItem(String brandId, String itemId) async {
    emit(state.copyWith(status: ItemStatus.loading));
    final result = await _itemRepository.getItem(brandId, itemId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ItemStatus.error,
        errorMessage: failure.message,
      )),
      (item) => emit(state.copyWith(
        status: ItemStatus.loaded,
        selected: item,
      )),
    );
  }

  Future<void> loadDropdowns(String brandId) async {
    final catResult = await _categoryRepository.getCategories(brandId);
    final unitResult = await _unitRepository.getUnits(brandId);
    emit(state.copyWith(
      categories: catResult.fold((_) => [], (r) => r.items),
      units: unitResult.fold((_) => [], (r) => r.items),
    ));
  }

  Future<void> createItem(String brandId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: ItemStatus.loading));
    final result = await _itemRepository.createItem(brandId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ItemStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: ItemStatus.success)),
    );
  }

  Future<void> updateItem(
    String brandId,
    String itemId,
    Map<String, dynamic> data,
  ) async {
    emit(state.copyWith(status: ItemStatus.loading));
    final result = await _itemRepository.updateItem(brandId, itemId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ItemStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: ItemStatus.success)),
    );
  }

  Future<void> deleteItem(String brandId, String itemId) async {
    emit(state.copyWith(status: ItemStatus.loading));
    final result = await _itemRepository.deleteItem(brandId, itemId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ItemStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: ItemStatus.success)),
    );
  }
}
