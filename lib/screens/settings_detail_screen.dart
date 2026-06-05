import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

class SettingsDetailScreen extends StatelessWidget {
  const SettingsDetailScreen({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: Text(title,
            style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_suggest_rounded, size: 64, color: AppColors.textSecondary.withAlpha(100)),
            const SizedBox(height: 16),
            Text('$title ayarları yakında eklenecek.',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
