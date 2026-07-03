import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../data/repositories/mock_feedback_repository.dart';
import '../bloc/feedback_bloc.dart';
import '../bloc/feedback_event.dart';
import '../bloc/feedback_state.dart';
import '../widgets/feedback_list_item.dart';
import '../widgets/feedback_summary_card.dart';
import 'package:go_router/go_router.dart';

class FeedbackDashboardScreen extends StatelessWidget {
  const FeedbackDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedbackBloc(
        repository: MockFeedbackRepository(),
      )..add(LoadFeedbacksEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('common.feedback_management'.tr()),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.go('/feedback/settings');
              },
            ),
          ],
        ),
        body: BlocBuilder<FeedbackBloc, FeedbackState>(
          builder: (context, state) {
            if (state is FeedbackLoading || state is FeedbackInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FeedbackError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is FeedbackLoaded) {
              return Column(
                children: [
                  _buildDashboardHeader(context, state),
                  const Divider(),
                  _buildFilterBar(context, state),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.filteredFeedbacks.length,
                      itemBuilder: (context, index) {
                        final feedback = state.filteredFeedbacks[index];
                        return FeedbackListItem(
                          feedback: feedback,
                          onTap: () {
                            // Navigate to detail
                            context.go('/feedback/detail/${feedback.id}');
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDashboardHeader(BuildContext context, FeedbackLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: FeedbackSummaryCard(
              title: 'Average Rating',
              value: state.averageRating.toStringAsFixed(1),
              icon: Icons.star,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FeedbackSummaryCard(
              title: 'Total Feedbacks',
              value: state.totalFeedbacks.toString(),
              icon: Icons.comment,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, FeedbackLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text('common.filter_by_rating'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          DropdownButton<double?>(
            value: state.currentRatingFilter,
            hint: Text('common.all_ratings'.tr()),
            items: [
              DropdownMenuItem(value: null, child: Text('common.all_ratings'.tr())),
              DropdownMenuItem(value: 5, child: Text('common.5_stars'.tr())),
              DropdownMenuItem(value: 4, child: Text('common.4_stars'.tr())),
              DropdownMenuItem(value: 3, child: Text('common.3_stars'.tr())),
              DropdownMenuItem(value: 2, child: Text('common.2_stars'.tr())),
              DropdownMenuItem(value: 1, child: Text('common.1_star'.tr())),
            ],
            onChanged: (value) {
              context.read<FeedbackBloc>().add(FilterFeedbacksEvent(
                    rating: value,
                    branchId: state.currentBranchFilter,
                  ));
            },
          ),
        ],
      ),
    );
  }
}
