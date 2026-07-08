import 'package:back_office/data/models/inventory/stock_transfer_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class StockTransferRepository {
  FutureEither<ListResponse<StockTransferModel>> getTransfers(
    String brandId, {
    int page = 1,
    int limit = 50,
  });

  FutureEither<StockTransferModel> createTransfer(
    String brandId,
    Map<String, dynamic> data,
  );
}
