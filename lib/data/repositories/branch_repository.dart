import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/branch_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class BranchRepository {
  FutureEither<BranchModel> getBranch(String branchId);

  FutureEither<BranchModel> createBranch(
      String brandId, Map<String, dynamic> data);

  FutureEither<BranchModel> updateBranch(
      String branchId, Map<String, dynamic> data);

  FutureEither<void> deleteBranch(String branchId);

  FutureEither<ListResponse<BranchBasicModel>> getBranchesByBrand(
      String brandId,
      {int page = 1,
      int limit = 20});

  FutureEither<Map<String, dynamic>> assignPlan(
      String branchId, Map<String, dynamic> data);

  FutureEither<ListResponse<Map<String, dynamic>>> getPlanHistory(
      String branchId,
      {int page = 1,
      int limit = 20});
}
