import 'package:flutter/material.dart';

/// Uygulamanın tüm renk sabitlerini içeren sınıf.
/// Koyu lacivert & teal renk paleti + aydınlık mod sabitleri.
class AppColors {
  AppColors._();

  // ════════════════════════════════════════════════════════════════════════════
  // DARK MODE SABİTLERİ
  // ════════════════════════════════════════════════════════════════════════════

  // ── Arka plan ───────────────────────────────────────────────────────────────
  /// En derin arka plan: #0B1120
  static const Color backgroundDeep   = Color(0xFF0B1120);

  /// Kart / modal arka planı: #111E32
  static const Color cardBackground   = Color(0xFF111E32);

  /// Input alanı arka planı: #162035
  static const Color inputBackground  = Color(0xFF162035);

  // ── Kenarlık ────────────────────────────────────────────────────────────────
  /// Kart kenarlığı (yarı şeffaf mavi-beyaz)
  static const Color cardBorder       = Color(0x33557ABA);

  /// Input kenarlığı
  static const Color inputBorder      = Color(0xFF1E2E4A);

  /// Input odak kenarlığı (teal)
  static const Color inputFocusBorder = Color(0xFF4DBFB0);

  // ── Metin ───────────────────────────────────────────────────────────────────
  /// Birincil beyaz metin
  static const Color textPrimary      = Color(0xFFFFFFFF);

  /// İkincil soluk mavi-gri metin
  static const Color textSecondary    = Color(0xFFAABDD8);

  /// Label metni (küçük büyük harf etiketler)
  static const Color textLabel        = Color(0xFF7A9CC0);

  /// Input placeholder metni
  static const Color textPlaceholder  = Color(0xFF3D5A7A);

  /// Teal vurgu metni
  static const Color textAccent       = Color(0xFF4DBFB0);

  /// Koyu buton metni (teal buton üzerindeki koyu yazı)
  static const Color textOnButton     = Color(0xFF0D1E30);

  // ════════════════════════════════════════════════════════════════════════════
  // LIGHT MODE SABİTLERİ
  // ════════════════════════════════════════════════════════════════════════════

  /// Açık arka plan
  static const Color lightBackground      = Color(0xFFF0F4F8);

  /// Açık kart / modal arka planı
  static const Color lightCard            = Color(0xFFFFFFFF);

  /// Açık kenarlık
  static const Color lightBorder         = Color(0xFFCBD6E2);

  /// Açık birincil metin (koyu lacivert)
  static const Color lightTextPrimary    = Color(0xFF102A43);

  /// Açık ikincil metin
  static const Color lightTextSecondary  = Color(0xFF334E68);

  /// Açık label metni
  static const Color lightTextLabel      = Color(0xFF627D98);

  /// Açık placeholder metni
  static const Color lightTextPlaceholder= Color(0xFF9FB3C8);

  // ════════════════════════════════════════════════════════════════════════════
  // ORTAK (BRAND) RENKLERİ
  // ════════════════════════════════════════════════════════════════════════════

  /// Ana aksiyon butonu: teal/yeşil-mavi #4DBFB0
  static const Color primaryButton      = Color(0xFF4DBFB0);

  /// Buton hover tonu (biraz daha açık)
  static const Color primaryButtonHover = Color(0xFF63CBBF);

  /// Koyu kaplama (overlay)
  static const Color overlayDark        = Color(0x80000000);

  // ── Semantic durum renkleri ─────────────────────────────────────────────────
  static const Color statusSuccess = Color(0xFF2ED573);
  static const Color statusWarning = Color(0xFFFFAA00);
  static const Color statusError   = Color(0xFFFF4757);
  static const Color statusInfo    = Color(0xFF9933FF);

  // ════════════════════════════════════════════════════════════════════════════
  // NEON (GÖREV KONTROL MERKEZİ) RENKLERİ
  // ════════════════════════════════════════════════════════════════════════════
  
  /// Parlayan Neon Teal (Marka Vurgusu ve Seçili Markerlar)
  static const Color neonTeal = Color(0xFF00FFFF);
  
  /// AI Optimize Rota Plazması
  static const Color neonBlue = Color(0xFF00C3FF);
  
  /// Anomali / Gecikme Plazması
  static const Color neonRed  = Color(0xFFFF0055);
  
  /// Süzülen Arka Plan Grid (Izgara) Rengi
  static const Color neonGrid = Color(0xFF1E3A5F);
}
