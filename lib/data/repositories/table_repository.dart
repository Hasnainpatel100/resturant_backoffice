import 'package:back_office/data/models/table_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/utils/utils.dart';

// ✅ NO CHANGE: Abstract contract is correct and clean.
// Room Types section stays commented out as per your existing pattern.
abstract class TableRepository {
  // Tables
  FutureEither<ListResponse<TableModel>> createTables(String brandId, List<Map<String, dynamic>> data);
  FutureEither<ListResponse<TableModel>> getTables(String brandId, String branchId, {String? status, int page = 1, int limit = 20});
  FutureEither<TableModel> getTable(String tableId);
  FutureEither<TableModel> updateTable(String tableId, Map<String, dynamic> data);
  FutureEither<void> deleteTable(String tableId,String brandId);
}
