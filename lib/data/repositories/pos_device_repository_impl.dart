import 'package:back_office/config/app_config.dart';
import 'package:back_office/data/models/pos_device_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/repositories/pos_device_repository.dart';
import 'package:back_office/utils/utils.dart';

class PosDeviceRepositoryImpl implements PosDeviceRepository {
  @override
  FutureEither<PosDeviceModel> activateDevice(Map<String, dynamic> data) async {
    return runTask(() async {
      final response = await AppConfig.dio.post<Map<String, dynamic>>(
        '/api/devices/activate',
        data: data,
      );
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return PosDeviceModel.fromJson(responseData);
    });
  }

  @override
  FutureEither<PosDeviceModel> createDevice(Map<String, dynamic> data) async {
    return runTask(() async {
      final response = await AppConfig.dio.post<Map<String, dynamic>>(
        '/api/devices/create',
        data: data,
      );
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return PosDeviceModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<ListResponse<PosDeviceModel>> getDevicesByBranch(String branchId) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/devices/branch/$branchId',
      );
      final data = response.data!['data'];
      final items = (data is List) ? data : [];
      return ListResponse<PosDeviceModel>.fromJsonList(
        items.map((e) => PosDeviceModel.fromJson(e as Map<String, dynamic>)).toList(),
        response.data!,
      );
    });
  }

  @override
  FutureEither<PosDeviceModel> updateDevice(String deviceId, Map<String, dynamic> data) async {
    // NOTE: Backend does not have PUT /api/devices/{deviceId} endpoint yet
    // This is a placeholder - will fail until backend adds the endpoint
    return runTask(() async {
      throw UnimplementedError('Update device endpoint not implemented on backend');
    }, requiresNetwork: true);
  }

  @override
  FutureEither<void> deleteDevice(String deviceId) async {
    return runTask(() async {
      await AppConfig.dio.delete<void>('/api/devices/$deviceId');
    }, requiresNetwork: true);
  }
}