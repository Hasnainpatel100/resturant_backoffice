import 'package:back_office/data/models/inventory/warehouse_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class WarehouseRepository {
  FutureEither<ListResponse<WarehouseModel>> getWarehouses(
    String brandId, {
    int page = 1,
    int limit = 50,
  });

  FutureEither<WarehouseModel> getWarehouse(String brandId, String warehouseId);

  FutureEither<WarehouseModel> createWarehouse(
    String brandId,
    Map<String, dynamic> data,
  );

  FutureEither<WarehouseModel> updateWarehouse(
    String brandId,
    String warehouseId,
    Map<String, dynamic> data,
  );

  FutureEither<void> deleteWarehouse(String brandId, String warehouseId);
}
