import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/plan_repository.dart';
import 'state_plan.dart';

class CubitPlan extends Cubit<StatePlan> {
  final PlanRepository _repository;

  CubitPlan({required PlanRepository repository})
      : _repository = repository,
        super(const StatePlan());

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<void> getPlans({int page = 1, int limit = 50}) async {
    emit(state.copyWith(status: PlanStatus.loading));
    final result = await _repository.getPlans(page: page, limit: limit);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: PlanStatus.error, errorMessage: failure.message)),
      (response) => emit(state.copyWith(
        status: PlanStatus.loaded,
        plans: response.items,
        meta: response.meta,
      )),
    );
  }

  Future<void> getPlan(String planId) async {
    emit(state.copyWith(status: PlanStatus.loading));
    final result = await _repository.getPlan(planId);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: PlanStatus.error, errorMessage: failure.message)),
      (plan) => emit(state.copyWith(status: PlanStatus.loaded, selectedPlan: plan)),
    );
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> createPlan(Map<String, dynamic> data) async {
    emit(state.copyWith(status: PlanStatus.loading));
    final result = await _repository.createPlan(data);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: PlanStatus.error, errorMessage: failure.message)),
      (plan) {
        final updated = [plan, ...state.plans];
        emit(state.copyWith(
          status: PlanStatus.success,
          plans: updated,
          selectedPlan: plan,
        ));
      },
    );
  }

  Future<void> updatePlan(String planId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: PlanStatus.loading));
    final result = await _repository.updatePlan(planId, data);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: PlanStatus.error, errorMessage: failure.message)),
      (updated) {
        final plans = state.plans
            .map((p) => p.id == planId ? updated : p)
            .toList();
        emit(state.copyWith(
          status: PlanStatus.success,
          plans: plans,
          selectedPlan: updated,
        ));
      },
    );
  }

  Future<void> deletePlan(String planId) async {
    emit(state.copyWith(status: PlanStatus.loading));
    final result = await _repository.deletePlan(planId);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: PlanStatus.error, errorMessage: failure.message)),
      (_) {
        final plans = state.plans.where((p) => p.id != planId).toList();
        emit(state.clearSelected().copyWith(
          status: PlanStatus.success,
          plans: plans,
        ));
      },
    );
  }
}
