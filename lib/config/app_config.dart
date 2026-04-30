import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/secure_storage_service.dart';
import '../utils/utils.dart';
import '../flavors.dart';

class AppConfig {
  AppConfig._();
  static late final Dio dio;
  static String _accessToken = '';
  static String _refreshToken = '';
  static String _userId = '';
  static String _brandId = '';
  static String _branchId = '';
  static String _role = '';
  static String _userType = '';

  static String get baseUrl => FlavorConfig.baseUrl;
  static String get flavor => FlavorConfig.name;
  static String get accessToken => _accessToken;
  static String get refreshToken => _refreshToken;
  static String get userId => _userId;
  static String get brandId => _brandId;
  static String get branchId => _branchId;
  static String get role => _role;
  static String get userType => _userType;

  static void setAuthData({
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? brandId,
    String? branchId,
    String? role,
    String? userType,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = userId ?? '';
    _brandId = brandId ?? '';
    _branchId = branchId ?? '';
    _role = role ?? '';
    _userType = userType ?? '';
  }

  static void clearAuthData() {
    _accessToken = '';
    _refreshToken = '';
    _userId = '';
    _brandId = '';
    _branchId = '';
    _role = '';
    _userType = '';
  }

  static Future<void> init() async {
    await dotenv.load(fileName: 'assets/.env');
    FlavorConfig.load(
      const String.fromEnvironment('FLAVOR', defaultValue: 'dev') == 'dev'
          ? Flavor.dev
          : const String.fromEnvironment('FLAVOR', defaultValue: 'dev') == 'staging'
              ? Flavor.staging
              : Flavor.prod,
    );

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(_AuthInterceptor());
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
      logPrint: (o) => AppLogger.info(o.toString()),
    ));
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppConfig.accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${AppConfig.accessToken}';
    }
    if (kDebugMode) {
      final queryParams = options.queryParameters.isNotEmpty ? '\n  Query: ${options.queryParameters}' : '';
      final dataStr = options.data != null ? '\n  Body: ${options.data}' : '';
      AppLogger.info(
        '🌐 [REQUEST] ${options.method} ${options.path}$queryParams$dataStr'
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final dataStr = response.data != null
          ? '\n  Response: ${_truncateString(response.data.toString(), 500)}'
          : '';
      AppLogger.success(
        '✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.path}$dataStr'
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      AppLogger.error(
        '❌ [ERROR] ${err.response?.statusCode ?? 'NETWORK'} ${err.requestOptions.path}\n'
        '  Message: ${err.message}\n'
        '  Response: ${err.response?.data}',
      );
    }

    if (err.response?.statusCode == 401 && AppConfig.refreshToken.isNotEmpty) {
      try {
        if (kDebugMode) AppLogger.info('🔄 [REFRESH] Attempting token refresh...');
        final refreshDio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
        final resp = await refreshDio.post(
          '/auth/refresh',
          data: {'refreshToken': AppConfig.refreshToken},
        );
        final data = resp.data;
        if (data['data'] != null) {
          final newAccess = data['data']['accessToken'] as String;
          final newRefresh = data['data']['refreshToken'] as String? ?? AppConfig.refreshToken;

          AppConfig.setAuthData(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );

          await SecureStorageService.instance.write('accessToken', newAccess);
          await SecureStorageService.instance.write('refreshToken', newRefresh);

          err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
          final retry = await Dio().fetch(err.requestOptions);
          if (kDebugMode) AppLogger.success('🔄 [REFRESH] Token refreshed successfully');
          return handler.resolve(retry);
        }
      } catch (e) {
        if (kDebugMode) AppLogger.error('🔄 [REFRESH] Token refresh failed', e);
        AppConfig.clearAuthData();
        await SecureStorageService.instance.deleteAll();
      }
    }
    handler.next(err);
  }

  String _truncateString(String str, int maxLen) {
    if (str.length <= maxLen) return str;
    return '${str.substring(0, maxLen)}... [truncated]';
  }
}
