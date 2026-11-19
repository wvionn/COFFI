import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/order_provider.dart';
import '../../auth/login_screen.dart';
import '../../kasir/kasir_main_screen.dart';

/// Shared COFFI Admin header matching the warm modern Figma aesthetic.
class AdminHeader extends StatelessWidget {
  final Function(int)? onTabNavigate;

  const AdminHeader({
    super.key,
    this.onTabNavigate,
  });

  static void showQuickMenu(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final menu = context.read<MenuProvider>();
    final orders = context.read<OrderProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.figmaSubtleBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.figmaCoffee,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.coffee_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.currentProfile?.fullName ?? 'Manager COFFI',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          auth.currentProfile?.email ?? 'admin@coffi.com',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 12),
              _buildMenuTile(
                icon: Icons.point_of_sale_rounded,
                iconBg: AppColors.figmaSoftCream,
                iconColor: AppColors.figmaCoffee,
                title: 'Buka Mode Kasir POS',
                subtitle: 'Kelola antrean & transaksi langsung',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const KasirMainScreen(isOpenedFromAdmin: true),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildMenuTile(
                icon: Icons.sync_rounded,
                iconBg: const Color(0xFFECFDF5),
                iconColor: AppColors.figmaReadyGreen,
                title: 'Sinkronkan Data',
                subtitle: 'Muat ulang produk, stok, dan transaksi',
                onTap: () async {
                  Navigator.pop(ctx);
                  await Future.wait([
                    menu.refreshProducts(),
                    orders.init(),
                  ]);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data dashboard & produk diperbarui.'),
                        backgroundColor: AppColors.figmaReadyGreen,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              _buildMenuTile(
                icon: Icons.logout_rounded,
                iconBg: const Color(0xFFFEF2F2),
                iconColor: AppColors.berryRed,
                title: 'Keluar Akun',
                subtitle: 'Kembali ke halaman login',
                onTap: () async {
                  Navigator.pop(ctx);
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildMenuTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFFCF8F4),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final rawName = auth.currentProfile?.fullName ?? 'Budi Santoso';
    final displayName = rawName.replaceAll(RegExp(r'\s*\(.*?\)'), '').trim();
    final roleLabel = (auth.currentProfile?.isAdmin ?? true)
        ? 'MANAGER'
        : (auth.currentProfile?.role.toUpperCase() ?? 'STAFF');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0E6DC), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              // Brand Icon Box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.figmaCoffee,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.coffee_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Brand Title
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'COFFI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: AppColors.figmaCoffee,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Admin',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w400,
                          color: AppColors.figmaHazelnut,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Manager Role & Name
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 112),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      roleLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                        color: const Color(0xFFB09381),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      displayName.isEmpty ? 'Budi Santoso' : displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.figmaCoffee,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Hamburger Quick Menu Button
              Material(
                color: const Color(0xFFFAF5F0),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => AdminHeader.showQuickMenu(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFEFE5DB),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.figmaCoffee,
                      size: 20,
                    ),
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

/// Shared product thumbnail supporting both local assets and network URLs.
class AdminProductImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double borderRadius;

  const AdminProductImage({
    super.key,
    required this.imageUrl,
    this.size = 56,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return _placeholder();
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.figmaSoftCream,
      alignment: Alignment.center,
      child: const Icon(
        Icons.coffee_rounded,
        color: AppColors.figmaHazelnut,
        size: 24,
      ),
    );
  }
}
