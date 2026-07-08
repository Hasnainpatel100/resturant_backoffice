import 'package:back_office/data/models/inventory/purchase_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class PurchaseRepository {
  FutureEither<ListResponse<PurchaseModel>> getPurchases(
    String brandId, {
    int page = 1,
    int limit = 50,
    String? search,
  });

  FutureEither<PurchaseModel> getPurchase(String brandId, String purchaseId);

  FutureEither<PurchaseModel> createPurchase(
    String brandId,
    Map<String, dynamic> data,
  );
}
