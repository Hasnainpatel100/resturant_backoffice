import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/models/plan_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class PlanRepository {
  /// Fetch all plans (active and inactive).
  FutureEither<ListResponse<PlanModel>> getPlans({int page = 1, int limit = 50});

  /// Fetch a single plan by ID.
  FutureEither<PlanModel> getPlan(String planId);

  /// Create a new master plan.
  FutureEither<PlanModel> createPlan(Map<String, dynamic> data);

  /// Update an existing master plan.
  FutureEither<PlanModel> updatePlan(String planId, Map<String, dynamic> data);

  /// Soft-delete / deactivate a plan.
  FutureEither<void> deletePlan(String planId);
}
