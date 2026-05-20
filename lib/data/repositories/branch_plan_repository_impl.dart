import 'package:back_office/config/app_config.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/branch_plan_model.dart';
import 'package:back_office/data/repositories/branch_plan_repository.dart';
import 'package:back_office/utils/utils.dart';

class BranchPlanRepositoryImpl implements BranchPlanRepository {
  @override
  FutureEither<ListResponse<BranchPlanModel>> getPlanHistory(
    String branchId, {
    int page = 0,
    int limit = 20,
  }) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/branches/$branchId/plan-history',
        queryParameters: {'page': page, 'limit': limit},
      );
      return ListResponse<BranchPlanModel>.fromJson(
        response.data!,
        (json) => BranchPlanModel.fromJson(json),
      );
    });
  }

  @override
  FutureEither<void> assignPlan(String branchId, Map<String, dynamic> data) async {
    return runTask(() async {
      final response = await AppConfig.dio.put(
        '/api/branches/$branchId/plan',
        data: data,
      );
    }, requiresNetwork: true);
  }
}
