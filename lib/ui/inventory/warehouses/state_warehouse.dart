import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/inventory/warehouse_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum WarehouseStatus { initial, loading, loaded, success, error }

class StateWarehouse extends Equatable {
  final WarehouseStatus status;
  final List<WarehouseModel> warehouses;
  final WarehouseModel? selected;
  final MetaData? meta;
  final String? errorMessage;

  const StateWarehouse({
    this.status = WarehouseStatus.initial,
    this.warehouses = const [],
    this.selected,
    this.meta,
    this.errorMessage,
  });

  StateWarehouse copyWith({
    WarehouseStatus? status,
    List<WarehouseModel>? warehouses,
    WarehouseModel? selected,
    MetaData? meta,
    String? errorMessage,
  }) {
    return StateWarehouse(
      status: status ?? this.status,
      warehouses: warehouses ?? this.warehouses,
      selected: selected ?? this.selected,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, warehouses, selected, meta, errorMessage];
}
