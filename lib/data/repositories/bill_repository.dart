import '../../utils/typedefs.dart';
import '../models/api_response_model.dart';
import '../models/bill_model.dart';

abstract interface class BillRepository {
  FutureEither<ListResponse<BillModel>> getBills(
    String brandId,
    String branchId, {
    int page = 1,
    int limit = 20,
  });

  FutureEither<BillModel> getBill(String billId);
}
