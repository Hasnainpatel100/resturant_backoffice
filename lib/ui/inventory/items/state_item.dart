import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/inventory/item_model.dart';
import 'package:back_office/data/models/inventory/inventory_category_model.dart';
import 'package:back_office/data/models/inventory/unit_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum ItemStatus { initial, loading, loaded, success, error }

class StateItem extends Equatable {
  final ItemStatus status;
  final List<ItemModel> items;
  final ItemModel? selected;
  final MetaData? meta;
  final String? errorMessage;

  // Dropdown data loaded alongside items
  final List<InventoryCategoryModel> categories;
  final List<UnitModel> units;

  const StateItem({
    this.status = ItemStatus.initial,
    this.items = const [],
    this.selected,
    this.meta,
    this.errorMessage,
    this.categories = const [],
    this.units = const [],
  });

  StateItem copyWith({
    ItemStatus? status,
    List<ItemModel>? items,
    ItemModel? selected,
    MetaData? meta,
    String? errorMessage,
    List<InventoryCategoryModel>? categories,
    List<UnitModel>? units,
  }) {
    return StateItem(
      status: status ?? this.status,
      items: items ?? this.items,
      selected: selected ?? this.selected,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
      categories: categories ?? this.categories,
      units: units ?? this.units,
    );
  }

  @override
  List<Object?> get props =>
      [status, items, selected, meta, errorMessage, categories, units];
}
