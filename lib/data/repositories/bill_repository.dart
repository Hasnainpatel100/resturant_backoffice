import '../../utils/typedefs.dart';
import '../models/api_response_model.dart';
import '../models/bill_model.dart';
import '../models/dashboard_report_model.dart';

abstract interface class BillRepository {
  FutureEither<ListResponse<BillModel>> getBills(
    String brandId,
    String? branchId, {
    int page = 1,
    int limit = 20,
  });

  FutureEither<BillModel> getBill(String billId);

  FutureEither<DashboardReportModel> getDashboardReport({
    required String branchId,
    required int fromDate,
    required int toDate,
  });
}
