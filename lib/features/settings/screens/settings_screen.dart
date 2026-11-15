import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/image_utils.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/screens/login_screen.dart';
import '../../friends/screens/friends_screen.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/widgets/edit_profile_bottom_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileStreamProvider).value;
    final themeState = ref.watch(themeProvider);
    final bytes = ImageUtils.decodeBase64(profile?.photoBase64);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configuración',
          style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Profile card
          _SectionLabel(label: 'Perfil'),
          const SizedBox(height: 8),
          _Tile(
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surfaceElevated,
              backgroundImage: bytes != null ? MemoryImage(bytes) : null,
              child: bytes == null
                  ? const Icon(Icons.person_rounded,
                      color: AppColors.textMuted, size: 20)
                  : null,
            ),
            title: profile?.displayName ?? 'Usuario',
            subtitle: 'Ver y editar perfil',
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => EditProfileBottomSheet(user: profile),
            ),
          ),

          const SizedBox(height: 24),

          // Amigos
          _SectionLabel(label: 'Social'),
          const SizedBox(height: 8),
          _Tile(
            leading: const Icon(Icons.people_outline_rounded,
                color: AppColors.primary, size: 22),
            title: 'Amigos',
            subtitle: 'Solicitudes y comparar juegos',
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
            onTap: () => Navigator.push(
              context,
              _fadeRoute(const FriendsScreen()),
            ),
          ),

          const SizedBox(height: 24),

          // Theme
          _SectionLabel(label: 'Apariencia'),
          const SizedBox(height: 8),
          _ThemePicker(state: themeState),

          const SizedBox(height: 24),

          // Logout
          _SectionLabel(label: 'Cuenta'),
          const SizedBox(height: 8),
          _Tile(
            leading: const Icon(Icons.logout_rounded,
                color: AppColors.error, size: 22),
            title: 'Cerrar sesión',
            subtitle: '',
            titleColor: AppColors.error,
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content:
                      const Text('¿Estás seguro de que quieres cerrar sesión?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Cerrar sesión',
                            style: TextStyle(color: AppColors.error))),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => const LoginScreen(),
                      transitionDuration: Duration.zero,
                    ),
                    (_) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ThemePicker extends ConsumerWidget {
  final ThemeState state;
  const _ThemePicker({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(themeProvider.notifier);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _ThemeOption(
            icon: Icons.dark_mode_outlined,
            label: 'Oscuro',
            subtitle: 'Tema por defecto',
            selected: state.mode == AppThemeMode.dark,
            onTap: () => notifier.setMode(AppThemeMode.dark),
          ),
          Divider(height: 1, color: AppColors.border),
          _ThemeOption(
            icon: Icons.brightness_1_rounded,
            label: 'AMOLED',
            subtitle: 'Fondos negros puros',
            selected: state.mode == AppThemeMode.amoled,
            onTap: () => notifier.setMode(AppThemeMode.amoled),
          ),
          Divider(height: 1, color: AppColors.border),
          _ThemeOption(
            icon: Icons.palette_outlined,
            label: 'Personalizado',
            subtitle: 'Elige tu color de acento',
            selected: state.mode == AppThemeMode.custom,
            onTap: () => notifier.setMode(AppThemeMode.custom),
          ),
          if (state.mode == AppThemeMode.custom) ...[
            Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: _ColorGrid(
                selected: state.customColor,
                onPick: notifier.setCustomColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.textMuted,
                size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.nunitoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: GoogleFonts.nunitoSans(
                            fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  final Color selected;
  final void Function(Color) onPick;

  const _ColorGrid({required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: kThemePresetColors.map((c) {
        final isSelected = selected.toARGB32() == c.toARGB32();
        return GestureDetector(
          onTap: () => onPick(c),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: c.withAlpha(100), blurRadius: 8)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _Tile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback onTap;

  const _Tile({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: titleColor ?? AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(subtitle,
                          style: GoogleFonts.nunitoSans(
                              fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.nunitoSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textMuted,
          letterSpacing: 1.2),
    );
  }
}

Route<T> _fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 200),
    );
