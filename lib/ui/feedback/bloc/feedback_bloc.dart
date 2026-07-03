import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/feedback_model.dart';
import '../../../data/repositories/mock_feedback_repository.dart';
import 'feedback_event.dart';
import 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final MockFeedbackRepository repository;

  FeedbackBloc({required this.repository}) : super(FeedbackInitial()) {
    on<LoadFeedbacksEvent>(_onLoadFeedbacks);
    on<FilterFeedbacksEvent>(_onFilterFeedbacks);
  }

  Future<void> _onLoadFeedbacks(
    LoadFeedbacksEvent event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());
    final result = await repository.getFeedbacks();

    result.fold(
      (error) => emit(FeedbackError(error)),
      (feedbacks) {
        final averageRating = _calculateAverageRating(feedbacks);
        emit(FeedbackLoaded(
          feedbacks: feedbacks,
          filteredFeedbacks: feedbacks,
          averageRating: averageRating,
          totalFeedbacks: feedbacks.length,
        ));
      },
    );
  }

  void _onFilterFeedbacks(
    FilterFeedbacksEvent event,
    Emitter<FeedbackState> emit,
  ) {
    if (state is FeedbackLoaded) {
      final currentState = state as FeedbackLoaded;
      
      List<FeedbackModel> filtered = currentState.feedbacks;
      
      if (event.rating != null) {
        filtered = filtered.where((f) => f.rating == event.rating).toList();
      }
      
      if (event.branchId != null) {
        filtered = filtered.where((f) => f.branchId == event.branchId).toList();
      }

      emit(FeedbackLoaded(
        feedbacks: currentState.feedbacks,
        filteredFeedbacks: filtered,
        averageRating: currentState.averageRating,
        totalFeedbacks: currentState.totalFeedbacks,
        currentRatingFilter: event.rating,
        currentBranchFilter: event.branchId,
      ));
    }
  }

  double _calculateAverageRating(List<FeedbackModel> feedbacks) {
    if (feedbacks.isEmpty) return 0;
    final total = feedbacks.fold(0.0, (sum, f) => sum + f.rating);
    return total / feedbacks.length;
  }
}
