import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

/// Şifre Değiştirme ekranı.
/// Navigator.push ile sağdan kayarak açılır.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentCtrl  = TextEditingController();
  final _newCtrl      = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _showCurrent  = false;
  bool _showNew      = false;
  bool _showConfirm  = false;
  bool _isLoading    = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Doğrulama kuralları ──────────────────────────────────────────────────
  String? _validateCurrent(String? v) {
    if (v == null || v.isEmpty) return 'Mevcut şifrenizi girin';
    return null;
  }

  String? _validateNew(String? v) {
    if (v == null || v.isEmpty) return 'Yeni şifre boş olamaz';
    if (v.length < 8)           return 'En az 8 karakter gerekli';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'En az bir büyük harf gerekli';
    if (!v.contains(RegExp(r'[0-9]'))) return 'En az bir rakam gerekli';
    if (!v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) {
      return 'En az bir özel karakter gerekli';
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty)   return 'Şifre tekrarını girin';
    if (v != _newCtrl.text)       return 'Şifreler eşleşmiyor';
    return null;
  }

  // ── Kaydet ──────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // Simüle edilmiş API çağrısı
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isLoading = false);
    await _showSuccessDialog();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _SuccessDialog(),
    );
  }

  // ── Şifre gücü hesaplama ─────────────────────────────────────────────────
  double get _strength {
    final v = _newCtrl.text;
    if (v.isEmpty) return 0;
    double s = 0;
    if (v.length >= 8) s += 0.25;
    if (v.contains(RegExp(r'[A-Z]'))) s += 0.25;
    if (v.contains(RegExp(r'[0-9]'))) s += 0.25;
    if (v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) s += 0.25;
    return s;
  }

  Color get _strengthColor {
    if (_strength <= 0.25) return const Color(0xFFFF4757);
    if (_strength <= 0.5)  return const Color(0xFFFFAA00);
    if (_strength <= 0.75) return const Color(0xFF4DBFB0);
    return const Color(0xFF2ED573);
  }

  String get _strengthLabel {
    if (_strength <= 0.25) return 'Zayıf';
    if (_strength <= 0.5)  return 'Orta';
    if (_strength <= 0.75) return 'İyi';
    return 'Güçlü';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = Theme.of(context).scaffoldBackgroundColor;
    final border = isDark ? AppColors.cardBorder : AppColors.lightBorder;
    final fieldBg= isDark ? AppColors.inputBackground : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.cardBackground : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: isDark ? AppColors.textPrimary : const Color(0xFF102A43)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Şifre Değiştir',
          style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimary : const Color(0xFF102A43)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Açıklama ──────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryButton.withAlpha(12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primaryButton.withAlpha(40), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_rounded,
                        color: AppColors.primaryButton, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Güvenliğiniz için şifrenizi en az 8 karakterden oluşturun, '
                        'büyük harf ve rakam içersin.',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.primaryButton,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Mevcut Şifre ──────────────────────────────────────────────
              _FieldLabel('GEÇERLİ ŞİFRE', isDark: isDark),
              _PasswordField(
                controller: _currentCtrl,
                hint: '••••••••',
                obscure: !_showCurrent,
                onToggle: () => setState(() => _showCurrent = !_showCurrent),
                validator: _validateCurrent,
                cardBg: fieldBg,
                border: border,
              ),
              const SizedBox(height: 20),

              // ── Yeni Şifre ────────────────────────────────────────────────
              _FieldLabel('YENİ ŞİFRE', isDark: isDark),
              _PasswordField(
                controller: _newCtrl,
                hint: 'Min. 8 karakter, büyük harf, rakam',
                obscure: !_showNew,
                onToggle: () => setState(() => _showNew = !_showNew),
                validator: _validateNew,
                onChanged: (_) => setState(() {}),
                cardBg: fieldBg,
                border: border,
              ),

              // ── Şifre Gücü Göstergesi ─────────────────────────────────────
              if (_newCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _strength,
                          minHeight: 4,
                          backgroundColor: border,
                          valueColor: AlwaysStoppedAnimation(_strengthColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(_strengthLabel,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _strengthColor)),
                  ],
                ),
                const SizedBox(height: 8),
                _PasswordRules(password: _newCtrl.text, isDark: isDark),
              ],

              const SizedBox(height: 20),

              // ── Şifreyi Onayla ────────────────────────────────────────────
              _FieldLabel('YENİ ŞİFREYİ ONAYLA', isDark: isDark),
              _PasswordField(
                controller: _confirmCtrl,
                hint: 'Şifrenizi tekrar girin',
                obscure: !_showConfirm,
                onToggle: () => setState(() => _showConfirm = !_showConfirm),
                validator: _validateConfirm,
                cardBg: fieldBg,
                border: border,
              ),

              const SizedBox(height: 36),

              // ── Güncelle Butonu ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    disabledBackgroundColor: AppColors.primaryButton.withAlpha(80),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text(
                          'Şifreyi Güncelle',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0D1E30)),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Alan etiketi
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {required this.isDark});
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: isDark ? AppColors.textLabel : const Color(0xFF627D98))),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Şifre Input Alanı
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    required this.validator,
    this.onChanged,
    required this.cardBg,
    required this.border,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final FormFieldValidator<String> validator;
  final ValueChanged<String>? onChanged;
  final Color cardBg;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      onChanged: onChanged,
      style: GoogleFonts.inter(
          color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: cardBg,
        hintStyle: GoogleFonts.inter(
            color: AppColors.textPlaceholder, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.primaryButton, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFFF4757), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFFF4757), width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Şifre Kuralları Göstergesi
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordRules extends StatelessWidget {
  const _PasswordRules({required this.password, required this.isDark});
  final String password;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Rule('En az 8 karakter', password.length >= 8),
        _Rule('En az bir büyük harf (A-Z)',
            password.contains(RegExp(r'[A-Z]'))),
        _Rule('En az bir rakam (0-9)',
            password.contains(RegExp(r'[0-9]'))),
        _Rule('En az bir özel karakter (!@#...)',
            password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule(this.label, this.satisfied);
  final String label;
  final bool satisfied;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 14, height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: satisfied
                  ? AppColors.primaryButton
                  : Colors.transparent,
              border: Border.all(
                color: satisfied
                    ? AppColors.primaryButton
                    : AppColors.cardBorder,
                width: 1.5,
              ),
            ),
            child: satisfied
                ? const Icon(Icons.check, size: 9, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: satisfied
                      ? AppColors.primaryButton
                      : AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Başarı Diyaloğu
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog();

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    // 2 saniye sonra otomatik kapat
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1A2B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: AppColors.primaryButton.withAlpha(60), width: 1),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primaryButton.withAlpha(30),
                    blurRadius: 40,
                    spreadRadius: 4),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Başarı animasyonu - halka ve tik
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryButton.withAlpha(20),
                    border: Border.all(
                        color: AppColors.primaryButton, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 36,
                    color: AppColors.primaryButton,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Şifre Güncellendi!',
                  style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Şifreniz başarıyla değiştirildi.\nHesabınız artık daha güvende.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryButton.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.primaryButton.withAlpha(60)),
                  ),
                  child: Text(
                    'Otomatik kapanıyor...',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.primaryButton,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
