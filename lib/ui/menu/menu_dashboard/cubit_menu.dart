import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/menu_repository.dart';
import 'state_menu.dart';

class CubitMenu extends Cubit<StateMenu> {
  final MenuRepository _repository;

  CubitMenu({required MenuRepository repository})
      : _repository = repository,
        super(const StateMenu());

  // ─────────────────────────────────────────────
  // CATEGORIES
  // ─────────────────────────────────────────────

  Future<void> loadCategories(
      String brandId,
      String branchId, {
        int page = 1,
        int limit = 20,
      }) async {
    emit(state.copyWith(status: MenuStatus.loading));
    final result = await _repository.getCategories(
      brandId,
      branchId,
      page: page,
      limit: limit,
    );
    result.fold(
          (failure) => emit(
        state.copyWith(
          status: MenuStatus.error,
          errorMessage: failure.message,
        ),
      ),
          (response) => emit(
        state.copyWith(
          status: MenuStatus.loaded,
          categories: response.items,
          meta: response.meta,
          categoryOperation: CategoryOperation.none,
        ),
      ),
    );
  }

  Future<void> createCategories(
      String brandId,
      List<Map<String, dynamic>> data,
      ) async {
    emit(state.copyWith(status: MenuStatus.loading));
    final result = await _repository.createCategories(brandId, data);
    result.fold(
          (failure) => emit(
        state.copyWith(
          status: MenuStatus.error,
          errorMessage: failure.message,
        ),
      ),
          (response) => emit(
        state.copyWith(
          status: MenuStatus.loaded,
          categories: [...state.categories, ...response.items],
          meta: response.meta,
          categoryOperation: CategoryOperation.created,
        ),
      ),
    );
  }

  /// PUT /api/menu/categories/{categoryId}
  ///
  /// [data] may contain any subset of:
  ///   { "name": "...", "displayOrder": 1, "imageUrl": "https://..." }
  Future<void> updateCategory(
      String brandId,
      String categoryId,
      Map<String, dynamic> data,
      ) async {
    emit(state.copyWith(status: MenuStatus.loading));
    final result = await _repository.updateCategory(brandId,categoryId,data);
    result.fold(
          (failure) => emit(
        state.copyWith(
          status: MenuStatus.error,
          errorMessage: failure.message,
        ),
      ),
          (updated) {
        final updatedList = state.categories
            .map((c) => c.id == updated.id ? updated : c)
            .toList();
        emit(
          state.copyWith(
            status: MenuStatus.loaded,
            categories: updatedList,
            categoryOperation: CategoryOperation.updated,
            lastMutatedCategoryId: categoryId,
          ),
        );
      },
    );
  }

  Future<void> deleteCategory(
      String brandId,
      String categoryId,
      ) async {

    emit(state.copyWith(status: MenuStatus.loading));

    final result = await _repository.deleteCategory(
      brandId,
      categoryId,
    );

    result.fold(
          (failure) => emit(
        state.copyWith(
          status: MenuStatus.error,
          errorMessage: failure.message,
        ),
      ),

          (_) {
        final updatedList =
        state.categories
            .where((c) => c.id != categoryId)
            .toList();

        emit(
          state.copyWith(
            status: MenuStatus.loaded,
            categories: updatedList,
            categoryOperation: CategoryOperation.deleted,
            lastMutatedCategoryId: categoryId,
          ),
        );
      },
    );
  }
  // ─────────────────────────────────────────────
  // MENU ITEMS
  // ─────────────────────────────────────────────

  Future<void> loadMenuItems(
      String brandId,
      String branchId, {
        String? categoryId,
        int page = 1,
        int limit = 20,
      }) async {
    emit(
      state.copyWith(
        status: MenuStatus.loading,
        selectedCategoryId: categoryId,
      ),
    );
    final result = await _repository.getMenuItems(
      brandId,
      branchId,
      categoryId: categoryId,
      page: page,
      limit: limit,
    );
    result.fold(
          (failure) => emit(
        state.copyWith(
          status: MenuStatus.error,
          errorMessage: failure.message,
        ),
      ),
          (response) => emit(
        state.copyWith(
          status: MenuStatus.loaded,
          menuItems: response.items,
          meta: response.meta,
        ),
      ),
    );
  }

  Future<void> createMenuItems(
      String brandId,
      List<Map<String, dynamic>> data,
      ) async {
    emit(state.copyWith(status: MenuStatus.loading));
    final result = await _repository.createMenuItems(brandId, data);
    result.fold(
          (failure) => emit(
        state.copyWith(
          status: MenuStatus.error,
          errorMessage: failure.message,
        ),
      ),
          (response) => emit(
        state.copyWith(
          status: MenuStatus.loaded,
          menuItems: [...state.menuItems, ...response.items],
          meta: response.meta,
        ),
      ),
    );
  }

  Future<void> updateMenuItem(
      String itemId,
      Map<String, dynamic> data,
      ) async {
    emit(state.copyWith(status: MenuStatus.loading));
    final result = await _repository.updateMenuItem(itemId, data);
    result.fold(
          (failure) => emit(
        state.copyWith(
          status: MenuStatus.error,
          errorMessage: failure.message,
        ),
      ),
          (item) {
        final updated =
        state.menuItems.map((i) => i.id == item.id ? item : i).toList();
        emit(state.copyWith(status: MenuStatus.loaded, menuItems: updated));
      },
    );
  }

  Future<void> toggleMenuItemAvailability(
      String itemId,
      Map<String, dynamic> data,
      ) async {
    emit(state.copyWith(status: MenuStatus.loading));
    final result = await _repository.toggleAvailability(itemId, data);
    result.fold(
          (failure) => emit(
        state.copyWith(
          status: MenuStatus.error,
          errorMessage: failure.message,
        ),
      ),
          (item) {
        final updated =
        state.menuItems.map((i) => i.id == item.id ? item : i).toList();
        emit(state.copyWith(status: MenuStatus.loaded, menuItems: updated));
      },
    );
  }

  Future<void> deleteMenuItem(String itemId, String brandId) async {
    emit(state.copyWith(status: MenuStatus.loading));
    final result = await _repository.deleteMenuItem(itemId, brandId);
    result.fold(
          (failure) => emit(
        state.copyWith(
          status: MenuStatus.error,
          errorMessage: failure.message,
        ),
      ),
          (_) {
        final updated =
        state.menuItems.where((i) => i.id != itemId).toList();
        emit(state.copyWith(status: MenuStatus.loaded, menuItems: updated));
      },
    );
  }
}
