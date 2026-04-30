import 'dart:async';
import 'package:fpdart/fpdart.dart';
import '../config/app_config.dart' as config;
import '../utils/utils.dart';
import '../data/models/user_model.dart';
import 'secure_storage_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final StreamController<AppUser?> _authStateController =
      StreamController<AppUser?>.broadcast();

  Stream<AppUser?> get authStateChanges => _authStateController.stream;

  FutureEither<AppUser> login({
    required String username,
    required String pin,
    String deviceId = '',
    String brandId = '',
  }) async {
    return runTask(() async {
      final response = await config.AppConfig.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'username': username,
          'pin': pin,
          if (deviceId.isNotEmpty) 'deviceId': deviceId,
          if (brandId.isNotEmpty) 'brandId': brandId,
        },
      );

      final data = response.data!['data'] as Map<String, dynamic>;

      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;

      final user = AppUser(
        id: data['userId'] as String? ?? '',
        email: data['username'] as String? ?? username,
        name: '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
        brandId: data['brandId'] as String? ?? '',
        branchId: data['branchId'] as String? ?? '',
        role: data['role'] as String? ?? '',
        userType: data['userType'] as String? ?? '',
        permissions: (data['permissions'] as List<dynamic>?)?.cast<String>() ?? [],
      );

      config.AppConfig.setAuthData(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: user.id,
        brandId: user.brandId,
        branchId: user.branchId,
        role: user.role,
        userType: user.userType,
      );

      await SecureStorageService.instance.write('accessToken', accessToken);
      await SecureStorageService.instance.write('refreshToken', refreshToken);
      await SecureStorageService.instance.write('userId', user.id);

      _authStateController.add(user);
      return user;
    }, requiresNetwork: true);
  }

  FutureEither<void> logout() async {
    // Clear tokens locally — no need to call logout API
    // Tokens expire server-side anyway, and clearing locally is sufficient
    config.AppConfig.clearAuthData();
    await SecureStorageService.instance.deleteAll();
    _authStateController.add(null);
    return right(null);
  }

  FutureEither<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return runTask(() async {
      final response = await config.AppConfig.dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final data = response.data!['data'] as Map<String, dynamic>;

      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;

      final user = AppUser(
        id: data['userId'] as String? ?? '',
        email: data['email'] as String? ?? email,
        name: data['name'] as String? ?? name,
        brandId: data['brandId'] as String? ?? '',
        branchId: data['branchId'] as String? ?? '',
        role: data['role'] as String? ?? '',
        userType: data['userType'] as String? ?? '',
        permissions: (data['permissions'] as List<dynamic>?)?.cast<String>() ?? [],
      );

      config.AppConfig.setAuthData(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: user.id,
        brandId: user.brandId,
        branchId: user.brandId,
        role: user.role,
        userType: user.userType,
      );

      await SecureStorageService.instance.write('accessToken', accessToken);
      await SecureStorageService.instance.write('refreshToken', refreshToken);
      await SecureStorageService.instance.write('userId', user.id);

      _authStateController.add(user);
      return user;
    }, requiresNetwork: true);
  }

  FutureEither<void> forgotPassword({required String email}) async {
    return runTask(() async {
      await config.AppConfig.dio.post<Map<String, dynamic>>(
        '/auth/forgot-password',
        data: {'email': email},
      );
    }, requiresNetwork: true);
  }

  FutureEither<AppUser?> checkStateAuth() async {
    final accessTokenResult = await SecureStorageService.instance.read('accessToken');
    final refreshTokenResult = await SecureStorageService.instance.read('refreshToken');

    final accessToken = accessTokenResult.fold((_) => '', (v) => v ?? '');
    final refreshToken = refreshTokenResult.fold((_) => '', (v) => v ?? '');

    if (accessToken.isEmpty) {
      return right(null);
    }

    config.AppConfig.setAuthData(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return right(null);
  }

  void dispose() {
    _authStateController.close();
  }
}
