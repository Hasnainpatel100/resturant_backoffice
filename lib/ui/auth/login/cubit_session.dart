import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/auth_repository.dart';
import 'package:back_office/data/models/user_model.dart';
import 'state_session.dart';

class CubitSession extends Cubit<StateSession> {
  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _authSub;

  CubitSession({required AuthRepository repository})
      : _repository = repository,
        super(const StateSession.unknown()) {
    _init();
  }

  Future<void> _init() async {
    await checkSession();
    _listenToAuthChanges();
  }

  Future<void> checkSession() async {
    final result = await _repository.checkStateAuth();

    result.fold(
      (_) => emit(const StateSession.unauthenticated()),
      (user) {
        if (user != null) {
          emit(StateSession.authenticated(user));
        } else {
          emit(const StateSession.unauthenticated());
        }
      },
    );
  }

  void _listenToAuthChanges() {
    _authSub?.cancel();
    _authSub = _repository.onStateAuthChanged.listen((user) {
      if (user != null) {
        emit(StateSession.authenticated(user));
      } else {
        emit(const StateSession.unauthenticated());
      }
    });
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const StateSession.unauthenticated());
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
