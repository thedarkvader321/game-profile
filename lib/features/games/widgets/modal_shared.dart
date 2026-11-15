import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/game_model.dart';

class ModalHandle extends StatelessWidget {
  const ModalHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class ImageChip extends StatelessWidget {
  final String label;
  const ImageChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(230),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunitoSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Chips horizontales para selección de categoría.
class CategoryChipsField extends StatelessWidget {
  final GameCategory value;
  final void Function(GameCategory) onChanged;

  const CategoryChipsField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static Color _colorFor(GameCategory cat) => switch (cat) {
        GameCategory.inProgress => AppColors.statusPlaying,
        GameCategory.toPlay => AppColors.statusPending,
        GameCategory.completed => AppColors.statusCompleted,
        _ => AppColors.primary,
      };

  @override
  Widget build(BuildContext context) {
    const cats = [GameCategory.inProgress, GameCategory.toPlay, GameCategory.completed];
    return Row(
      children: cats.map((cat) {
        final selected = value == cat;
        final color = _colorFor(cat);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: cat == GameCategory.inProgress ? 0 : 4,
              right: cat == GameCategory.completed ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () => onChanged(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? color.withAlpha(35) : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? color : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      cat.displayName,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? color : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Dropdown de categoría usando DropdownMenu (M3) — sin deprecations.
class CategoryDropdownField extends StatelessWidget {
  final GameCategory value;
  final ValueChanged<GameCategory> onChanged;

  const CategoryDropdownField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _entries = [
    (cat: GameCategory.toPlay, label: 'Pendientes'),
    (cat: GameCategory.inProgress, label: 'Jugando'),
    (cat: GameCategory.completed, label: 'Completado'),
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<GameCategory>(
      initialSelection: value,
      expandedInsets: EdgeInsets.zero,
      label: Text(
        'Categoría',
        style: GoogleFonts.nunitoSans(color: AppColors.textMuted, fontSize: 14),
      ),
      leadingIcon: const Icon(Icons.category_outlined, color: AppColors.textMuted),
      textStyle: GoogleFonts.nunitoSans(color: AppColors.textPrimary, fontSize: 14),
      menuStyle: const MenuStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.surfaceElevated),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        elevation: WidgetStatePropertyAll(4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      dropdownMenuEntries: _entries
          .map(
            (e) => DropdownMenuEntry<GameCategory>(
              value: e.cat,
              label: e.label,
              style: ButtonStyle(
                foregroundColor:
                    const WidgetStatePropertyAll(AppColors.textPrimary),
              ),
            ),
          )
          .toList(),
      onSelected: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
