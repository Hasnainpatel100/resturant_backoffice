import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/branch_subscription_repository.dart';
import 'state_subscription.dart';

class CubitBranchSubscription extends Cubit<StateSubscription> {
  final BranchSubscriptionRepository _repository;

  CubitBranchSubscription({required BranchSubscriptionRepository repository})
      : _repository = repository,
        super(const StateSubscription());

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<void> getBranchSubscription(String branchId) async {
    emit(state.copyWith(status: SubscriptionCubitStatus.loading));
    final result = await _repository.getBranchSubscription(branchId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SubscriptionCubitStatus.error,
        errorMessage: failure.message,
      )),
      (subscription) {
        if (subscription == null) {
          emit(state.clearSubscription().copyWith(
            status: SubscriptionCubitStatus.loaded,
          ));
        } else {
          emit(state.copyWith(
            status: SubscriptionCubitStatus.loaded,
            activeSubscription: subscription,
          ));
        }
      },
    );
  }

  Future<void> getSubscriptionHistory(
    String branchId, {
    int page = 1,
    int limit = 20,
  }) async {
    emit(state.copyWith(status: SubscriptionCubitStatus.loading));
    final result = await _repository.getSubscriptionHistory(
      branchId,
      page: page,
      limit: limit,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: SubscriptionCubitStatus.error,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: SubscriptionCubitStatus.loaded,
        history: response.items,
        meta: response.meta,
      )),
    );
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> assignPlanToBranch(
    String branchId,
    Map<String, dynamic> data,
  ) async {
    emit(state.copyWith(status: SubscriptionCubitStatus.loading));
    final result = await _repository.assignPlanToBranch(branchId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SubscriptionCubitStatus.error,
        errorMessage: failure.message,
      )),
      (subscription) => emit(state.copyWith(
        status: SubscriptionCubitStatus.success,
        activeSubscription: subscription,
      )),
    );
  }

  Future<void> updateSubscription(
    String subscriptionId,
    Map<String, dynamic> data,
  ) async {
    emit(state.copyWith(status: SubscriptionCubitStatus.loading));
    final result = await _repository.updateSubscription(subscriptionId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SubscriptionCubitStatus.error,
        errorMessage: failure.message,
      )),
      (subscription) => emit(state.copyWith(
        status: SubscriptionCubitStatus.success,
        activeSubscription: subscription,
      )),
    );
  }

  Future<void> renewSubscription(
    String subscriptionId,
    Map<String, dynamic> data,
  ) async {
    emit(state.copyWith(status: SubscriptionCubitStatus.loading));
    final result = await _repository.renewSubscription(subscriptionId, data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SubscriptionCubitStatus.error,
        errorMessage: failure.message,
      )),
      (subscription) => emit(state.copyWith(
        status: SubscriptionCubitStatus.success,
        activeSubscription: subscription,
      )),
    );
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    emit(state.copyWith(status: SubscriptionCubitStatus.loading));
    final result = await _repository.cancelSubscription(subscriptionId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SubscriptionCubitStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.clearSubscription().copyWith(
        status: SubscriptionCubitStatus.success,
      )),
    );
  }
}
