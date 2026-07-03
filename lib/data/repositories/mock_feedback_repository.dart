import 'package:fpdart/fpdart.dart';
import '../models/feedback_model.dart';

class MockFeedbackRepository {
  // Dummy data
  final List<FeedbackModel> _dummyFeedbacks = [
    FeedbackModel(
      id: 'fb-1',
      customerName: 'John Doe',
      phone: '+1234567890',
      rating: 5,
      comment: 'Excellent food and quick service!',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      branchId: 'branch-1',
      billId: 'bill-101',
    ),
    FeedbackModel(
      id: 'fb-2',
      customerName: 'Jane Smith',
      phone: '+0987654321',
      rating: 2,
      comment: 'Food was cold when served. Very disappointed.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      branchId: 'branch-2',
      billId: 'bill-102',
    ),
    FeedbackModel(
      id: 'fb-3',
      customerName: 'Mike Johnson',
      phone: '+1122334455',
      rating: 4,
      comment: 'Good ambiance but slightly overpriced.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      branchId: 'branch-1',
      billId: 'bill-103',
    ),
    FeedbackModel(
      id: 'fb-4',
      customerName: 'Alice Williams',
      phone: '+5544332211',
      rating: 1,
      comment: 'Worst experience ever. The staff was rude.',
      date: DateTime.now().subtract(const Duration(days: 3)),
      branchId: 'branch-3',
      billId: 'bill-104',
    ),
  ];

  Future<Either<String, List<FeedbackModel>>> getFeedbacks() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      return Right(_dummyFeedbacks);
    } catch (e) {
      return Left('Failed to fetch feedbacks: $e');
    }
  }

  Future<Either<String, FeedbackModel>> getFeedbackById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final feedback = _dummyFeedbacks.firstWhere((fb) => fb.id == id);
      return Right(feedback);
    } catch (e) {
      return const Left('Feedback not found');
    }
  }
}
