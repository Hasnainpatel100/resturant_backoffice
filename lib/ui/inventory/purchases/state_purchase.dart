import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/inventory/purchase_model.dart';
import 'package:back_office/data/models/inventory/supplier_model.dart';
import 'package:back_office/data/models/inventory/warehouse_model.dart';
import 'package:back_office/data/models/inventory/item_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum PurchaseStatus { initial, loading, loaded, success, error }

class StatePurchase extends Equatable {
  final PurchaseStatus status;
  final List<PurchaseModel> purchases;
  final PurchaseModel? selected;
  final MetaData? meta;
  final String? errorMessage;

  // Supporting dropdown data lists loaded along during purchases creation
  final List<SupplierModel> suppliers;
  final List<WarehouseModel> warehouses;
  final List<ItemModel> items;

  const StatePurchase({
    this.status = PurchaseStatus.initial,
    this.purchases = const [],
    this.selected,
    this.meta,
    this.errorMessage,
    this.suppliers = const [],
    this.warehouses = const [],
    this.items = const [],
  });

  StatePurchase copyWith({
    PurchaseStatus? status,
    List<PurchaseModel>? purchases,
    PurchaseModel? selected,
    MetaData? meta,
    String? errorMessage,
    List<SupplierModel>? suppliers,
    List<WarehouseModel>? warehouses,
    List<ItemModel>? items,
  }) {
    return StatePurchase(
      status: status ?? this.status,
      purchases: purchases ?? this.purchases,
      selected: selected ?? this.selected,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
      suppliers: suppliers ?? this.suppliers,
      warehouses: warehouses ?? this.warehouses,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
        status,
        purchases,
        selected,
        meta,
        errorMessage,
        suppliers,
        warehouses,
        items
      ];
}
