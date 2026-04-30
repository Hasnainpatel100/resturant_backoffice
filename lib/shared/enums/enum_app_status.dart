/// Represents the async lifecycle state of any data/operation.
///
/// Use this in state classes across all state management patterns (Riverpod,
/// Bloc, Provider, etc.) to replace ad-hoc boolean flags with a clean enum.
///
/// Usage:
/// ```dart
/// // In your state class
/// AppStatus status = AppStatus.initial;
///
/// // In your UI
/// switch (status) {
///   AppStatus.initial => const SizedBox.shrink(),
///   AppStatus.loading => const AppLoading(),
///   AppStatus.success => YourContentWidget(),
///   AppStatus.failure => AppErrorWidget(onRetry: _load),
/// }
/// ```
enum EnumAppStatus {
  /// No operation started yet — initial empty state.
  initial,

  /// Async operation in progress.
  loading,

  /// Operation completed successfully.
  success,

  /// Operation failed.
  failure,
}

/// Extension helpers for [EnumAppStatus].
extension AppStatusX on EnumAppStatus {
  bool get isInitial  => this == EnumAppStatus.initial;
  bool get isLoading  => this == EnumAppStatus.loading;
  bool get isSuccess  => this == EnumAppStatus.success;
  bool get isFailure  => this == EnumAppStatus.failure;
  bool get isDone     => isSuccess || isFailure;
}
