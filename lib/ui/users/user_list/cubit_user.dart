import 'package:back_office/data/repositories/branch_repository.dart';
import 'package:back_office/data/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/branch_repository_impl.dart';
import 'state_user.dart';

class CubitUser extends Cubit<StateUser> {
  final UserRepository _repository;
  final BranchRepository _branchRepository;

  CubitUser(
      {required UserRepository repository, BranchRepository? branchRepository})
      : _repository = repository,
        _branchRepository = branchRepository ?? BranchRepositoryImpl(),
        super(const StateUser());

  Future<void> loadUser(String userId) async {
    emit(state.copyWith(status: UserStatus.loading));
    final result = await _repository.getUser(userId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: UserStatus.error, errorMessage: failure.message)),
      (user) => emit(state.copyWith(status: UserStatus.loaded, user: user)),
    );
  }

  Future<void> loadUsers(String brandId, {int page = 1, int limit = 20}) async {
    emit(state.copyWith(status: UserStatus.loading));
    final result =
        await _repository.getUsersByBrand(brandId, page: page, limit: limit);
    result.fold(
      (failure) => emit(state.copyWith(
          status: UserStatus.error, errorMessage: failure.message)),
      (response) => emit(state.copyWith(
        status: UserStatus.loaded,
        users: response.items,
        meta: response.meta,
      )),
    );
  }

  Future<void> loadBranches(String brandId) async {
    final result =
        await _branchRepository.getBranchesByBrand(brandId, limit: 100);
    result.fold(
      (failure) => null,
      (response) => emit(state.copyWith(branches: response.items)),
    );
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    emit(state.copyWith(status: UserStatus.loading));
    final result = await _repository.createUser(data);
    result.fold(
      (failure) => emit(state.copyWith(
          status: UserStatus.error, errorMessage: failure.message)),
      (user) => emit(state.copyWith(status: UserStatus.loaded, user: user)),
    );
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    emit(state.copyWith(status: UserStatus.loading));
    final result = await _repository.updateUser(userId, data);
    result.fold(
      (failure) => emit(state.copyWith(
          status: UserStatus.error, errorMessage: failure.message)),
      (user) => emit(state.copyWith(status: UserStatus.loaded, user: user)),
    );
  }

  Future<void> assignUserBranch(String userId, String branchId) async {
    emit(state.copyWith(status: UserStatus.loading));
    final result = await _repository.updateUserBranch(userId, branchId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: UserStatus.error, errorMessage: failure.message)),
      (user) => emit(state.copyWith(status: UserStatus.loaded, user: user)),
    );
  }

  Future<void> deleteUser(String userId) async {
    emit(state.copyWith(status: UserStatus.loading));
    final result = await _repository.deleteUser(userId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: UserStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: UserStatus.loaded, user: null)),
    );
  }
}
