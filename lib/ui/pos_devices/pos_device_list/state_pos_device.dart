import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/pos_device_model.dart';

enum StatePosDeviceStatus { initial, loading, loaded, error }

class StatePosDevice extends Equatable {
  final StatePosDeviceStatus status;
  final List<PosDeviceModel> devices;
  final String? errorMessage;

  const StatePosDevice({
    this.status = StatePosDeviceStatus.initial,
    this.devices = const [],
    this.errorMessage,
  });

  StatePosDevice copyWith({
    StatePosDeviceStatus? status,
    List<PosDeviceModel>? devices,
    String? errorMessage,
  }) {
    return StatePosDevice(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, devices, errorMessage];
}