import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/branch_subscription_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum SubscriptionCubitStatus { initial, loading, loaded, success, error }

class StateSubscription extends Equatable {
  final SubscriptionCubitStatus status;
  final BranchSubscriptionModel? activeSubscription;
  final List<BranchSubscriptionModel> history;
  final MetaData? meta;
  final String? errorMessage;

  const StateSubscription({
    this.status = SubscriptionCubitStatus.initial,
    this.activeSubscription,
    this.history = const [],
    this.meta,
    this.errorMessage,
  });

  StateSubscription copyWith({
    SubscriptionCubitStatus? status,
    BranchSubscriptionModel? activeSubscription,
    List<BranchSubscriptionModel>? history,
    MetaData? meta,
    String? errorMessage,
  }) {
    return StateSubscription(
      status: status ?? this.status,
      activeSubscription: activeSubscription ?? this.activeSubscription,
      history: history ?? this.history,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Clear activeSubscription (nullable field cannot be nulled via copyWith alone).
  StateSubscription clearSubscription() => StateSubscription(
        status: status,
        history: history,
        meta: meta,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, activeSubscription, history, meta, errorMessage];
}
