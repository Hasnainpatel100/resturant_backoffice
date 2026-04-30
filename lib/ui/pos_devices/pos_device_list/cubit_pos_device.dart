import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/pos_device_repository.dart';
import 'state_pos_device.dart';

class CubitPosDevice extends Cubit<StatePosDevice> {
  final PosDeviceRepository _repository;

  CubitPosDevice({required PosDeviceRepository repository})
      : _repository = repository,
        super(const StatePosDevice());

  Future<void> loadDevices(String branchId) async {
    emit(state.copyWith(status: StatePosDeviceStatus.loading));
    final result = await _repository.getDevicesByBranch(branchId);
    result.fold(
      (failure) => emit(state.copyWith(status: StatePosDeviceStatus.error, errorMessage: failure.message)),
      (response) => emit(state.copyWith(
        status: StatePosDeviceStatus.loaded,
        devices: response.items,
      )),
    );
  }

  Future<void> activateDevice(Map<String, dynamic> data) async {
    emit(state.copyWith(status: StatePosDeviceStatus.loading));
    final result = await _repository.activateDevice(data);
    result.fold(
      (failure) => emit(state.copyWith(status: StatePosDeviceStatus.error, errorMessage: failure.message)),
      (device) => emit(state.copyWith(
        status: StatePosDeviceStatus.loaded,
        devices: [...state.devices, device],
      )),
    );
  }

  Future<void> registerDevice(Map<String, dynamic> data) async {
    emit(state.copyWith(status: StatePosDeviceStatus.loading));
    final result = await _repository.createDevice(data);
    result.fold(
      (failure) => emit(state.copyWith(status: StatePosDeviceStatus.error, errorMessage: failure.message)),
      (device) => emit(state.copyWith(
        status: StatePosDeviceStatus.loaded,
        devices: [...state.devices, device],
      )),
    );
  }

  Future<void> updateDevice(String deviceId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: StatePosDeviceStatus.loading));
    final result = await _repository.updateDevice(deviceId, data);
    result.fold(
      (failure) => emit(state.copyWith(status: StatePosDeviceStatus.error, errorMessage: failure.message)),
      (device) {
        final updated = state.devices.map((d) => d.id == device.id ? device : d).toList();
        emit(state.copyWith(status: StatePosDeviceStatus.loaded, devices: updated));
      },
    );
  }

  Future<void> deleteDevice(String deviceId) async {
    emit(state.copyWith(status: StatePosDeviceStatus.loading));
    final result = await _repository.deleteDevice(deviceId);
    result.fold(
      (failure) => emit(state.copyWith(status: StatePosDeviceStatus.error, errorMessage: failure.message)),
      (_) {
        final updated = state.devices.where((d) => d.id != deviceId).toList();
        emit(state.copyWith(status: StatePosDeviceStatus.loaded, devices: updated));
      },
    );
  }
}