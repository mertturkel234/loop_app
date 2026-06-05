import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

/// Henüz hazırlanmamış API detay sayfası.
class ApiDetailsPlaceholder extends StatelessWidget {
  const ApiDetailsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('API Dokümantasyonu',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryButton.withAlpha(15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryButton.withAlpha(60), width: 2),
              ),
              child: const Icon(Icons.api_rounded,
                  size: 32, color: AppColors.primaryButton),
            ),
            const SizedBox(height: 24),
            Text(
              'BU SAYFA SONRA\nYÜKLENECEKTİR',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  height: 1.3),
            ),
            const SizedBox(height: 12),
            Text(
              'API entegrasyon dokümantasyonu hazırlanıyor.',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
