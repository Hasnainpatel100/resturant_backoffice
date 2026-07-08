import 'package:back_office/data/models/inventory/supplier_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class SupplierRepository {
  FutureEither<ListResponse<SupplierModel>> getSuppliers(
    String brandId, {
    int page = 1,
    int limit = 50,
    String? search,
  });

  FutureEither<SupplierModel> getSupplier(String brandId, String supplierId);

  FutureEither<SupplierModel> createSupplier(
    String brandId,
    Map<String, dynamic> data,
  );

  FutureEither<SupplierModel> updateSupplier(
    String brandId,
    String supplierId,
    Map<String, dynamic> data,
  );

  FutureEither<void> deleteSupplier(String brandId, String supplierId);
}
