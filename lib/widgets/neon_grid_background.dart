import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Tüm harita/ekran arkasında yavaşça süzülen fütüristik Neon Izgara dokusu.
class NeonGridBackground extends StatefulWidget {
  const NeonGridBackground({super.key, required this.child});
  final Widget child;

  @override
  State<NeonGridBackground> createState() => _NeonGridBackgroundState();
}

class _NeonGridBackgroundState extends State<NeonGridBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // Yavaşça akan bir animasyon (sonsuz döngü)
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 15))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return CustomPaint(
                painter: _GridPainter(
                  progress: _ctrl.value,
                  isDark: isDark,
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.progress, required this.isDark});
  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    // Aydınlık/Karanlık moduna göre ızgara opaklığı ve rengi
    final gridColor = isDark 
        ? AppColors.neonGrid.withAlpha(40) 
        : AppColors.lightBorder.withAlpha(60);

    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double gridSize = 40.0;
    
    // Yatay çizgilerin akış animasyonu (yukarıdan aşağıya süzülme)
    final double offsetY = progress * gridSize;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = -gridSize; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y + offsetY), Offset(size.width, y + offsetY), paint);
    }
    
    // Kenarlara çok hafif radial gradient karartması ekleyerek tünel/derinlik hissi verelim
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          isDark ? AppColors.backgroundDeep.withAlpha(200) : AppColors.lightBackground.withAlpha(180),
        ],
        stops: const [0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
