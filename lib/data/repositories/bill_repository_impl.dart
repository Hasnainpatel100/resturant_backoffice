import 'package:back_office/config/app_config.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/bill_model.dart';
import 'package:back_office/data/repositories/bill_repository.dart';
import 'package:back_office/utils/utils.dart';

class BillRepositoryImpl implements BillRepository {
  @override
  FutureEither<ListResponse<BillModel>> getBills(
    String brandId,
    String branchId, {
    int page = 1,
    int limit = 20,
  }) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/bills',
        queryParameters: {
          'brandId': brandId,
          'branchId': branchId,
          'page': page,
          'limit': limit,
        },
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
}
