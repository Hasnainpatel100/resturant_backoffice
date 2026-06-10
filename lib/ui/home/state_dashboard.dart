import 'package:equatable/equatable.dart';
import '../../data/models/dashboard_report_model.dart';

enum DashboardStatus { initial, loading, loaded, error, branchSelectionRequired }

class StateDashboard extends Equatable {
  final DashboardStatus status;
  final DashboardReportModel? report;
  final String? selectedBranchId;
  final DateTime fromDate;
  final DateTime toDate;
  final String? errorMessage;

  const StateDashboard({
    this.status = DashboardStatus.initial,
    this.report,
    this.selectedBranchId,
    required this.fromDate,
    required this.toDate,
    this.errorMessage,
  });

  StateDashboard copyWith({
    DashboardStatus? status,
    DashboardReportModel? report,
    String? selectedBranchId,
    DateTime? fromDate,
    DateTime? toDate,
    String? errorMessage,
  }) {
    return StateDashboard(
      status: status ?? this.status,
      report: report ?? this.report,
      selectedBranchId: selectedBranchId ?? this.selectedBranchId,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        report,
        selectedBranchId,
        fromDate,
        toDate,
        errorMessage,
      ];
}
