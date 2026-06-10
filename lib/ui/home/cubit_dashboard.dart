import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/bill_repository.dart';
import 'state_dashboard.dart';

class CubitDashboard extends Cubit<StateDashboard> {
  final BillRepository _repository;

  CubitDashboard({required BillRepository repository})
      : _repository = repository,
        super(StateDashboard(
          fromDate: DateTime.now().subtract(const Duration(days: 30)),
          toDate: DateTime.now(),
        ));

  Future<void> loadDashboard({
    String? branchId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final activeBranchId = branchId ?? state.selectedBranchId;
    final activeFrom = fromDate ?? state.fromDate;
    final activeTo = toDate ?? state.toDate;

    if (activeBranchId == null || activeBranchId.isEmpty) {
      emit(state.copyWith(
        status: DashboardStatus.branchSelectionRequired,
        fromDate: activeFrom,
        toDate: activeTo,
      ));
      return;
    }

    emit(state.copyWith(
      status: DashboardStatus.loading,
      selectedBranchId: activeBranchId,
      fromDate: activeFrom,
      toDate: activeTo,
    ));

    final fromMillis = activeFrom.millisecondsSinceEpoch;
    // Set toDate to end of that day (23:59:59) so that we capture all transactions of the last day.
    final toEndOfDay = DateTime(activeTo.year, activeTo.month, activeTo.day, 23, 59, 59, 999);
    final toMillis = toEndOfDay.millisecondsSinceEpoch;

    final result = await _repository.getDashboardReport(
      branchId: activeBranchId,
      fromDate: fromMillis,
      toDate: toMillis,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: failure.message,
      )),
      (report) => emit(state.copyWith(
        status: DashboardStatus.loaded,
        report: report,
      )),
    );
  }

  void changeBranch(String branchId) {
    loadDashboard(branchId: branchId);
  }

  void changeDateRange(DateTime from, DateTime to) {
    loadDashboard(fromDate: from, toDate: to);
  }
}
