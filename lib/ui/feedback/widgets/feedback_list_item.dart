import 'package:flutter/material.dart';
import '../../../data/models/feedback_model.dart';
import 'package:intl/intl.dart';
import 'rating_stars_widget.dart';

class FeedbackListItem extends StatelessWidget {
  final FeedbackModel feedback;
  final VoidCallback onTap;

  const FeedbackListItem({
    super.key,
    required this.feedback,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              child: Text(
                feedback.customerName.isNotEmpty ? feedback.customerName[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        feedback.customerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(feedback.date),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      RatingStarsWidget(rating: feedback.rating, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '(${feedback.rating})',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      if (feedback.billId != null) ...[
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Bill: ${feedback.billId}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 11),
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feedback.comment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
