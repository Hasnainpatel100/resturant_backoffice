import 'package:equatable/equatable.dart';

class FeedbackModel extends Equatable {
  final String id;
  final String customerName;
  final String phone;
  final double rating;
  final String comment;
  final DateTime date;
  final String branchId;
  final String? billId;

  const FeedbackModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.rating,
    required this.comment,
    required this.date,
    required this.branchId,
    this.billId,
  });

  @override
  List<Object?> get props => [
        id,
        customerName,
        phone,
        rating,
        comment,
        date,
        branchId,
        billId,
      ];
}
