import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/room_type_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum RoomTypeStatus { initial, loading, loaded, error }

class StateRoomType extends Equatable {
  final RoomTypeStatus status;
  final List<RoomTypeModel> roomTypes;
  final MetaData? meta;
  final String? errorMessage;

  const StateRoomType({
    this.status = RoomTypeStatus.initial,
    this.roomTypes = const [],
    this.meta,
    this.errorMessage,
  });

  StateRoomType copyWith({
    RoomTypeStatus? status,
    List<RoomTypeModel>? roomTypes,
    MetaData? meta,
    String? errorMessage,
    bool clearError = false, // ← explicit flag to wipe stale error
  }) {
    return StateRoomType(
      status: status ?? this.status,
      roomTypes: roomTypes ?? this.roomTypes,
      meta: meta ?? this.meta,
      // If clearError is true OR the new status is not error, clear the message.
      // This prevents a stale errorMessage sitting in state after recovery.
      errorMessage: clearError || (status != null && status != RoomTypeStatus.error)
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, roomTypes, meta, errorMessage];
}
