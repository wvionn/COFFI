import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/menu_provider.dart';
import '../widgets/customer_favorite_card.dart';
import '../widgets/promo_carousel_banner.dart';

class CustomerDashboardTab extends StatefulWidget {
  final VoidCallback onNavigateToMenu;
  final VoidCallback onOpenProfile;

  const CustomerDashboardTab({
    super.key,
    required this.onNavigateToMenu,
    required this.onOpenProfile,
  });

  @override
  State<CustomerDashboardTab> createState() => _CustomerDashboardTabState();
}

class _CustomerDashboardTabState extends State<CustomerDashboardTab> {
  String _selectedOutlet = 'COFFI (Senopati)';
  final List<String> _outlets = [
    'COFFI (Senopati)',
    'COFFI (SCBD Park)',
    'COFFI (Kemang Raya)',
    'COFFI (Menteng Heritage)',
  ];

  void _showOutletDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Pilih Lokasi Outlet',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              ..._outlets.map((outlet) {
                final isSelected = outlet == _selectedOutlet;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.figmaSoftCream
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: isSelected ? AppColors.figmaCoffee : AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    outlet,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? AppColors.figmaCoffee : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.figmaCoffee)
                      : null,
                  onTap: () {
                    setState(() => _selectedOutlet = outlet);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Notifikasi Promo & Pesanan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_offer_rounded, color: Color(0xFF00C853)),
                ),
                title: Text(
                  'Promo Buy 1 Get 1 Free Aktif!',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Gunakan kode promo COFFIBOGO di pesanan Anda.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final menu = context.watch<MenuProvider>();
    final cart = context.read<CartProvider>();
    final profile = auth.currentProfile;

    // First name extraction for warm friendly greeting: "Halo, Budi 👋"
    final fullName = profile?.fullName ?? 'Budi';
    final firstName = fullName.split(' ').first;

    // Favorites list (either flagged or top products)
    final favorites = menu.products.where((p) => p.isActive).take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // 1. TOP BAR: Outlet on Left, Actions (Notification + Avatar) on Right
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Lokasi Outlet Selector
                Expanded(
                  child: GestureDetector(
                    onTap: _showOutletDialog,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'LOKASI OUTLET',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.figmaHazelnut,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.figmaRedPin,
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _selectedOutlet,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Top Right Action Buttons: Notification Bell & Profile Avatar
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Notification Button
                    Material(
                      color: AppColors.figmaSoftCream,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _showNotificationSheet,
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.figmaCoffee,
                            size: 22,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // User Profile Photo (matching 44x44 rounded rectangle style)
                    GestureDetector(
                      onTap: widget.onOpenProfile,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.figmaSoftCream,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.figmaSubtleBorder,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF38220F).withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.5),
                          child: Image.asset(
                            'assets/images/user_avatar.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.figmaCoffee,
                              child: Center(
                                child: Text(
                                  firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2. GREETING SECTION (Full-width below top bar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Halo, $firstName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('👋', style: TextStyle(fontSize: 22)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Mau ngopi apa hari ini?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9E8E82),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. HERO PROMO BANNER CAROUSEL
          PromoCarouselBanner(
            onTap: widget.onNavigateToMenu,
          ),

          const SizedBox(height: 28),

          // 3. REKOMENDASI FAVORIT SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Rekomendasi Favorit',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: widget.onNavigateToMenu,
                  child: Text(
                    'LIHAT SEMUA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.figmaHazelnut,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Horizontal Favorites List
          SizedBox(
            height: 272,
            child: favorites.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.figmaCoffee))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final product = favorites[index];
                      return CustomerFavoriteCard(
                        product: product,
                        onAddToCart: () {
                          cart.addItem(product: product);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} ditambahkan ke keranjang.'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.figmaCoffee,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
