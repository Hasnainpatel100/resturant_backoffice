import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/room_type_repository.dart';
import 'state_room_type.dart';

class CubitRoomType extends Cubit<StateRoomType> {
  final RoomTypeRepository _repository;

  CubitRoomType({required RoomTypeRepository repository})
      : _repository = repository,
        super(const StateRoomType());

  Future<void> loadRoomTypes(String brandId, String branchId, {int page = 1, int limit = 20}) async {
    emit(state.copyWith(status: RoomTypeStatus.loading));
    final result = await _repository.getRoomTypes(brandId, branchId, page: page, limit: limit);
    result.fold(
          (failure) => emit(state.copyWith(status: RoomTypeStatus.error, errorMessage: failure.message)),
          (response) => emit(state.copyWith(
        status: RoomTypeStatus.loaded,
        roomTypes: response.items,
        meta: response.meta,
      )),
    );
  }

  Future<void> createRoomTypes(String brandId, List<Map<String, dynamic>> data) async {
    emit(state.copyWith(status: RoomTypeStatus.loading));
    final result = await _repository.createRoomTypes(brandId, data);
    result.fold(
          (failure) => emit(state.copyWith(status: RoomTypeStatus.error, errorMessage: failure.message)),
          (response) => emit(state.copyWith(
        status: RoomTypeStatus.loaded,
        roomTypes: [...state.roomTypes, ...response.items],
        meta: response.meta,
      )),
    );
  }

  Future<void> updateRoomType(String roomTypeId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: RoomTypeStatus.loading));
    final result = await _repository.updateRoomType(roomTypeId, data);
    result.fold(
          (failure) => emit(state.copyWith(status: RoomTypeStatus.error, errorMessage: failure.message)),
          (roomType) {
        final updated = state.roomTypes.map((r) => r.id == roomType.id ? roomType : r).toList();
        emit(state.copyWith(status: RoomTypeStatus.loaded, roomTypes: updated));
      },
    );
  }

  Future<void> deleteRoomType(String roomTypeId, {required String brandId, required String branchId}) async {
    emit(state.copyWith(status: RoomTypeStatus.loading));
    final result = await _repository.deleteRoomType(roomTypeId, brandId: brandId, branchId: branchId);
    result.fold(
          (failure) => emit(state.copyWith(status: RoomTypeStatus.error, errorMessage: failure.message)),
          (_) {
        final updated = state.roomTypes.where((r) => r.id != roomTypeId).toList();
        emit(state.copyWith(status: RoomTypeStatus.loaded, roomTypes: updated));
      },
    );
  }
}
