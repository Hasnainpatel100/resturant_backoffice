import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/table_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

import '../../../data/models/room_type_model.dart';

enum StateTableStatus { initial, loading, loaded, error }

class StateTable extends Equatable {
  final StateTableStatus status;
  final List<TableModel> tables;
  final MetaData? meta;
  final String? errorMessage;

  const StateTable({
    this.status = StateTableStatus.initial,
    this.tables = const [],
    this.meta,
    this.errorMessage,
  });

  StateTable copyWith({
    StateTableStatus? status,
    List<TableModel>? tables,
    MetaData? meta,
    String? errorMessage,
  }) {
    return StateTable(
      status: status ?? this.status,
      tables: tables ?? this.tables,
      meta: meta ?? this.meta,
      // ✅ FIX: errorMessage must be explicitly nullable-reset.
      // If a previous error existed and a new success comes in,
      // copyWith(status: loaded) would carry the old errorMessage forward.
      // Pass null explicitly on success to clear it.
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tables, meta, errorMessage];
}
