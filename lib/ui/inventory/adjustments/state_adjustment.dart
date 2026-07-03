import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/inventory/stock_adjustment_model.dart';
import 'package:back_office/data/models/inventory/warehouse_model.dart';
import 'package:back_office/data/models/inventory/item_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum AdjustmentStatus { initial, loading, loaded, success, error }

class StateAdjustment extends Equatable {
  final AdjustmentStatus status;
  final List<StockAdjustmentModel> adjustments;
  final MetaData? meta;
  final String? errorMessage;

  final List<WarehouseModel> warehouses;
  final List<ItemModel> items;

  const StateAdjustment({
    this.status = AdjustmentStatus.initial,
    this.adjustments = const [],
    this.meta,
    this.errorMessage,
    this.warehouses = const [],
    this.items = const [],
  });

  StateAdjustment copyWith({
    AdjustmentStatus? status,
    List<StockAdjustmentModel>? adjustments,
    MetaData? meta,
    String? errorMessage,
    List<WarehouseModel>? warehouses,
    List<ItemModel>? items,
  }) {
    return StateAdjustment(
      status: status ?? this.status,
      adjustments: adjustments ?? this.adjustments,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
      warehouses: warehouses ?? this.warehouses,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props =>
      [status, adjustments, meta, errorMessage, warehouses, items];
}
