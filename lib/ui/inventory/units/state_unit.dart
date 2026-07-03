import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/inventory/unit_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum UnitStatus { initial, loading, loaded, success, error }

class StateUnit extends Equatable {
  final UnitStatus status;
  final List<UnitModel> units;
  final UnitModel? selected;
  final MetaData? meta;
  final String? errorMessage;

  const StateUnit({
    this.status = UnitStatus.initial,
    this.units = const [],
    this.selected,
    this.meta,
    this.errorMessage,
  });

  StateUnit copyWith({
    UnitStatus? status,
    List<UnitModel>? units,
    UnitModel? selected,
    MetaData? meta,
    String? errorMessage,
  }) {
    return StateUnit(
      status: status ?? this.status,
      units: units ?? this.units,
      selected: selected ?? this.selected,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, units, selected, meta, errorMessage];
}
