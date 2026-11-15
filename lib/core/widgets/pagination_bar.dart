import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Controles de paginación: anterior / "Página X de Y" / siguiente.
class PaginationBar extends StatelessWidget {
  final int page; // base 0
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PaginationBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          key: const Key('pagination_previous'),
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
          color: AppColors.primary,
          disabledColor: AppColors.border,
          tooltip: 'Página anterior',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Página ${page + 1} de $totalPages',
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        IconButton(
          key: const Key('pagination_next'),
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
          color: AppColors.primary,
          disabledColor: AppColors.border,
          tooltip: 'Página siguiente',
        ),
      ],
    );
  }
}
