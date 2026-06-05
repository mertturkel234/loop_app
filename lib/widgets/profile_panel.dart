import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../state/app_state_provider.dart';
import '../screens/change_password_screen.dart';

/// LOOP Account / Profile Settings Paneli.
/// showModalBottomSheet ile DraggableScrollableSheet olarak açılır.
void showProfilePanel(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _ProfilePanel(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Ana Panel Widget
// ─────────────────────────────────────────────────────────────────────────────

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (ctx, controller) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 30,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Tutma çubuğu
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Panel başlık
              _PanelHeader(onClose: () => Navigator.pop(ctx)),
              // Kaydırılabilir içerik
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: const [
                    _ProfileSection(),
                    SizedBox(height: 20),
                    _ThemeSection(),
                    SizedBox(height: 20),
                    _SecuritySection(),
                    SizedBox(height: 20),
                    _NotificationsSection(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Panel Başlık
// ─────────────────────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3ECFCE), Color(0xFF4DBFB0)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                state.initials,
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LOOP Account',
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary)),
              Text('PROFILE SETTINGS',
                  style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      letterSpacing: 1.5, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 1),
              ),
              child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ortak bölüm başlık
// ─────────────────────────────────────────────────────────────────────────────

Widget _sectionTitle(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w700,
            letterSpacing: 1.2, color: AppColors.textLabel),
      ),
    );

Widget _sectionCard({required Widget child}) => Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: child,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Profil Formu
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileSection extends StatefulWidget {
  const _ProfileSection();

  @override
  State<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<_ProfileSection> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _companyCtrl;
  bool _saved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateProvider.of(context);
    _nameCtrl = TextEditingController(text: state.name);
    _emailCtrl = TextEditingController(text: state.email);
    _companyCtrl = TextEditingController(text: state.companyName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  void _save() {
    AppStateProvider.read(context).updateProfile(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
    );
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('PROFİL BİLGİLERİ'),
        _sectionCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _FieldRow(label: 'AD SOYAD', controller: _nameCtrl, hint: 'Adınız Soyadınız'),
                const SizedBox(height: 12),
                _FieldRow(label: 'E-POSTA', controller: _emailCtrl, hint: 'email@sirket.com'),
                const SizedBox(height: 12),
                _FieldRow(label: 'ŞİRKET ADI', controller: _companyCtrl, hint: 'Şirket adınız'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _saved ? const Color(0xFF2D6A4F) : AppColors.primaryButton,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      _saved ? '✓ Kaydedildi' : 'Değişiklikleri Kaydet',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: const Color(0xFF0D1E30)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.controller, required this.hint});
  final String label;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w700,
                letterSpacing: 1.2, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.backgroundDeep,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cardBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryButton, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tema Seçici
// ─────────────────────────────────────────────────────────────────────────────

class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isDark = state.themeMode == ThemeMode.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ARAYÜZ TEMASI'),
        _sectionCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _ThemeBtn(
                  label: '🌙  Karanlık',
                  isActive: isDark,
                  onTap: () => AppStateProvider.read(context).setThemeMode(ThemeMode.dark),
                ),
                const SizedBox(width: 10),
                _ThemeBtn(
                  label: '☀️  Aydınlık',
                  isActive: !isDark,
                  onTap: () => AppStateProvider.read(context).setThemeMode(ThemeMode.light),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeBtn extends StatelessWidget {
  const _ThemeBtn({required this.label, required this.isActive, required this.onTap});
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryButton.withAlpha(30) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? AppColors.primaryButton : AppColors.cardBorder,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: isActive ? AppColors.primaryButton : AppColors.textSecondary)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Güvenlik Bölümü
// ─────────────────────────────────────────────────────────────────────────────

class _SecuritySection extends StatelessWidget {
  const _SecuritySection();

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('GÜVENLİK'),
        _sectionCard(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDeep,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Icon(Icons.lock_rounded, size: 18, color: AppColors.textSecondary),
                ),
                title: Text('Şifre Değiştir',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                subtitle: Text('Son değişiklik: 3 ay önce',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLabel),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (ctx, anim, sec) =>
                          const ChangePasswordScreen(),
                      transitionsBuilder: (ctx, anim, sec, child) =>
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                                parent: anim, curve: Curves.easeInOut)),
                            child: child,
                          ),
                      transitionDuration:
                          const Duration(milliseconds: 320),
                    ),
                  );
                },
              ),
              Divider(height: 1, color: AppColors.cardBorder),
              SwitchListTile(
                value: state.twoFactorEnabled,
                activeThumbColor: AppColors.primaryButton,
                onChanged: (v) => AppStateProvider.read(context).setTwoFactor(v),
                title: Text('İki Faktörlü Doğrulama (2FA)',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                subtitle: Text(
                  state.twoFactorEnabled ? 'Etkin — SMS ile doğrulama' : 'Kapalı — önerilir',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: state.twoFactorEnabled
                          ? AppColors.primaryButton
                          : AppColors.textSecondary),
                ),
                secondary: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDeep,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Icon(Icons.shield_rounded, size: 18, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bildirimler Bölümü
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('BİLDİRİMLER'),
        _sectionCard(
          child: Column(
            children: [
              SwitchListTile(
                value: state.pushNotifications,
                activeThumbColor: AppColors.primaryButton,
                onChanged: (v) => AppStateProvider.read(context).setPushNotifications(v),
                title: Text('Push Bildirimleri',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                subtitle: Text('Anlık sipariş ve teslimat güncellemeleri',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                secondary: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDeep,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Icon(Icons.notifications_outlined, size: 18, color: AppColors.textSecondary),
                ),
              ),
              Divider(height: 1, color: AppColors.cardBorder),
              SwitchListTile(
                value: state.emailNotifications,
                activeThumbColor: AppColors.primaryButton,
                onChanged: (v) => AppStateProvider.read(context).setEmailNotifications(v),
                title: Text('E-Posta Bildirimleri',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                subtitle: Text('Haftalık özet ve operasyon raporları',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                secondary: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDeep,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Icon(Icons.email_outlined, size: 18, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
