import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../state/app_state_provider.dart';

/// 4 adımlı LOOP Onboarding Modalı.
/// showDialog ile açılır. Business → Shipments → Experience → Verify.
void showOnboardingModal(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withAlpha(170),
    builder: (ctx) => const _OnboardingDialog(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Ana Dialog Widget
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingDialog extends StatefulWidget {
  const _OnboardingDialog();

  @override
  State<_OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<_OnboardingDialog> {
  final PageController _pageCtrl = PageController();
  int _currentStep = 0;

  // Step 1 – Business
  final _companyCtrl = TextEditingController();
  String _businessType = '';
  final _couriersCtrl = TextEditingController();
  final _employeesCtrl = TextEditingController();

  // Step 2 – Shipments
  double _monthlyVolume = 0;
  final Set<String> _goodsTypes = {};
  final _shippingLanesCtrl = TextEditingController();

  // Step 3 – Experience
  final _yearsCtrl = TextEditingController();
  final _tmsCtrl = TextEditingController();
  final _referencesCtrl = TextEditingController();
  final _challengeCtrl = TextEditingController();

  // Step 4 – Verify
  bool _identityConfirmed = false;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _companyCtrl.dispose();
    _couriersCtrl.dispose();
    _employeesCtrl.dispose();
    _shippingLanesCtrl.dispose();
    _yearsCtrl.dispose();
    _tmsCtrl.dispose();
    _referencesCtrl.dispose();
    _challengeCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    }
  }

  void _complete() {
    final state = AppStateProvider.read(context);
    state.completeOnboarding(
      name: _companyCtrl.text.isNotEmpty ? _companyCtrl.text.split(' ').first : 'Kullanıcı',
      email: '',
      companyName: _companyCtrl.text,
    );
    Navigator.pop(context);
  }

  // Buton etkin mi?
  bool get _canContinue {
    switch (_currentStep) {
      case 0: return _companyCtrl.text.isNotEmpty && _businessType.isNotEmpty;
      case 1: return true;
      case 2: return true;
      case 3: return _identityConfirmed && _termsAccepted;
      default: return false;
    }
  }

  static const _stepLabels = ['BUSINESS', 'SHIPMENTS', 'EXPERIENCE', 'VERIFY'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1A2B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder.withAlpha(60), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 60,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            _ModalHeader(onClose: () => Navigator.pop(context)),

            // ── Stepper ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
              child: _StepperBar(
                currentStep: _currentStep,
                labels: _stepLabels,
              ),
            ),

            const SizedBox(height: 20),

            // ── Sayfa içeriği ──────────────────────────────────────────────
            Flexible(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1Business(
                    companyCtrl: _companyCtrl,
                    businessType: _businessType,
                    onBusinessTypeChanged: (v) => setState(() => _businessType = v ?? ''),
                    couriersCtrl: _couriersCtrl,
                    employeesCtrl: _employeesCtrl,
                    onChanged: () => setState(() {}),
                  ),
                  _Step2Shipments(
                    monthlyVolume: _monthlyVolume,
                    onVolumeChanged: (v) => setState(() => _monthlyVolume = v),
                    goodsTypes: _goodsTypes,
                    onGoodsChanged: (v, checked) => setState(() {
                      checked ? _goodsTypes.add(v) : _goodsTypes.remove(v);
                    }),
                    shippingLanesCtrl: _shippingLanesCtrl,
                  ),
                  _Step3Experience(
                    yearsCtrl: _yearsCtrl,
                    tmsCtrl: _tmsCtrl,
                    referencesCtrl: _referencesCtrl,
                    challengeCtrl: _challengeCtrl,
                  ),
                  _Step4Verify(
                    identityConfirmed: _identityConfirmed,
                    termsAccepted: _termsAccepted,
                    onIdentityChanged: (v) => setState(() => _identityConfirmed = v ?? false),
                    onTermsChanged: (v) => setState(() => _termsAccepted = v ?? false),
                  ),
                ],
              ),
            ),

            // ── Footer ─────────────────────────────────────────────────────
            _ModalFooter(
              currentStep: _currentStep,
              canContinue: _canContinue,
              onBack: _currentStep > 0 ? _back : null,
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Modal Header
// ─────────────────────────────────────────────────────────────────────────────

class _ModalHeader extends StatelessWidget {
  const _ModalHeader({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 20, 0),
      child: Row(
        children: [
          // Logo kutusu
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryButton.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryButton.withAlpha(80), width: 1),
            ),
            child: Center(
              child: Text('L',
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w900,
                      color: AppColors.primaryButton)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LOOP Onboarding',
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary, letterSpacing: 0.3)),
              Text('LOGISTICS PARTNER SETUP',
                  style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary, letterSpacing: 1.5)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 1),
              ),
              child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stepper Bar
// ─────────────────────────────────────────────────────────────────────────────

class _StepperBar extends StatelessWidget {
  const _StepperBar({required this.currentStep, required this.labels});
  final int currentStep;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connecting line
          final stepIndex = i ~/ 2;
          final isCompleted = stepIndex < currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 1,
              color: isCompleted
                  ? AppColors.primaryButton
                  : AppColors.cardBorder,
            ),
          );
        }
        // Step circle
        final stepIndex = i ~/ 2;
        final isCompleted = stepIndex < currentStep;
        final isActive = stepIndex == currentStep;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted || isActive
                    ? AppColors.primaryButton
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted || isActive
                      ? AppColors.primaryButton
                      : AppColors.cardBorder,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text('${stepIndex + 1}',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? const Color(0xFF0D1E30)
                                : AppColors.textSecondary)),
              ),
            ),
            const SizedBox(height: 4),
            Text(labels[stepIndex],
                style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isCompleted || isActive
                        ? AppColors.primaryButton
                        : AppColors.textSecondary)),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer (Back / Step X of 4 / Continue)
// ─────────────────────────────────────────────────────────────────────────────

class _ModalFooter extends StatelessWidget {
  const _ModalFooter({
    required this.currentStep,
    required this.canContinue,
    required this.onBack,
    required this.onNext,
  });
  final int currentStep;
  final bool canContinue;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
      child: Row(
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text('Back',
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            const SizedBox(width: 80),
          const Spacer(),
          Text('Step ${currentStep + 1} of 4',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary)),
          const Spacer(),
          GestureDetector(
            onTap: canContinue ? onNext : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: canContinue ? AppColors.primaryButton : AppColors.primaryButton.withAlpha(60),
                borderRadius: BorderRadius.circular(10),
                boxShadow: canContinue
                    ? [BoxShadow(color: AppColors.primaryButton.withAlpha(80), blurRadius: 12, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentStep == 3 ? 'Complete & Unlock Payment' : 'Continue',
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: const Color(0xFF0D1E30)),
                  ),
                  if (currentStep < 3) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF0D1E30)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ortak input dekorasyon yardımcısı
// ─────────────────────────────────────────────────────────────────────────────

InputDecoration _fieldDeco(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFF142030),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.inter(color: const Color(0xFF3D5A7A), fontSize: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1E2E4A), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryButton, width: 1.5),
      ),
    );

Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w700,
              letterSpacing: 1.2, color: const Color(0xFF7A9CC0))),
    );

// ─────────────────────────────────────────────────────────────────────────────
// Adım 1 — Business Profile
// ─────────────────────────────────────────────────────────────────────────────

class _Step1Business extends StatelessWidget {
  const _Step1Business({
    required this.companyCtrl,
    required this.businessType,
    required this.onBusinessTypeChanged,
    required this.couriersCtrl,
    required this.employeesCtrl,
    required this.onChanged,
  });

  final TextEditingController companyCtrl;
  final String businessType;
  final ValueChanged<String?> onBusinessTypeChanged;
  final TextEditingController couriersCtrl;
  final TextEditingController employeesCtrl;
  final VoidCallback onChanged;

  static const _businessTypes = [
    '— Select your shipment model —',
    'FTL — Full Truckload (dedicated full-truck shipments)',
    'LTL — Less Than Truckload (shared freight, partial loads)',
    'E-Commerce / Last Mile (consumer parcel delivery)',
    'Mixed Fleet (combination of FTL, LTL & last-mile)',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Business Profile',
              style: GoogleFonts.inter(
                  fontSize: 26, fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(
            'Tell us about your logistics operation. This helps us tailor route '
            'assignments and reporting to your fleet size and shipment model.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 20),
          _label('BUSINESS / COMPANY NAME'),
          TextField(
            controller: companyCtrl,
            onChanged: (_) => onChanged(),
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
            decoration: _fieldDeco('e.g. Yılmaz Freight Solutions'),
          ),
          const SizedBox(height: 16),
          _label('BUSINESS TYPE'),
          DropdownButtonFormField<String>(
            initialValue: businessType.isEmpty ? _businessTypes[0] : businessType,
            dropdownColor: const Color(0xFF142030),
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
            decoration: _fieldDeco('').copyWith(hintText: null),
            items: _businessTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary))))
                .toList(),
            onChanged: (v) {
              if (v != _businessTypes[0]) {
                onBusinessTypeChanged(v);
              } else {
                onBusinessTypeChanged('');
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('NUMBER OF ACTIVE COURIERS / VEHICLES'),
                    TextField(
                      controller: couriersCtrl,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
                      decoration: _fieldDeco('e.g. 25'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('TOTAL EMPLOYEES'),
                    TextField(
                      controller: employeesCtrl,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
                      decoration: _fieldDeco('e.g. 1-10, 50-200, 500+'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Adım 2 — Shipment Details
// ─────────────────────────────────────────────────────────────────────────────

class _Step2Shipments extends StatelessWidget {
  const _Step2Shipments({
    required this.monthlyVolume,
    required this.onVolumeChanged,
    required this.goodsTypes,
    required this.onGoodsChanged,
    required this.shippingLanesCtrl,
  });

  final double monthlyVolume;
  final ValueChanged<double> onVolumeChanged;
  final Set<String> goodsTypes;
  final void Function(String, bool) onGoodsChanged;
  final TextEditingController shippingLanesCtrl;

  static const _goodsOptions = [
    ('💻', 'Electronics & Tech'),
    ('🌡', 'Perishables / Cold Chain'),
    ('👗', 'Clothing & Apparel'),
    ('🔩', 'Automotive Parts'),
    ('🛋', 'Furniture & Home Goods'),
    ('📄', 'Documents & Legal'),
  ];

  String get _volumeLabel {
    if (monthlyVolume < 0.5) return '1 – 100 shipments / month';
    if (monthlyVolume < 1.0) return '100 – 500 shipments / month';
    return '500+ shipments / month';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Shipment Details',
              style: GoogleFonts.inter(
                  fontSize: 26, fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(
            'Help us understand your shipment volume and cargo types so our routing '
            'engine can prioritise capacity, temperature-control zones, and urban density correctly.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 20),
          _label('ANTICIPATED MONTHLY SHIPMENT VOLUME'),
          Slider(
            value: monthlyVolume,
            min: 0, max: 1,
            activeColor: AppColors.primaryButton,
            inactiveColor: AppColors.cardBorder,
            onChanged: onVolumeChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 - 100 / mo', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
              Text('100 - 500 / mo', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
              Text('500+ / mo', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
          Center(
            child: Text(_volumeLabel,
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppColors.primaryButton)),
          ),
          const SizedBox(height: 16),
          _label('TYPES OF GOODS TRANSPORTED'),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 8,
            childAspectRatio: 4.5,
            children: _goodsOptions.map((opt) {
              final isSelected = goodsTypes.contains(opt.$2);
              return GestureDetector(
                onTap: () => onGoodsChanged(opt.$2, !isSelected),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryButton.withAlpha(20) : const Color(0xFF142030),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryButton : const Color(0xFF1E2E4A),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (v) => onGoodsChanged(opt.$2, v ?? false),
                          activeColor: AppColors.primaryButton,
                          side: const BorderSide(color: AppColors.cardBorder, width: 1),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('${opt.$1} ${opt.$2}',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isSelected ? AppColors.primaryButton : AppColors.textSecondary)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _label('PRIMARY SHIPPING LANES / REGIONS'),
          TextField(
            controller: shippingLanesCtrl,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
            decoration: _fieldDeco('e.g. İstanbul – Ankara, İzmir metro area, nationwide'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Adım 3 — Experience & References
// ─────────────────────────────────────────────────────────────────────────────

class _Step3Experience extends StatelessWidget {
  const _Step3Experience({
    required this.yearsCtrl,
    required this.tmsCtrl,
    required this.referencesCtrl,
    required this.challengeCtrl,
  });

  final TextEditingController yearsCtrl;
  final TextEditingController tmsCtrl;
  final TextEditingController referencesCtrl;
  final TextEditingController challengeCtrl;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Experience & References',
              style: GoogleFonts.inter(
                  fontSize: 26, fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(
            'We partner with established operators. Sharing your background helps us assign '
            'a dedicated LOOP integration specialist who understands your sector.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('YEARS IN LOGISTICS / FREIGHT'),
                    TextField(
                      controller: yearsCtrl,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
                      decoration: _fieldDeco('e.g. 7'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('CURRENT TMS / DISPATCH SOFTWARE'),
                    TextField(
                      controller: tmsCtrl,
                      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
                      decoration: _fieldDeco('e.g. SAP TM, Oracle TMS, spreadsheets'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _label('PROFESSIONAL REFERENCES (OPTIONAL)'),
          TextField(
            controller: referencesCtrl,
            maxLines: 3,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
            decoration: _fieldDeco(
              'e.g. Ahmet Kaya, Logistics Director @ TechCorp +90 532 xxx xx xx\n'
              'Fatma Demir, Operations VP @ RetailCo fatma@retailco.com',
            ),
          ),
          const SizedBox(height: 16),
          _label('BIGGEST OPERATIONAL CHALLENGE TODAY'),
          TextField(
            controller: challengeCtrl,
            maxLines: 3,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
            decoration: _fieldDeco(
              'e.g. High fuel costs, difficult last-mile in dense urban areas, '
              'manual dispatcher overload during peak hours...',
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Adım 4 — Verification & Agreement
// ─────────────────────────────────────────────────────────────────────────────

class _Step4Verify extends StatelessWidget {
  const _Step4Verify({
    required this.identityConfirmed,
    required this.termsAccepted,
    required this.onIdentityChanged,
    required this.onTermsChanged,
  });

  final bool identityConfirmed;
  final bool termsAccepted;
  final ValueChanged<bool?> onIdentityChanged;
  final ValueChanged<bool?> onTermsChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verification & Agreement',
              style: GoogleFonts.inter(
                  fontSize: 26, fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(
            'We take trust seriously. Please confirm your identity and accept our operating '
            'terms before we activate your LOOP partner account and unlock payment options.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 20),
          _AgreementCard(
            isChecked: identityConfirmed,
            onChanged: onIdentityChanged,
            title: 'Identity Confirmation:',
            body: 'I confirm that the business name, contact details, and shipment information '
                'I have provided are accurate and belong to a legitimate registered business entity. '
                'I understand that false information may result in account termination.',
          ),
          const SizedBox(height: 12),
          _AgreementCard(
            isChecked: termsAccepted,
            onChanged: onTermsChanged,
            title: 'Terms & Service Agreement:',
            body: "I have read and agree to LOOP's Terms of Service, Privacy Policy, and Logistics "
                "Partner Agreement. I acknowledge that LOOP's platform stores operational data "
                'for route analysis and billing purposes.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryButton.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryButton.withAlpha(40), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WHAT HAPPENS NEXT?',
                    style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        letterSpacing: 1.2, color: AppColors.primaryButton)),
                const SizedBox(height: 8),
                Text(
                  'After verification, your partner account is activated and a secure payment link is unlocked. '
                  'A LOOP onboarding specialist will contact you within 24 hours to schedule your fleet integration session.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreementCard extends StatelessWidget {
  const _AgreementCard({
    required this.isChecked,
    required this.onChanged,
    required this.title,
    required this.body,
  });

  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isChecked ? AppColors.primaryButton.withAlpha(12) : const Color(0xFF142030),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked ? AppColors.primaryButton.withAlpha(80) : const Color(0xFF1E2E4A),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: isChecked,
              onChanged: onChanged,
              activeColor: AppColors.primaryButton,
              side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                  children: [
                    TextSpan(
                        text: title,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700)),
                    TextSpan(text: ' $body'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
