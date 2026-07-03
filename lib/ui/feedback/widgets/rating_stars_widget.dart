import 'package:flutter/material.dart';

class RatingStarsWidget extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  const RatingStarsWidget({
    super.key,
    required this.rating,
    this.size = 20,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData iconData;
        if (index < rating.floor()) {
          iconData = Icons.star;
        } else if (index < rating && rating % 1 != 0) {
          iconData = Icons.star_half;
        } else {
          iconData = Icons.star_border;
        }

        return Icon(
          iconData,
          color: color,
          size: size,
        );
      }),
    );
  }
}
