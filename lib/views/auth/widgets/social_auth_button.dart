import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialAuthRow extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onOtpTap; // Kept for backwards compatibility, not rendered

  const SocialAuthRow({
    super.key,
    this.onGoogleTap,
    this.onOtpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onGoogleTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 50,
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE8DDD3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF38220F).withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGoogleIcon(),
                const SizedBox(width: 12),
                Text(
                  'Google',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF38220F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

/// Custom painter for the authentic Google 'G' 4-color logo
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double radius = w * 0.45;
    final double strokeWidth = w * 0.22;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Blue arc (top-right to bottom-right)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Green arc (bottom-right to bottom-left)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Yellow arc (bottom-left to top-left)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Red arc (top-left to top-right)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw arcs (approx angles in radians)
    // Blue: -0.8 to 0.7 rad
    canvas.drawArc(rect, -0.65, 1.45, false, bluePaint);
    // Green: 0.7 to 2.2 rad
    canvas.drawArc(rect, 0.7, 1.45, false, greenPaint);
    // Yellow: 2.1 to 3.6 rad
    canvas.drawArc(rect, 2.1, 1.35, false, yellowPaint);
    // Red: 3.4 to 4.9 rad
    canvas.drawArc(rect, 3.4, 1.45, false, redPaint);

    // Center horizontal blue crossbar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.05, cy - strokeWidth / 2, radius + strokeWidth / 2 + 1, strokeWidth),
      Radius.circular(strokeWidth / 4),
    );
    canvas.drawRRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
