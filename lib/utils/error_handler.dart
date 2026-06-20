import 'package:dio/dio.dart';

class AppErrorHandler {
  static String format(dynamic error) {
    if (error is String) return error;

    // ── DioException: read the actual server response body first ──────────
    if (error is DioException) {
      // 1. Try the structured error body: { "error": { "message": "..." } }
      final data = error.response?.data;
      if (data is Map) {
        final serverMessage =
            data['error']?['message'] ??   // { "error": { "message": "..." } }
                data['message'];               // { "message": "..." }
        if (serverMessage is String && serverMessage.isNotEmpty) {
          return serverMessage;
        }
      }

      // 2. Fallback to HTTP status description
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        return _httpStatusMessage(statusCode);
      }

      // 3. Network-level errors (no response at all)
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Request timed out. Please try again.';
        case DioExceptionType.connectionError:
          return 'Unable to connect. Check your internet connection.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        default:
          break;
      }
    }

    // ── Generic fallback ──────────────────────────────────────────────────
    try {
      if (error?.message != null) return error.message as String;
      if (error?.toString() != null) return error.toString();
    } catch (_) {}

    return 'An unexpected error occurred';
  }

  static String _httpStatusMessage(int code) {
    switch (code) {
      case 400: return 'Bad request. Please check your input.';
      case 401: return 'Unauthorised. Please log in again.';
      case 403: return 'You do not have permission to perform this action.';
      case 404: return 'The requested resource was not found.';
      case 409: return 'A conflict occurred. The resource may already exist.';
      case 422: return 'Validation failed. Please check your input.';
      case 500: return 'Internal server error. Please try again later.';
      case 503: return 'Service unavailable. Please try again later.';
      default:  return 'Request failed with status $code.';
    }
  }
}
