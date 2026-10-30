import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _Promo {
  final String tag;
  final String title;
  final String subtitle;
  final Alignment imageAlignment;
  final Color tint;

  const _Promo({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.imageAlignment,
    required this.tint,
  });
}

/// Hero promo carousel for the customer dashboard.
///
/// The background image is text-free; every label is rendered by Flutter so
/// nothing is duplicated and the copy stays editable.
class PromoCarouselBanner extends StatefulWidget {
  final VoidCallback? onTap;

  const PromoCarouselBanner({super.key, this.onTap});

  @override
  State<PromoCarouselBanner> createState() => _PromoCarouselBannerState();
}

class _PromoCarouselBannerState extends State<PromoCarouselBanner> {
  static const double _bannerHeight = 176;
  static const double _shadowRoom = 14;
  static const String _bgAsset = 'assets/images/promo_banner_bg.png';

  static const List<_Promo> _promos = [
    _Promo(
      tag: 'LIMITED TIME',
      title: 'Buy 1 Get 1 Free!',
      subtitle: 'Nikmati promo spesial khusus\npengguna aplikasi COFFI.',
      imageAlignment: Alignment.centerRight,
      tint: Color(0xFF00C853),
    ),
    _Promo(
      tag: 'WEEKEND SPECIAL',
      title: 'Diskon 30% Pastry',
      subtitle: 'Pasangan pas untuk kopi sore\ndengan Butter Croissant.',
      imageAlignment: Alignment.topRight,
      tint: Color(0xFFFF9800),
    ),
    _Promo(
      tag: 'FREE DELIVERY',
      title: 'Gratis Ongkir Outlet',
      subtitle: 'Pesan antar radius 3 km dari\noutlet Senopati & SCBD.',
      imageAlignment: Alignment.bottomRight,
      tint: Color(0xFF29B6F6),
    ),
  ];

  int _activePage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _bannerHeight + _shadowRoom * 2,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _promos.length,
        onPageChanged: (index) => setState(() => _activePage = index),
        itemBuilder: (context, index) => Padding(
          // Vertical room keeps the drop shadow from being clipped by PageView.
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: _shadowRoom,
          ),
          child: _buildCard(_promos[index]),
        ),
      ),
    );
  }

  Widget _buildCard(_Promo promo) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38220F).withOpacity(0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: const Color(0xFF2B1810),
          child: InkWell(
            onTap: widget.onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Text-free background (falls back to a warm gradient).
                Image.asset(
                  _bgAsset,
                  fit: BoxFit.cover,
                  alignment: promo.imageAlignment,
                  errorBuilder: (_, __, ___) => const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xFFC77D2E),
                          Color(0xFF7A4318),
                          Color(0xFF2B1810),
                        ],
                      ),
                    ),
                  ),
                ),

                // Left-to-right scrim so text stays readable.
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.62),
                        Colors.black.withOpacity(0.18),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: promo.tint,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          promo.tag,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        promo.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promo.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                          color: Colors.white.withOpacity(0.88),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(_promos.length, (i) {
                          final active = _activePage == i;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 5),
                            width: active ? 22 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ],
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
