import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../models/friend_model.dart';

class FriendCardWidget extends StatelessWidget {
  final FriendModel friend;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FriendCardWidget({
    super.key,
    required this.friend,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = ImageUtils.decodeBase64(friend.photoBase64);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.surfaceElevated,
                backgroundImage: bytes != null ? MemoryImage(bytes) : null,
                child: bytes == null
                    ? const Icon(Icons.person_rounded,
                        color: AppColors.textMuted, size: 22)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.displayName,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Toca para comparar juegos',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.person_remove_outlined,
                    color: AppColors.textMuted, size: 18),
                onPressed: onRemove,
                tooltip: 'Eliminar amigo',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
