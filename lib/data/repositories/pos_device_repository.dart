import 'package:back_office/data/models/pos_device_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class PosDeviceRepository {
  FutureEither<PosDeviceModel> activateDevice(Map<String, dynamic> data);
  FutureEither<PosDeviceModel> createDevice(Map<String, dynamic> data);
  FutureEither<ListResponse<PosDeviceModel>> getDevicesByBranch(String branchId);
  FutureEither<PosDeviceModel> updateDevice(String deviceId, Map<String, dynamic> data);
  FutureEither<void> deleteDevice(String deviceId);
}