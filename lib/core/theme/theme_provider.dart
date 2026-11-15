import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { dark, amoled, custom }

const List<Color> kThemePresetColors = [
  Color(0xFF4A7DFF),
  Color(0xFF8B5CF6),
  Color(0xFFEC4899),
  Color(0xFFEF4444),
  Color(0xFFF59E0B),
  Color(0xFF10B981),
  Color(0xFF06B6D4),
  Color(0xFF14B8A6),
];

class ThemeState {
  final AppThemeMode mode;
  final Color customColor;

  const ThemeState({
    this.mode = AppThemeMode.dark,
    this.customColor = const Color(0xFF4A7DFF),
  });

  Color get primary =>
      mode == AppThemeMode.custom ? customColor : const Color(0xFF4A7DFF);

  List<Color> get gradientFrom => switch (mode) {
        AppThemeMode.amoled => [
            Colors.black,
            const Color(0xFF030710),
            Colors.black
          ],
        _ => [
            const Color(0xFF05080F),
            const Color(0xFF0E1535),
            const Color(0xFF080C18)
          ],
      };

  List<Color> get gradientTo {
    if (mode == AppThemeMode.amoled) {
      return [Colors.black, const Color(0xFF02050D), Colors.black];
    }
    if (mode == AppThemeMode.custom) {
      return [
        const Color(0xFF060914),
        Color.alphaBlend(customColor.withAlpha(45), const Color(0xFF0E1535)),
        const Color(0xFF050A18),
      ];
    }
    return [
      const Color(0xFF060914),
      const Color(0xFF111F40),
      const Color(0xFF050A18)
    ];
  }

  ThemeState copyWith({AppThemeMode? mode, Color? customColor}) => ThemeState(
        mode: mode ?? this.mode,
        customColor: customColor ?? this.customColor,
      );
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState()) {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final idx = p.getInt('theme_mode') ?? 0;
    final col = p.getInt('theme_color') ?? 0xFF4A7DFF;
    state = ThemeState(
      mode: AppThemeMode.values[idx],
      customColor: Color(col),
    );
  }

  Future<void> setMode(AppThemeMode m) async {
    state = state.copyWith(mode: m);
    (await SharedPreferences.getInstance()).setInt('theme_mode', m.index);
  }

  Future<void> setCustomColor(Color c) async {
    state = state.copyWith(mode: AppThemeMode.custom, customColor: c);
    final p = await SharedPreferences.getInstance();
    p.setInt('theme_color', c.toARGB32());
    p.setInt('theme_mode', AppThemeMode.custom.index);
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((_) => ThemeNotifier());
