import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../data/models/feedback_model.dart';
import '../../../data/repositories/mock_feedback_repository.dart';
import '../widgets/rating_stars_widget.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class FeedbackDetailScreen extends StatelessWidget {
  final String feedbackId;

  const FeedbackDetailScreen({super.key, required this.feedbackId});

  @override
  Widget build(BuildContext context) {
    final repository = MockFeedbackRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text('common.feedback_details'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder(
        future: repository.getFeedbackById(feedbackId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.isRight()) {
            final feedback = snapshot.data!.getRight().toNullable()!;
            return _buildDetailContent(context, feedback);
          }

          return Center(child: Text('common.failed_to_load_feedback_detail'.tr()));
        },
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, FeedbackModel feedback) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                child: Text(
                  feedback.customerName.isNotEmpty ? feedback.customerName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.customerName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feedback.phone,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow('Rating', RatingStarsWidget(rating: feedback.rating, size: 24)),
          const SizedBox(height: 16),
          _buildInfoRow('Date', Text(DateFormat('MMMM dd, yyyy - hh:mm a').format(feedback.date))),
          const SizedBox(height: 16),
          if (feedback.billId != null)
            _buildInfoRow('Bill Number', Text(feedback.billId!, style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text('common.customer_comment'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              feedback.comment,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Placeholder for reply action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('common.reply_feature_coming_soon'.tr())),
                );
              },
              icon: const Icon(Icons.reply),
              label: Text('common.reply_to_customer'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, Widget content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(child: content),
      ],
    );
  }
}
