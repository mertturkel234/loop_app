import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

/// "KURUMSAL E-POSTA" başlıklı e-posta giriş alanı.
///
/// Tasarımdan çıkarılan özellikler:
/// - Koyu [AppColors.inputBackground] dolgulu arka plan
/// - Küçük büyük-harf etiket (label dışarıda, üstte)
/// - Dolgu: 20 yatay, 18 dikey
/// - Odakta teal kenarlık
class EmailField extends StatefulWidget {
  const EmailField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  State<EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Etiket ──────────────────────────────────────────────────────────
        Text(
          'KURUMSAL E-POSTA',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
            color: _isFocused ? AppColors.textAccent : AppColors.textLabel,
          ),
        ),
        const SizedBox(height: 8),

        // ── Input ────────────────────────────────────────────────────────────
        Focus(
          onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
          child: TextFormField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: 'yonetici@firma.com',
            ),
          ),
        ),
      ],
    );
  }
}
