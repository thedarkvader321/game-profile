import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/games/screens/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: GameTrackerApp()));
}

class GameTrackerApp extends ConsumerWidget {
  const GameTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeState = ref.watch(themeProvider);
    return MaterialApp(
      title: 'GameTracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(themeState.primary),
      home: authState.when(
        data: (user) => user != null ? const HomeScreen() : const LoginScreen(),
        loading: () => const _SplashScreen(),
        error: (_, _) => const LoginScreen(),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF080C18),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF4A7DFF)),
      ),
    );
  }
}
