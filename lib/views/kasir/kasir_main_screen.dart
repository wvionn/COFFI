import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/order_provider.dart';
import '../admin/admin_main_screen.dart';
import '../auth/login_screen.dart';
import 'cart_checkout_screen.dart';
import 'kasir_orders_tracking_screen.dart';
import 'widgets/item_modifier_sheet.dart';

class KasirMainScreen extends StatefulWidget {
  final bool isOpenedFromAdmin;

  const KasirMainScreen({super.key, this.isOpenedFromAdmin = false});

  @override
  State<KasirMainScreen> createState() => _KasirMainScreenState();
}

class _KasirMainScreenState extends State<KasirMainScreen> {
  int _navIndex = 1; // 0: Beranda, 1: Kasir, 2: Transaksi, 3: Laporan, 4: Produk, 5: Pengaturan
  String _selectedCategoryName = 'Semua';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final menu = context.watch<MenuProvider>();
    final orderProvider = context.watch<OrderProvider>();

    final activeOrdersCount = orderProvider.orders
        .where((o) => !o.isCancelled && !o.isCompleted)
        .length;

    final readyOrdersCount = orderProvider.orders
        .where((o) => o.isReady)
        .length;

    // Filter products based on selected category pill
    List<ProductModel> displayedProducts = menu.filteredProducts;
    if (_selectedCategoryName != 'Semua') {
      displayedProducts = displayedProducts.where((p) {
        final cat = menu.categories.firstWhere(
          (c) => c.id == p.categoryId,
          orElse: () => menu.categories.isNotEmpty ? menu.categories.first : menu.categories.first,
        );
        return cat.name.toLowerCase().contains(_selectedCategoryName.toLowerCase()) ||
            _selectedCategoryName.toLowerCase().contains(cat.name.toLowerCase());
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.softSand, // Warm cafe sand/oat cream matching Image 2
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Top Admin Banner (If opened from Admin)
                if (widget.isOpenedFromAdmin || (auth.currentProfile?.isAdmin == true))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColors.espressoDark,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.admin_panel_settings, color: AppColors.creamLatte, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Mode POS (Admin Aktif)',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const AdminMainScreen()),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.activePillCream,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_back, color: AppColors.espressoDark, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Kembali ke Admin',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.espressoDark,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Top Search Row (Matching Image 2)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                  child: Row(
                    children: [
                      // Search Input Field
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            onChanged: (val) => menu.setSearchQuery(val),
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Cari produk...',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Dark Barcode / Scanner Button (Matching Image 2)
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          // Quick status / scan action
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const KasirOrdersTrackingScreen()),
                          );
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.darkBarcodeBg, // #1E232A
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.format_align_justify_rounded, // Barcode/stripes look
                                color: Colors.white,
                                size: 22,
                              ),
                              if (readyOrdersCount > 0)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.matchaGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Horizontal Category Chips (Matching Image 2)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    children: [
                      _buildPillChip('Semua'),
                      _buildPillChip('Makanan'),
                      _buildPillChip('Minuman'),
                      _buildPillChip('Snack'),
                      _buildPillChip('Promo'),
                      // Dynamic categories from database if available
                      ...menu.categories
                          .where((c) => !['Makanan', 'Minuman', 'Snack', 'Promo'].contains(c.name))
                          .map((c) => _buildPillChip(c.name)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 2-Column Product Grid (Matching Image 2)
                Expanded(
                  child: menu.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.roastedCoffee))
                      : displayedProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.search_off_rounded, size: 54, color: AppColors.textMuted),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Menu tidak ditemukan',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Coba ubah kata kunci atau pilih kategori lain.',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(18, 4, 18, 120), // Bottom space for bottom nav
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.68, // Fits image, title, variant, price & stock perfectly
                              ),
                              itemCount: displayedProducts.length,
                              itemBuilder: (context, index) {
                                final product = displayedProducts[index];
                                return _buildProductCard(context, product, cart);
                              },
                            ),
                ),
              ],
            ),

            // Floating Cart Checkout Bar (Matching Screenshot)
            if (cart.items.isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 78, // Sits comfortably above curved bottom nav
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF261914), // Dark coffee matching screenshot
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${cart.totalItemsCount} Item • ${CurrencyFormatter.format(cart.totalAmount)}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CartCheckoutScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7E6CE), // Cream latte pill matching screenshot
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lihat Keranjang',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.espressoDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                                color: AppColors.espressoDark,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Curved White Bottom Navigation Bar (5 Items Matching Screenshot)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home_rounded,
                        label: 'Beranda',
                        isSelected: _navIndex == 0,
                        onTap: () {
                          setState(() => _navIndex = 0);
                          if (widget.isOpenedFromAdmin && Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else if (auth.currentProfile?.isAdmin == true) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminMainScreen(initialIndex: 0)),
                            );
                          } else {
                            setState(() {
                              _selectedCategoryName = 'Semua';
                              _navIndex = 1;
                            });
                          }
                        },
                      ),
                      _buildNavItem(
                        icon: Icons.point_of_sale_outlined,
                        selectedIcon: Icons.point_of_sale_rounded,
                        label: 'Kasir',
                        isSelected: _navIndex == 1,
                        onTap: () => setState(() => _navIndex = 1),
                      ),
                      _buildNavItem(
                        icon: Icons.receipt_long_outlined,
                        selectedIcon: Icons.receipt_long_rounded,
                        label: 'Antrean',
                        isSelected: _navIndex == 2,
                        badgeCount: activeOrdersCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const KasirOrdersTrackingScreen()),
                          );
                        },
                      ),
                      _buildNavItem(
                        icon: Icons.bar_chart_rounded,
                        selectedIcon: Icons.bar_chart_rounded,
                        label: 'Laporan',
                        isSelected: _navIndex == 3,
                        onTap: () {
                          if (auth.currentProfile?.isAdmin == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminMainScreen(initialIndex: 3)),
                            );
                          } else {
                            _showKasirShiftReportModal(context);
                          }
                        },
                      ),
                      _buildNavItem(
                        icon: Icons.settings_outlined,
                        selectedIcon: Icons.settings_rounded,
                        label: 'Pengaturan',
                        isSelected: _navIndex == 4,
                        onTap: () {
                          if (auth.currentProfile?.isAdmin == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminMainScreen(initialIndex: 4)),
                            );
                          } else {
                            _showUserLogoutSheet(context, auth);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Horizontal Category Pill Item (Matching Image 2)
  Widget _buildPillChip(String label) {
    final isSelected = _selectedCategoryName.toLowerCase() == label.toLowerCase();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            _selectedCategoryName = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.activePillCream : Colors.white, // Active cream, Inactive white
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.activePillCream : const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.espressoDark : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // 2-Column Product Card (Matching Image 2)
  Widget _buildProductCard(BuildContext context, ProductModel product, CartProvider cart) {
    final isSoldOut = product.isOutOfStock || !product.isActive;
    final inCartCount = cart.items
        .where((i) => i.productId == product.id)
        .fold(0, (sum, i) => sum + i.quantity);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: isSoldOut
          ? null
          : () {
              // Open modifier sheet for options or direct add
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ItemModifierSheet(product: product),
              );
            },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: inCartCount > 0 ? AppColors.warmCaramel.withOpacity(0.5) : const Color(0xFFECECEC),
            width: inCartCount > 0 ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Container with Star Badge
            Expanded(
              flex: 11,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                      child: Container(
                        color: const Color(0xFFF4F0EA),
                        child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                            ? Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.coffee, size: 36, color: AppColors.warmCaramel),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.coffee, size: 36, color: AppColors.warmCaramel),
                              ),
                      ),
                    ),
                  ),

                  // Star Badge on Top-Left (Matching Image 2)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7E6),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD591), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.star_rounded,
                          size: 17,
                          color: Color(0xFFFA8C16),
                        ),
                      ),
                    ),
                  ),

                  // Sold out overlay
                  if (isSoldOut)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.berryRed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'HABIS',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // In Cart Quantity Badge
                  if (inCartCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.espressoDark,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '$inCartCount x',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Details (Matching Image 2 typography & layout)
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name (Bold)
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Subtitle / Variant (Muted grey)
                        Text(
                          product.description ?? 'Pilihan favorit pelanggan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price (Bold)
                        Text(
                          CurrencyFormatter.format(product.price),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.espressoDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Stock Indicator (Matching Image 2: "Stok : 12 porsi")
                        Text(
                          product.trackStock ? 'Stok : ${product.stock} porsi' : 'Stok : Tersedia',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: product.isLowStock ? AppColors.amberOrange : AppColors.textMuted,
                            fontWeight: product.isLowStock ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Nav Bar Item (Matching Screenshot)
  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 24,
                  color: isSelected ? const Color(0xFF261914) : const Color(0xFF8C8C8C),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -7,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE86328), // Orange badge matching screenshot
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$badgeCount',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? const Color(0xFF261914) : const Color(0xFF8C8C8C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showKasirShiftReportModal(BuildContext context) {
    final orderProvider = context.read<OrderProvider>();
    final completedToday = orderProvider.orders.where((o) => o.isCompleted).toList();
    final totalOmset = completedToday.fold<double>(0, (sum, o) => sum + o.totalAmount);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.roastedCoffee.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bar_chart_rounded, color: AppColors.roastedCoffee, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Shift Kasir',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.espressoDark,
                        ),
                      ),
                      Text(
                        'Rekapitulasi penjualan shift kasir hari ini',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pesanan Selesai',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      Text(
                        '${completedToday.length} Transaksi',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.espressoDark),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Penjualan Shift',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      Text(
                        CurrencyFormatter.format(totalOmset),
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.espressoDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Untuk laporan laba-rugi & export PDF lengkap, silakan masuk menggunakan Akun Admin.',
              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roastedCoffee,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserLogoutSheet(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.activePillCream,
                    child: Text(
                      auth.currentProfile?.fullName.isNotEmpty == true
                          ? auth.currentProfile!.fullName[0].toUpperCase()
                          : 'K',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.espressoDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.currentProfile?.fullName ?? 'Kasir COFFI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.espressoDark,
                        ),
                      ),
                      Text(
                        'Role: ${auth.currentProfile?.role.toUpperCase()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.receipt_long, color: AppColors.roastedCoffee),
                title: const Text('Status Antrean Dapur'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KasirOrdersTrackingScreen()),
                  );
                },
              ),
              if (auth.currentProfile?.isAdmin == true)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: AppColors.roastedCoffee),
                  title: const Text('Ke Dashboard Admin'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminMainScreen()),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.berryRed),
                title: const Text('Keluar Akun', style: TextStyle(color: AppColors.berryRed)),
                onTap: () {
                  Navigator.pop(ctx);
                  auth.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
