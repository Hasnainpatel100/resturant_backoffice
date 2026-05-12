import 'package:back_office/config/app_config.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/plan_model.dart';
import 'package:back_office/data/repositories/plan_repository.dart';
import 'package:back_office/utils/utils.dart';

class PlanRepositoryImpl implements PlanRepository {
  @override
  FutureEither<ListResponse<PlanModel>> getPlans({int page = 1, int limit = 50}) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/plans',
        queryParameters: {'page': page, 'limit': limit},
      );
      return ListResponse<PlanModel>.fromJson(
        response.data!,
        (json) => PlanModel.fromJson(json),
      );
    });
  }

  @override
  FutureEither<PlanModel> getPlan(String planId) async {
    return runTask(() async {
      final response =
          await AppConfig.dio.get<Map<String, dynamic>>('/api/plans/$planId');
      final data = response.data!['data'] as Map<String, dynamic>;
      return PlanModel.fromJson(data);
    });
  }

  @override
  FutureEither<PlanModel> createPlan(Map<String, dynamic> data) async {
    return runTask(() async {
      final response = await AppConfig.dio.post<Map<String, dynamic>>(
        '/api/plans/create',
        data: data,
      );
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return PlanModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<PlanModel> updatePlan(String planId, Map<String, dynamic> data) async {
    return runTask(() async {
      final response = await AppConfig.dio.put<Map<String, dynamic>>(
        '/api/plans/$planId',
        data: data,
      );
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return PlanModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<void> deletePlan(String planId) async {
    return runTask(() async {
      await AppConfig.dio.delete<void>('/api/plans/$planId');
    }, requiresNetwork: true);
  }
}
