import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/branch_plan_repository.dart';
import 'state_branch_plan.dart';

class CubitBranchPlan extends Cubit<StateBranchPlan> {
  final BranchPlanRepository _repository;

  CubitBranchPlan({required BranchPlanRepository repository})
      : _repository = repository,
        super(const StateBranchPlan());

  Future<void> loadPlanHistory(String branchId, {int page = 0, int limit = 20}) async {
    emit(state.copyWith(status: BranchPlanStatus.loading));
    final result = await _repository.getPlanHistory(branchId, page: page, limit: limit);
    result.fold(
      (failure) => emit(state.copyWith(
        status: BranchPlanStatus.error,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: BranchPlanStatus.loaded,
        history: response.items,
        meta: response.meta,
      )),
    );
  }

  // Note: For Phase 1, we might not call assignPlan, but we'll have it ready.
  Future<void> assignPlan(String branchId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: BranchPlanStatus.loading));
    final result = await _repository.assignPlan(branchId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: BranchPlanStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: BranchPlanStatus.success)),
    );
  }
}
