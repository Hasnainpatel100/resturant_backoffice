import 'package:back_office/config/app_config.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/bill_model.dart';
import 'package:back_office/data/models/dashboard_report_model.dart';
import 'package:back_office/data/repositories/bill_repository.dart';
import 'package:back_office/utils/utils.dart';

class BillRepositoryImpl implements BillRepository {
  @override
  FutureEither<ListResponse<BillModel>> getBills(
    String brandId,
    String? branchId, {
    int page = 1,
    int limit = 20,
  }) async {
    return runTask(() async {
      final queryParams = <String, dynamic>{
        'brandId': brandId,
        'page': page,
        'limit': limit,
      };
      if (branchId != null && branchId.isNotEmpty) {
        queryParams['branchId'] = branchId;
      }

      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/bills',
        queryParameters: queryParams,
      );

      return ListResponse<BillModel>.fromJson(
        response.data!,
        (json) => BillModel.fromJson(json),
      );
    });
  }

  @override
  FutureEither<BillModel> getBill(String billId) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/bills/$billId',
      );

      final responseData = response.data!['data'] as Map<String, dynamic>;
      return BillModel.fromJson(responseData);
    });
  }

  @override
  FutureEither<DashboardReportModel> getDashboardReport({
    required String branchId,
    required int fromDate,
    required int toDate,
  }) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/bills/reports/dashboard',
        queryParameters: {
          'branchId': branchId,
          'fromDate': fromDate,
          'toDate': toDate,
        },
      );

      final responseData = response.data!['data'] as Map<String, dynamic>;
      return DashboardReportModel.fromJson(responseData);
    });
  }
}
