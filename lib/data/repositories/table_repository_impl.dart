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

      // ✅ FIX: API returns { "data": [...], "meta": {...} } at root level for POST.
      // The original code cast response.data!['data'] as List which is correct for create,
      // but then used ListResponse.fromJsonList — this is fine IF fromJsonList exists.
      // Unified to use fromJson for consistency with getTables().
      return ListResponse<TableModel>.fromJson(
        response.data!,
            (json) => TableModel.fromJson(json),
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

      // ✅ NO CHANGE: fromJson parses response.data which is { "data": [...], "meta": {...} }
      // This is correct — ListResponse.fromJson reads the 'data' key internally.
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

      // ✅ NO CHANGE: Single item response has { "data": {...} } — correct parsing.
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

      // ✅ NO CHANGE: PUT returns { "data": {...} } — correct parsing.
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return TableModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  @override
  FutureEither<void> deleteTable(String tableId, String brandId) async {
    return runTask(() async {
      await AppConfig.dio.delete<void>(
        '/api/tables/$tableId',
        queryParameters: {'brandId': brandId}, // ✅ THIS WAS MISSING
      );
    }, requiresNetwork: true);
  }
}
