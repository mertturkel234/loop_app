import 'package:flutter/material.dart';
import 'app_state.dart';

/// Widget ağacına [AppState] sağlayan InheritedNotifier.
///
/// Kullanım:
/// ```dart
/// // Okuma + rebuild:
/// final state = AppStateProvider.of(context);
///
/// // Sadece okuma (rebuild yok):
/// final state = AppStateProvider.read(context);
/// ```
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  /// Context'ten AppState'e erişir ve widget rebuild'ı dinler.
  static AppState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'AppStateProvider bulunamadı!');
    return provider!.notifier!;
  }

  /// Context'ten AppState'e erişir, rebuild dinlemez (performans).
  static AppState read(BuildContext context) {
    final provider =
        context.findAncestorWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'AppStateProvider bulunamadı!');
    return provider!.notifier!;
  }
}
