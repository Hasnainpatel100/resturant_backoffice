import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/inventory/inventory_category_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum CategoryStatus { initial, loading, loaded, success, error }

class StateCategory extends Equatable {
  final CategoryStatus status;
  final List<InventoryCategoryModel> categories;
  final InventoryCategoryModel? selected;
  final MetaData? meta;
  final String? errorMessage;

  const StateCategory({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.selected,
    this.meta,
    this.errorMessage,
  });

  StateCategory copyWith({
    CategoryStatus? status,
    List<InventoryCategoryModel>? categories,
    InventoryCategoryModel? selected,
    MetaData? meta,
    String? errorMessage,
  }) {
    return StateCategory(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      selected: selected ?? this.selected,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, categories, selected, meta, errorMessage];
}
