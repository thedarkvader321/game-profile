import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/game_model.dart';

class CategoryBadge extends StatelessWidget {
  final GameCategory category;

  const CategoryBadge({super.key, required this.category});

  Color get _color {
    switch (category) {
      case GameCategory.inProgress:
        return AppColors.statusPlaying;
      case GameCategory.toPlay:
        return AppColors.statusPending;
      case GameCategory.completed:
        return AppColors.statusCompleted;
      case GameCategory.all:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withAlpha(36),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withAlpha(90), width: 0.8),
      ),
      child: Text(
        category.displayName,
        style: GoogleFonts.nunitoSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
