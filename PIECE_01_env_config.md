# Piece 1 — Environment & Config Setup

You are working on the backoffice Flutter app at `G:\WorkSpace\backendWorkSpace\rhpos-ktor-restaurant\backoffice`

This is a multi-tenant restaurant POS backoffice app (Android, iOS, Desktop, Web) using `flutter_bloc` + `go_router` + `dio`.

## Setup tasks:

### 1. Create `assets/.env`
```env
API_BASE_URL=http://172.29.208.1:8080
```

### 2. Modify `pubspec.yaml`
- Add `FLAVOR=dev` under `flutter.define` (create the section if missing)
- Add `.env` to the `assets:` list under `flutter.assets`

```yaml
flutter:
  define: "FLAVOR=dev"

  assets:
    - assets/
    - assets/images/
    - assets/icons/
    - assets/translations/
    - .env
    - assets/.env
```

### 3. Rewrite `lib/src/flavors.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Flavor { dev, staging, prod }

class FlavorConfig {
  FlavorConfig(this.flavor);
  final Flavor flavor;

  static late FlavorConfig current;

  static void load(Flavor flavor) {
    current = FlavorConfig(flavor);
  }

  static String get name => current.flavor.name;

  static final Map<String, String> _flavorUrls = {
    'dev': 'http://172.29.208.1:8080',
    'staging': 'http://staging-api:8080',
    'prod': 'https://api.rhpos.com',
  };

  static String get baseUrl {
    final envOverride = dotenv.get('API_BASE_URL', fallback: '');
    if (envOverride.isNotEmpty) return envOverride;
    return _flavorUrls[name] ?? _flavorUrls['dev']!;
  }
}
```

### 4. Rewrite `lib/src/config/app_config.dart`

```dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/utils.dart';
import '../services/secure_storage_service.dart';

class AppConfig {
  AppConfig._();
  static late final Dio dio;
  static String _accessToken = '';
  static String _refreshToken = '';

  static String get baseUrl => FlavorConfig.baseUrl;
  static String get flavor => FlavorConfig.name;

  static void setTokens({required String accessToken, required String refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  static void clearTokens() {
    _accessToken = '';
    _refreshToken = '';
  }

  static String get accessToken => _accessToken;
  static String get refreshToken => _refreshToken;

  static Future<void> init() async {
    await dotenv.load(fileName: 'assets/.env');
    FlavorConfig.load(const String.fromEnvironment('FLAVOR', defaultValue: 'dev') == 'dev'
        ? Flavor.dev
        : const String.fromEnvironment('FLAVOR', defaultValue: 'dev') == 'staging'
            ? Flavor.staging
            : Flavor.prod);

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
    AppLogger.info('🌐 [DIO] REQUEST[${options.method}] => PATH: ${options.path}');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && AppConfig.refreshToken.isNotEmpty) {
      try {
        final refreshDio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
        final resp = await refreshDio.post('/auth/refresh', data: {'refreshToken': AppConfig.refreshToken});
        final data = resp.data;
        final newAccess = data['accessToken'] as String;
        final newRefresh = data['refreshToken'] as String? ?? AppConfig.refreshToken;
        AppConfig.setTokens(accessToken: newAccess, refreshToken: newRefresh);
        await SecureStorageService.instance.write('accessToken', newAccess);
        await SecureStorageService.instance.write('refreshToken', newRefresh);
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
        final retry = await Dio().fetch(err.requestOptions);
        return handler.resolve(retry);
      } catch (_) {
        AppConfig.clearTokens();
        await SecureStorageService.instance.deleteAll();
        return handler.next(err);
      }
    }
    AppLogger.error('❌ [DIO] ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    handler.next(err);
  }
}
```

---

**Read all existing files before making changes. Preserve the existing code structure and only add/modify what is needed.**