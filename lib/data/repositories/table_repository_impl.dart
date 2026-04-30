import 'package:back_office/config/app_config.dart';
import 'package:back_office/data/models/table_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/repositories/table_repository.dart';
import 'package:back_office/utils/utils.dart';

class TableRepositoryImpl implements TableRepository {
  // ==================== TABLES ====================

  @override
  FutureEither<ListResponse<TableModel>> createTables(
    String brandId,
    List<Map<String, dynamic>> data,
  ) async {
    return runTask(() async {
      final response = await AppConfig.dio.post<Map<String, dynamic>>(
        '/api/tables',
        data: data.map((e) => {'brandId': brandId, ...e}).toList(),
      );
      final responseData = response.data!['data'] as List;
      return ListResponse<TableModel>.fromJsonList(
        responseData.map((e) => TableModel.fromJson(e as Map<String, dynamic>)).toList(),
        response.data!,
      );
    }, requiresNetwork: true);
  }

  @override
  FutureEither<ListResponse<TableModel>> getTables(
    String brandId,
    String branchId, {
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/tables',
        queryParameters: {
          'brandId': brandId,
          'branchId': branchId,
          if (status != null) 'status': status,
          'page': page,
          'limit': limit,
        },
      );
      return ListResponse<TableModel>.fromJson(
        response.data!,
        (json) => TableModel.fromJson(json),
      );
    });
  }

  @override
  FutureEither<TableModel> getTable(String tableId) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/tables/$tableId',
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return TableModel.fromJson(data);
    });
  }

  @override
  FutureEither<TableModel> updateTable(
    String tableId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      final response = await AppConfig.dio.put<Map<String, dynamic>>(
        '/api/tables/$tableId',
        data: data,
      );
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return TableModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<void> deleteTable(String tableId) async {
    return runTask(() async {
      await AppConfig.dio.delete<void>('/api/tables/$tableId');
    }, requiresNetwork: true);
  }

  // ==================== ROOM TYPES ====================

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
        data: data,
      );
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return RoomTypeModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<void> deleteRoomType(String roomTypeId) async {
    return runTask(() async {
      await AppConfig.dio.delete<void>('/api/room-types/$roomTypeId');
    }, requiresNetwork: true);
  }
}