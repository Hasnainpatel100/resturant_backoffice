import 'package:back_office/data/models/inventory/stock_adjustment_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class StockAdjustmentRepository {
  FutureEither<ListResponse<StockAdjustmentModel>> getAdjustments(
    String brandId, {
    int page = 1,
    int limit = 50,
  });

  FutureEither<StockAdjustmentModel> createAdjustment(
    String brandId,
    Map<String, dynamic> data,
  );
}
