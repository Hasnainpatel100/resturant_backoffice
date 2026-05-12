import 'package:back_office/config/app_config.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/branch_subscription_model.dart';
import 'package:back_office/data/repositories/branch_subscription_repository.dart';
import 'package:back_office/utils/utils.dart';

class BranchSubscriptionRepositoryImpl implements BranchSubscriptionRepository {
  @override
  FutureEither<BranchSubscriptionModel?> getBranchSubscription(
      String branchId) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/branch-subscriptions/branch/$branchId/active',
      );
      final data = response.data!['data'];
      if (data == null) return null;
      return BranchSubscriptionModel.fromJson(data as Map<String, dynamic>);
    });
  }

  @override
  FutureEither<ListResponse<BranchSubscriptionModel>> getSubscriptionHistory(
    String branchId, {
    int page = 1,
    int limit = 20,
  }) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/branch-subscriptions/branch/$branchId',
        queryParameters: {'page': page, 'limit': limit},
      );
      return ListResponse<BranchSubscriptionModel>.fromJson(
        response.data!,
        (json) => BranchSubscriptionModel.fromJson(json),
      );
    });
  }

  @override
  FutureEither<BranchSubscriptionModel> assignPlanToBranch(
    String branchId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      final response = await AppConfig.dio.post<Map<String, dynamic>>(
        '/api/branch-subscriptions/assign',
        data: {'branchId': branchId, ...data},
      );
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return BranchSubscriptionModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<BranchSubscriptionModel> updateSubscription(
    String subscriptionId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      final response = await AppConfig.dio.put<Map<String, dynamic>>(
        '/api/branch-subscriptions/$subscriptionId',
        data: data,
      );
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return BranchSubscriptionModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<BranchSubscriptionModel> renewSubscription(
    String subscriptionId,
    Map<String, dynamic> data,
  ) async {
    return runTask(() async {
      final response = await AppConfig.dio.post<Map<String, dynamic>>(
        '/api/branch-subscriptions/$subscriptionId/renew',
        data: data,
      );
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return BranchSubscriptionModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<void> cancelSubscription(String subscriptionId) async {
    return runTask(() async {
      await AppConfig.dio.post<void>(
        '/api/branch-subscriptions/$subscriptionId/cancel',
      );
    }, requiresNetwork: true);
  }
}
