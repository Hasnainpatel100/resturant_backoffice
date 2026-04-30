import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/auth_repository.dart';
import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/imports/packages_imports.dart';
import 'state_auth.dart';

class CubitAuth extends Cubit<StateAuth> {
  final AuthRepository _repository;

  CubitAuth({required AuthRepository repository})
      : _repository = repository,
        super(const StateAuth.initial());

  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.login(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showToast(context, message: failure.message, status: 'error');
      },
      (user) {
        emit(state.copyWith(isLoading: false));
        if (context.mounted) {
          context.go(AppRoutes.home);
        }
      },
    );
  }

  Future<void> signUp({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.signUp(
      name: name,
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showToast(context, message: failure.message, status: 'error');
      },
      (user) {
        emit(state.copyWith(isLoading: false));
        showToast(context, message: 'auth.account_created'.tr(), status: 'success');
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      },
    );
  }

  Future<void> forgotPassword({
    required BuildContext context,
    required String email,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.forgotPassword(email: email);

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showToast(context, message: failure.message, status: 'error');
      },
      (_) {
        emit(state.copyWith(isLoading: false));
        showToast(context, message: 'auth.reset_link_sent'.tr(), status: 'success');
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      },
    );
  }
}
