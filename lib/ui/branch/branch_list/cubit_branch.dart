import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/branch_repository.dart';
import 'state_branch.dart';

class CubitBranch extends Cubit<StateBranch> {
  final BranchRepository _repository;

  CubitBranch({required BranchRepository repository})
      : _repository = repository,
        super(const StateBranch());

  Future<void> loadBranch(String branchId) async {
    emit(state.copyWith(status: BranchStatus.loading));
    final result = await _repository.getBranch(branchId);
    result.fold(
      (failure) => emit(state.copyWith(status: BranchStatus.error, errorMessage: failure.message)),
      (branch) => emit(state.copyWith(status: BranchStatus.loaded, branch: branch)),
    );
  }

  Future<void> loadBranches(String brandId, {int page = 1, int limit = 20}) async {
    emit(state.copyWith(status: BranchStatus.loading));
    final result = await _repository.getBranchesByBrand(brandId, page: page, limit: limit);
    result.fold(
      (failure) => emit(state.copyWith(status: BranchStatus.error, errorMessage: failure.message)),
      (response) => emit(state.copyWith(
        status: BranchStatus.loaded,
        branches: response.items,
        meta: response.meta,
      )),
    );
  }

  Future<void> createBranch(String brandId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: BranchStatus.loading));
    final result = await _repository.createBranch(brandId, data);
    result.fold(
      (failure) => emit(state.copyWith(status: BranchStatus.error, errorMessage: failure.message)),
      (branch) => emit(state.copyWith(status: BranchStatus.success, branch: branch)),
    );
  }

  Future<void> updateBranch(String branchId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: BranchStatus.loading));
    final result = await _repository.updateBranch(branchId, data);
    result.fold(
      (failure) => emit(state.copyWith(status: BranchStatus.error, errorMessage: failure.message)),
      (branch) => emit(state.copyWith(status: BranchStatus.success, branch: branch)),
    );
  }

  Future<void> deleteBranch(String branchId) async {
    emit(state.copyWith(status: BranchStatus.loading));
    final result = await _repository.deleteBranch(branchId);
    result.fold(
      (failure) => emit(state.copyWith(status: BranchStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: BranchStatus.success, branch: null)),
    );
  }

  Future<void> assignPlan(String branchId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: BranchStatus.loading));
    final result = await _repository.assignPlan(branchId, data);
    result.fold(
      (failure) => emit(state.copyWith(status: BranchStatus.error, errorMessage: failure.message)),
      (plan) => emit(state.copyWith(status: BranchStatus.loaded, planAssignment: plan)),
    );
  }

  Future<void> loadPlanHistory(String branchId, {int page = 1, int limit = 20}) async {
    final result = await _repository.getPlanHistory(branchId, page: page, limit: limit);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (response) => emit(state.copyWith(planHistory: response.items)),
    );
  }
}