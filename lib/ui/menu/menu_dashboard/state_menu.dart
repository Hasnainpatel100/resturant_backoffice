import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/menu_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/room_type_model.dart';

enum MenuStatus { initial, loading, loaded, error }

/// Tracks which category-level operation just completed,
/// so the UI can show targeted feedback without a full reload.
enum CategoryOperation { none, created, updated, deleted }

class StateMenu extends Equatable {
  final MenuStatus status;
  final List<CategoryModel> categories;
  final List<MenuItemResponse> menuItems;
  final List<RoomTypeModel> roomTypes;       // ← for room-price dropdowns
  final String? selectedCategoryId;
  final MetaData? meta;
  final String? errorMessage;

  /// The last category operation that completed successfully.
  final CategoryOperation categoryOperation;

  /// The id of the category that was last mutated (updated / deleted).
  final String? lastMutatedCategoryId;

  const StateMenu({
    this.status = MenuStatus.initial,
    this.categories = const [],
    this.menuItems = const [],
    this.roomTypes = const [],
    this.selectedCategoryId,
    this.meta,
    this.errorMessage,
    this.categoryOperation = CategoryOperation.none,
    this.lastMutatedCategoryId,
  });

  StateMenu copyWith({
    MenuStatus? status,
    List<CategoryModel>? categories,
    List<MenuItemResponse>? menuItems,
    List<RoomTypeModel>? roomTypes,
    String? selectedCategoryId,
    MetaData? meta,
    String? errorMessage,
    CategoryOperation? categoryOperation,
    String? lastMutatedCategoryId,
  }) {
    return StateMenu(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      menuItems: menuItems ?? this.menuItems,
      roomTypes: roomTypes ?? this.roomTypes,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
      categoryOperation: categoryOperation ?? this.categoryOperation,
      lastMutatedCategoryId:
          lastMutatedCategoryId ?? this.lastMutatedCategoryId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        menuItems,
        roomTypes,
        selectedCategoryId,
        meta,
        errorMessage,
        categoryOperation,
        lastMutatedCategoryId,
      ];
}
