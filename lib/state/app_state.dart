import 'package:flutter/material.dart';

/// Global uygulama durumu — kullanıcı verisi + onboarding + tema.
/// ChangeNotifier kullanılarak tüm dinleyiciler otomatik rebuild edilir.
class AppState extends ChangeNotifier {
  // ── Kullanıcı Verisi ──────────────────────────────────────────────────────
  String _name = '';
  String _email = '';
  String _companyName = '';
  bool _onboardingComplete = false;

  // ── Tema ve Dil ──────────────────────────────────────────────────────────
  ThemeMode _themeMode = ThemeMode.dark;
  String _locale = 'TR';

  // ── Güvenlik ─────────────────────────────────────────────────────────────
  bool _twoFactorEnabled = false;

  // ── Bildirimler ───────────────────────────────────────────────────────────
  bool _pushNotifications = true;
  bool _emailNotifications = true;

  // ── Getters ───────────────────────────────────────────────────────────────
  String get name => _name;
  String get email => _email;
  String get companyName => _companyName;
  bool get onboardingComplete => _onboardingComplete;
  ThemeMode get themeMode => _themeMode;
  String get locale => _locale;
  bool get twoFactorEnabled => _twoFactorEnabled;
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;

  /// İsim baş harfleri avatar için.
  String get initials {
    final parts = _name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'L';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  // ── Setters ───────────────────────────────────────────────────────────────

  void updateProfile({required String name, required String email}) {
    _name = name;
    _email = email;
    notifyListeners();
  }

  void completeOnboarding({
    required String name,
    required String email,
    required String companyName,
  }) {
    _name = name;
    _email = email;
    _companyName = companyName;
    _onboardingComplete = true;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setLocale(String lang) {
    _locale = lang;
    notifyListeners();
  }

  void setTwoFactor(bool value) {
    _twoFactorEnabled = value;
    notifyListeners();
  }

  void setPushNotifications(bool value) {
    _pushNotifications = value;
    notifyListeners();
  }

  void setEmailNotifications(bool value) {
    _emailNotifications = value;
    notifyListeners();
  }
}
