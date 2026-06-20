import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/branch_plan_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum BranchPlanStatus { initial, loading, loaded, success, error }

class StateBranchPlan extends Equatable {
  final BranchPlanStatus status;
  final List<BranchPlanModel> history;
  final MetaData? meta;
  final String? errorMessage;

  const StateBranchPlan({
    this.status = BranchPlanStatus.initial,
    this.history = const [],
    this.meta,
    this.errorMessage,
  });

  StateBranchPlan copyWith({
    BranchPlanStatus? status,
    List<BranchPlanModel>? history,
    MetaData? meta,
    String? errorMessage,
  }) {
    return StateBranchPlan(
      status: status ?? this.status,
      history: history ?? this.history,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, history, meta, errorMessage];
}
