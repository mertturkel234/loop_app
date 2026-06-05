import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

/// "ŞİFRE" başlıklı şifre giriş alanı.
///
/// Tasarımdan çıkarılan özellikler:
/// - Metin varsayılan olarak gizli (obscureText: true)
/// - Sağda göz ikonu → şifreyi göster/gizle
/// - Küçük büyük-harf etiket (label dışarıda, üstte)
/// - Odakta teal kenarlık
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Etiket ──────────────────────────────────────────────────────────
        Text(
          'ŞİFRE',
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
            obscureText: _obscureText,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              letterSpacing: 4,
            ),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: GoogleFonts.inter(
                color: AppColors.textPlaceholder,
                fontSize: 18,
                letterSpacing: 4,
              ),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscureText = !_obscureText),
                child: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textLabel,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
