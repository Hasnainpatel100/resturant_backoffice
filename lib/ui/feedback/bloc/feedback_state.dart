import 'package:equatable/equatable.dart';
import '../../../data/models/feedback_model.dart';

abstract class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object?> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackLoaded extends FeedbackState {
  final List<FeedbackModel> feedbacks;
  final List<FeedbackModel> filteredFeedbacks;
  final double averageRating;
  final int totalFeedbacks;
  
  // Active filters
  final double? currentRatingFilter;
  final String? currentBranchFilter;

  const FeedbackLoaded({
    required this.feedbacks,
    required this.filteredFeedbacks,
    required this.averageRating,
    required this.totalFeedbacks,
    this.currentRatingFilter,
    this.currentBranchFilter,
  });

  @override
  List<Object?> get props => [
        feedbacks,
        filteredFeedbacks,
        averageRating,
        totalFeedbacks,
        currentRatingFilter,
        currentBranchFilter,
      ];
}

class FeedbackError extends FeedbackState {
  final String message;

  const FeedbackError(this.message);

  @override
  List<Object> get props => [message];
}
