import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

/// LOOP uygulamasının evrensel buton bileşeni.
///
/// Özellikler:
///   - Press/hover'da glow efekti + ölçek animasyonu
///   - Üç varyant: [LoopButtonVariant.primary], [secondary], [ghost]
///   - Yükleme durumu (spinner)
///   - Opsiyonel ikon desteği
enum LoopButtonVariant { primary, secondary, ghost }

class LoopButton extends StatefulWidget {
  const LoopButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isLoading = false,
    this.variant = LoopButtonVariant.primary,
    this.width,
    this.height = 54,
    this.fontSize = 16,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final LoopButtonVariant variant;
  final double? width;
  final double height;
  final double fontSize;

  @override
  State<LoopButton> createState() => _LoopButtonState();
}

class _LoopButtonState extends State<LoopButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDown(_) {
    if (widget.onTap == null || widget.isLoading) return;
    setState(() => _pressed = true);
    _ctrl.reverse();
  }

  void _onUp(_) {
    setState(() => _pressed = false);
    _ctrl.forward();
    if (!widget.isLoading) widget.onTap?.call();
  }

  void _onCancel() {
    setState(() => _pressed = false);
    _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.variant == LoopButtonVariant.primary;
    final isSecondary = widget.variant == LoopButtonVariant.secondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _pressed = true),
      onExit: (_) {
        setState(() => _pressed = false);
        _ctrl.forward();
      },
      child: GestureDetector(
        onTapDown: _onDown,
        onTapUp: _onUp,
        onTapCancel: _onCancel,
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: isPrimary
                  ? LinearGradient(
                      colors: _pressed
                          ? [
                              const Color(0xFF56DDD0),
                              const Color(0xFF63CBBF),
                            ]
                          : [
                              const Color(0xFF3ECFCE),
                              const Color(0xFF4DBFB0),
                            ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: isSecondary
                  ? (_pressed
                      ? AppColors.primaryButton.withAlpha(20)
                      : Colors.transparent)
                  : isPrimary
                      ? null
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: !isPrimary
                  ? Border.all(
                      color: _pressed
                          ? AppColors.primaryButton
                          : AppColors.cardBorder,
                      width: 1.2,
                    )
                  : null,
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: AppColors.primaryButton
                            .withAlpha(_pressed ? 140 : 80),
                        blurRadius: _pressed ? 28 : 14,
                        spreadRadius: _pressed ? 2 : 0,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : _pressed
                      ? [
                          BoxShadow(
                            color: AppColors.primaryButton.withAlpha(50),
                            blurRadius: 16,
                          ),
                        ]
                      : [],
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isPrimary
                              ? AppColors.textOnButton
                              : AppColors.textAccent,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: widget.fontSize + 2,
                            color: isPrimary
                                ? AppColors.textOnButton
                                : (_pressed
                                    ? AppColors.primaryButton
                                    : AppColors.textSecondary),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: GoogleFonts.inter(
                            fontSize: widget.fontSize,
                            fontWeight: FontWeight.w800,
                            color: isPrimary
                                ? AppColors.textOnButton
                                : (_pressed
                                    ? AppColors.primaryButton
                                    : AppColors.textSecondary),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
