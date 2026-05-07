import 'package:back_office/config/app_config.dart';
import 'package:back_office/data/models/room_type_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/repositories/room_type_repository.dart';
import 'package:back_office/utils/utils.dart';

class RoomTypeRepositoryImpl implements RoomTypeRepository {
  @override
  FutureEither<ListResponse<RoomTypeModel>> createRoomTypes(
      String brandId,
      List<Map<String, dynamic>> data,
      ) async {
    return runTask(() async {
      final response = await AppConfig.dio.post<Map<String, dynamic>>(
        '/api/room-types',
        data: data.map((e) => {'brandId': brandId, ...e}).toList(),
      );
      final responseData = response.data!['data'] as List;
      return ListResponse<RoomTypeModel>.fromJsonList(
        responseData.map((e) => RoomTypeModel.fromJson(e as Map<String, dynamic>)).toList(),
        response.data!,
      );
    }, requiresNetwork: true);
  }

  @override
  FutureEither<ListResponse<RoomTypeModel>> getRoomTypes(
      String brandId,
      String branchId, {
        int page = 1,
        int limit = 20,
      }) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/room-types',
        queryParameters: {
          'brandId': brandId,
          'branchId': branchId,
          'page': page,
          'limit': limit,
        },
      );
      return ListResponse<RoomTypeModel>.fromJson(
        response.data!,
            (json) => RoomTypeModel.fromJson(json),
      );
    });
  }

  @override
  FutureEither<RoomTypeModel> getRoomType(String roomTypeId) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/room-types/$roomTypeId',
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return RoomTypeModel.fromJson(data);
    });
  }

  @override
  FutureEither<RoomTypeModel> updateRoomType(
      String roomTypeId,
      Map<String, dynamic> data,
      ) async {
    return runTask(() async {
      final response = await AppConfig.dio.put<Map<String, dynamic>>(
        '/api/room-types/$roomTypeId',
        data: {
          'brandId': data['brandId'],
          'name': data['name'],
          if (data['displayOrder'] != null) 'displayOrder': data['displayOrder'],
          if (data['isActive'] != null) 'isActive': data['isActive'],
        },
      );
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return RoomTypeModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<void> deleteRoomType(
      String roomTypeId, {
        required String brandId,
        required String branchId,
      }) async {
    return runTask(() async {
      await AppConfig.dio.delete<void>(
        '/api/room-types/$roomTypeId',
        queryParameters: {
          'brandId': brandId,
          'branchId': branchId,
        },
      );
    }, requiresNetwork: true);
  }
}
