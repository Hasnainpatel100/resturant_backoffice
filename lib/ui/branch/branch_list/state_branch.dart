import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/branch_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum BranchStatus { initial, loading, loaded, success, error }

class StateBranch extends Equatable {
  final BranchStatus status;
  final BranchModel? branch;
  final List<BranchBasicModel> branches;
  final MetaData? meta;
  final Map<String, dynamic>? planAssignment;
  final List<Map<String, dynamic>> planHistory;
  final String? errorMessage;

  const StateBranch({
    this.status = BranchStatus.initial,
    this.branch,
    this.branches = const [],
    this.meta,
    this.planAssignment,
    this.planHistory = const [],
    this.errorMessage,
  });

  StateBranch copyWith({
    BranchStatus? status,
    BranchModel? branch,
    List<BranchBasicModel>? branches,
    MetaData? meta,
    Map<String, dynamic>? planAssignment,
    List<Map<String, dynamic>>? planHistory,
    String? errorMessage,
  }) {
    return StateBranch(
      status: status ?? this.status,
      branch: branch ?? this.branch,
      branches: branches ?? this.branches,
      meta: meta ?? this.meta,
      planAssignment: planAssignment ?? this.planAssignment,
      planHistory: planHistory ?? this.planHistory,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, branch, branches, meta, planAssignment, planHistory, errorMessage];
}