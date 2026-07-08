import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/inventory/stock_transfer_model.dart';
import 'package:back_office/data/models/inventory/warehouse_model.dart';
import 'package:back_office/data/models/inventory/item_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum TransferStatus { initial, loading, loaded, success, error }

class StateTransfer extends Equatable {
  final TransferStatus status;
  final List<StockTransferModel> transfers;
  final MetaData? meta;
  final String? errorMessage;

  final List<WarehouseModel> warehouses;
  final List<ItemModel> items;

  const StateTransfer({
    this.status = TransferStatus.initial,
    this.transfers = const [],
    this.meta,
    this.errorMessage,
    this.warehouses = const [],
    this.items = const [],
  });

  StateTransfer copyWith({
    TransferStatus? status,
    List<StockTransferModel>? transfers,
    MetaData? meta,
    String? errorMessage,
    List<WarehouseModel>? warehouses,
    List<ItemModel>? items,
  }) {
    return StateTransfer(
      status: status ?? this.status,
      transfers: transfers ?? this.transfers,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
      warehouses: warehouses ?? this.warehouses,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props =>
      [status, transfers, meta, errorMessage, warehouses, items];
}
