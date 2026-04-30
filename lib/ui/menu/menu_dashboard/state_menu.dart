import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/menu_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum MenuStatus { initial, loading, loaded, error }

class StateMenu extends Equatable {
  final MenuStatus status;
  final List<CategoryModel> categories;
  final List<MenuItemResponse> menuItems;
  final String? selectedCategoryId;
  final MetaData? meta;
  final String? errorMessage;

  const StateMenu({
    this.status = MenuStatus.initial,
    this.categories = const [],
    this.menuItems = const [],
    this.selectedCategoryId,
    this.meta,
    this.errorMessage,
  });

  StateMenu copyWith({
    MenuStatus? status,
    List<CategoryModel>? categories,
    List<MenuItemResponse>? menuItems,
    String? selectedCategoryId,
    MetaData? meta,
    String? errorMessage,
  }) {
    return StateMenu(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      menuItems: menuItems ?? this.menuItems,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, categories, menuItems, selectedCategoryId, meta, errorMessage];
}