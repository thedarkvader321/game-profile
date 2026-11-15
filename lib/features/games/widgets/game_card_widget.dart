import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../models/game_model.dart';
import 'category_badge.dart';

class GameCardWidget extends StatelessWidget {
  final GameModel game;
  final VoidCallback onEdit;

  const GameCardWidget({super.key, required this.game, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final bytes = ImageUtils.decodeBase64(game.imageBase64);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        splashColor: AppColors.primary.withAlpha(25),
        highlightColor: AppColors.primary.withAlpha(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image — ocupa todo el espacio disponible
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    bytes != null
                        ? Image.memory(bytes, fit: BoxFit.cover)
                        : Container(
                            color: AppColors.surfaceElevated,
                            child: const Icon(
                              Icons.sports_esports_outlined,
                              color: AppColors.textMuted,
                              size: 42,
                            ),
                          ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.background.withAlpha(200),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info — altura fija, nunca desborda sin importar cuánto texto haya
              SizedBox(
                height: 76,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          game.nombre,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CategoryBadge(category: game.categoria),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
