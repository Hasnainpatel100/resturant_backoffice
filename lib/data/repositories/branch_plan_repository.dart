import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/branch_plan_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class BranchPlanRepository {
  FutureEither<ListResponse<BranchPlanModel>> getPlanHistory(
    String branchId, {
    int page = 0,
    int limit = 20,
  });

  FutureEither<void> assignPlan(String branchId, Map<String, dynamic> data);
}
