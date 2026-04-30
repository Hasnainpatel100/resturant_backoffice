import 'package:back_office/imports/core_imports.dart';
import 'package:back_office/data/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService = AuthService.instance;

  @override
  Stream<AppUser?> get onStateAuthChanged {
    return _authService.authStateChanges.map((user) => user);
  }

  @override
  FutureEither<AppUser> login({
    required String email,
    required String password,
  }) async {
    final result = await _authService.login(
      username: email,
      pin: password,
    );

    return result.fold(
      (failure) => left(failure),
      (user) => right(user),
    );
  }

  @override
  FutureEither<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return _authService.signUp(
      name: name,
      email: email,
      password: password,
    );
  }

  @override
  FutureEither<void> forgotPassword({required String email}) async {
    return _authService.forgotPassword(email: email);
  }

  @override
  FutureEither<void> logout() {
    return _authService.logout();
  }

  @override
  FutureEither<AppUser?> checkStateAuth() {
    return _authService.checkStateAuth();
  }
}
