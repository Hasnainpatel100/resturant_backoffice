import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/plan_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum PlanStatus { initial, loading, loaded, success, error }

class StatePlan extends Equatable {
  final PlanStatus status;
  final List<PlanModel> plans;
  final PlanModel? selectedPlan;
  final MetaData? meta;
  final String? errorMessage;

  const StatePlan({
    this.status = PlanStatus.initial,
    this.plans = const [],
    this.selectedPlan,
    this.meta,
    this.errorMessage,
  });

  StatePlan copyWith({
    PlanStatus? status,
    List<PlanModel>? plans,
    PlanModel? selectedPlan,
    MetaData? meta,
    String? errorMessage,
  }) {
    return StatePlan(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  StatePlan clearSelected() => StatePlan(
        status: status,
        plans: plans,
        meta: meta,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, plans, selectedPlan, meta, errorMessage];
}
