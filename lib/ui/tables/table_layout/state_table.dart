import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/table_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum StateTableStatus { initial, loading, loaded, error }

class StateTable extends Equatable {
  final StateTableStatus status;
  final List<TableModel> tables;
  final List<RoomTypeModel> roomTypes;
  final MetaData? meta;
  final String? errorMessage;

  const StateTable({
    this.status = StateTableStatus.initial,
    this.tables = const [],
    this.roomTypes = const [],
    this.meta,
    this.errorMessage,
  });

  StateTable copyWith({
    StateTableStatus? status,
    List<TableModel>? tables,
    List<RoomTypeModel>? roomTypes,
    MetaData? meta,
    String? errorMessage,
  }) {
    return StateTable(
      status: status ?? this.status,
      tables: tables ?? this.tables,
      roomTypes: roomTypes ?? this.roomTypes,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tables, roomTypes, meta, errorMessage];
}