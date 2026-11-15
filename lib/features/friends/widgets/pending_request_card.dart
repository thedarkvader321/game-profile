import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../models/friend_request_model.dart';

class PendingRequestCard extends StatelessWidget {
  final FriendRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const PendingRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = ImageUtils.decodeBase64(request.senderPhotoBase64);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withAlpha(80)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.surfaceElevated,
            backgroundImage: bytes != null ? MemoryImage(bytes) : null,
            child: bytes == null
                ? const Icon(Icons.person_rounded,
                    color: AppColors.textMuted, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.senderDisplayName,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Quiere ser tu amigo',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionBtn(
                icon: Icons.close_rounded,
                color: AppColors.error,
                onTap: onReject,
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                icon: Icons.check_rounded,
                color: AppColors.statusCompleted,
                onTap: onAccept,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          shape: BoxShape.circle,
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
