import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/branch_subscription_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class BranchSubscriptionRepository {
  /// Get the current active subscription for a branch.
  FutureEither<BranchSubscriptionModel?> getBranchSubscription(String branchId);

  /// Get full subscription history (paginated) for a branch.
  FutureEither<ListResponse<BranchSubscriptionModel>> getSubscriptionHistory(
    String branchId, {
    int page = 1,
    int limit = 20,
  });

  /// Assign a new plan to a branch — creates a subscription record.
  FutureEither<BranchSubscriptionModel> assignPlanToBranch(
    String branchId,
    Map<String, dynamic> data,
  );

  /// Update an existing subscription (e.g. change expiry, auto-renew flag).
  FutureEither<BranchSubscriptionModel> updateSubscription(
    String subscriptionId,
    Map<String, dynamic> data,
  );

  /// Renew an existing subscription — extends the expiry date.
  FutureEither<BranchSubscriptionModel> renewSubscription(
    String subscriptionId,
    Map<String, dynamic> data,
  );

  /// Cancel a subscription.
  FutureEither<void> cancelSubscription(String subscriptionId);
}
