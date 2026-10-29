import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialAuthRow extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onOtpTap;

  const SocialAuthRow({
    super.key,
    this.onGoogleTap,
    this.onOtpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Google Button
        Expanded(
          child: _SocialButton(
            onTap: onGoogleTap,
            icon: _buildGoogleIcon(),
            label: 'Google',
          ),
        ),
        const SizedBox(width: 14),
        // OTP Button
        Expanded(
          child: _SocialButton(
            onTap: onOtpTap,
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFF25D366),
              size: 19,
            ),
            label: 'OTP',
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      child: Text(
        'G',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF4285F4),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget icon;
  final String label;

  const _SocialButton({
    required this.onTap,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE8DDD3),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF38220F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

