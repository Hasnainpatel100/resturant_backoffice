import 'package:equatable/equatable.dart';
import 'package:back_office/data/models/bill_model.dart';
import 'package:back_office/data/models/api_response_model.dart';

enum StateBillStatus { initial, loading, loaded, error }

class StateBill extends Equatable {
  final StateBillStatus status;
  final List<BillModel> bills;
  final MetaData? meta;
  final BillModel? activeBill;
  final String? errorMessage;

  const StateBill({
    this.status = StateBillStatus.initial,
    this.bills = const [],
    this.meta,
    this.activeBill,
    this.errorMessage,
  });

  StateBill copyWith({
    StateBillStatus? status,
    List<BillModel>? bills,
    MetaData? meta,
    BillModel? activeBill,
    String? errorMessage,
  }) {
    return StateBill(
      status: status ?? this.status,
      bills: bills ?? this.bills,
      meta: meta ?? this.meta,
      activeBill: activeBill ?? this.activeBill,
      errorMessage: errorMessage, // Explicitly pass to clear out on success
    );
  }

  @override
  List<Object?> get props => [status, bills, meta, activeBill, errorMessage];
}
