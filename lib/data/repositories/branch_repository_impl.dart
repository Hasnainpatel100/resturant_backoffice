import 'package:back_office/config/app_config.dart';
import 'package:back_office/data/models/branch_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/repositories/branch_repository.dart';
import 'package:back_office/utils/utils.dart';

class BranchRepositoryImpl implements BranchRepository {
  @override
  FutureEither<BranchModel> getBranch(String branchId) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>('/api/branches/$branchId');
      final data = response.data!['data'] as Map<String, dynamic>;
      return BranchModel.fromJson(data);
    });
  }

  @override
  FutureEither<BranchModel> createBranch(String brandId, Map<String, dynamic> data) async {
    return runTask(() async {
      final response = await AppConfig.dio.post<Map<String, dynamic>>(
        '/api/branches/create',
        data: {'brandId': brandId, ...data},
      );
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return BranchModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<BranchModel> updateBranch(String branchId, Map<String, dynamic> data) async {
    return runTask(() async {
      final response = await AppConfig.dio.put<Map<String, dynamic>>('/api/branches/$branchId', data: data);
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return BranchModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<void> deleteBranch(String branchId) async {
    return runTask(() async {
      await AppConfig.dio.delete<void>('/api/branches/$branchId');
    }, requiresNetwork: true);
  }

  @override
  FutureEither<ListResponse<BranchBasicModel>> getBranchesByBrand(String brandId, {int page = 1, int limit = 20}) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/branches/brand/$brandId',
        queryParameters: {'page': page, 'limit': limit},
      );
      return ListResponse<BranchBasicModel>.fromJson(
        response.data!,
        (json) => BranchBasicModel.fromJson(json),
      );
    });
  }

  @override
  FutureEither<Map<String, dynamic>> assignPlan(String branchId, Map<String, dynamic> data) async {
    return runTask(() async {
      final response = await AppConfig.dio.put<Map<String, dynamic>>(
        '/api/branches/$branchId/plan',
        data: data,
      );
      return response.data!['data'] as Map<String, dynamic>;
    }, requiresNetwork: true);
  }

  @override
  FutureEither<ListResponse<Map<String, dynamic>>> getPlanHistory(String branchId, {int page = 1, int limit = 20}) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/branches/$branchId/plan-history',
        queryParameters: {'page': page, 'limit': limit},
      );
      return ListResponse<Map<String, dynamic>>.fromJson(
        response.data!,
        (json) => json,
      );
    });
  }
}
