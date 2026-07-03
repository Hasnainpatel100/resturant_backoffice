import 'package:equatable/equatable.dart';

abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object> get props => [];
}

class LoadFeedbacksEvent extends FeedbackEvent {}

class FilterFeedbacksEvent extends FeedbackEvent {
  final double? rating;
  final String? branchId;

  const FilterFeedbacksEvent({this.rating, this.branchId});

  @override
  List<Object> get props => [
        if (rating != null) rating!,
        if (branchId != null) branchId!,
      ];
}
