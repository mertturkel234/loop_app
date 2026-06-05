import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'screens/onboarding_screen.dart';
import 'state/app_state.dart';
import 'state/app_state_provider.dart';

void main() {
  runApp(const LooApp());
}

/// Uygulamanın kök widget'ı.
/// AppState'i yönetir ve MaterialApp.themeMode'u dinamik olarak bağlar.
class LooApp extends StatefulWidget {
  const LooApp({super.key});

  @override
  State<LooApp> createState() => _LooAppState();
}

class _LooAppState extends State<LooApp> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    // Tema değiştiğinde MaterialApp yeniden build edilir.
    _appState.addListener(_onStateChanged);
  }

  void _onStateChanged() => setState(() {});

  @override
  void dispose() {
    _appState.removeListener(_onStateChanged);
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      state: _appState,
      child: MaterialApp(
        title: 'LOOP — Kurumsal Yönetim',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _appState.themeMode,
        home: const OnboardingScreen(),
      ),
    );
  }
}
