import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_office/data/repositories/bill_repository.dart';
import 'state_bill.dart';

class CubitBill extends Cubit<StateBill> {
  final BillRepository _repository;

  CubitBill({required BillRepository repository})
      : _repository = repository,
        super(const StateBill());

  Future<void> loadBills(String brandId, String branchId, {int page = 1, int limit = 20}) async {
    emit(state.copyWith(status: StateBillStatus.loading, errorMessage: null));
    final result = await _repository.getBills(brandId, branchId, page: page, limit: limit);
    result.fold(
      (failure) => emit(state.copyWith(
        status: StateBillStatus.error,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: StateBillStatus.loaded,
        bills: response.items,
        meta: response.meta,
        errorMessage: null,
      )),
    );
  }

  Future<void> loadBillDetail(String billId) async {
    emit(state.copyWith(status: StateBillStatus.loading, errorMessage: null));
    final result = await _repository.getBill(billId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: StateBillStatus.error,
        errorMessage: failure.message,
      )),
      (bill) => emit(state.copyWith(
        status: StateBillStatus.loaded,
        activeBill: bill,
        errorMessage: null,
      )),
    );
  }
}
