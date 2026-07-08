import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/inventory/supplier_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum SupplierStatus { initial, loading, loaded, success, error }

class StateSupplier extends Equatable {
  final SupplierStatus status;
  final List<SupplierModel> suppliers;
  final SupplierModel? selected;
  final MetaData? meta;
  final String? errorMessage;

  const StateSupplier({
    this.status = SupplierStatus.initial,
    this.suppliers = const [],
    this.selected,
    this.meta,
    this.errorMessage,
  });

  StateSupplier copyWith({
    SupplierStatus? status,
    List<SupplierModel>? suppliers,
    SupplierModel? selected,
    MetaData? meta,
    String? errorMessage,
  }) {
    return StateSupplier(
      status: status ?? this.status,
      suppliers: suppliers ?? this.suppliers,
      selected: selected ?? this.selected,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, suppliers, selected, meta, errorMessage];
}
