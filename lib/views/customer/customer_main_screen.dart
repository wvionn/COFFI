import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/table_provider.dart';
import '../auth/login_screen.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showCheckoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CustomerCheckoutSheet(),
    ).then((submitted) {
      if (submitted == true) {
        _tabController.animateTo(1); // Auto switch to "Pesanan Saya" tab
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final profile = auth.currentProfile;

    return Scaffold(
      backgroundColor: AppColors.softSand,
      appBar: AppBar(
        backgroundColor: AppColors.espressoDark,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COFFI • SELF ORDER',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.creamLatte,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Halo, Kak ${profile?.fullName ?? "Pelanggan"} 👋',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded, color: AppColors.creamLatte),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dCtx) => AlertDialog(
                  title: const Text('Keluar dari Akun?'),
                  content: const Text('Apakah Anda yakin ingin keluar dari sesi aplikasi?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Batal')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.berryRed, foregroundColor: Colors.white),
                      onPressed: () => Navigator.pop(dCtx, true),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.activePillCream,
          indicatorWeight: 3.5,
          labelColor: AppColors.activePillCream,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800),
          tabs: const [
            Tab(icon: Icon(Icons.coffee_rounded, size: 20), text: 'Pesan Menu'),
            Tab(icon: Icon(Icons.receipt_long_rounded, size: 20), text: 'Pesanan Saya'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: MENU & KATALOG
          _buildMenuTab(context),

          // TAB 2: PESANAN SAYA (LIVE TRACKING)
          _buildMyOrdersTab(context),
        ],
      ),
      // Sticky Bottom Cart Bar
      bottomNavigationBar: cart.items.isNotEmpty
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🛒 ${cart.totalItemsCount} Menu Dipilih',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            'Rp ${cart.totalAmount.toInt()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.espressoDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.roastedCoffee,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () => _showCheckoutBottomSheet(context),
                      icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                      label: Text(
                        'Checkout ➔',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildMenuTab(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final cart = context.watch<CartProvider>();

    final categories = ['Semua', ...menu.categories.map((c) => c.name)];

    var products = menu.products.where((p) => p.isActive).toList();
    if (_selectedCategory != 'Semua') {
      final selectedCat = menu.categories.where((c) => c.name == _selectedCategory).toList();
      if (selectedCat.isNotEmpty) {
        products = products.where((p) => p.categoryId == selectedCat.first.id).toList();
      }
    }
    if (_searchQuery.isNotEmpty) {
      products = products.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return Column(
      children: [
        // Search & Greeting Banner
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Cari kopi, pastry, makanan...',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Categories Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                        selectedColor: AppColors.espressoDark,
                        backgroundColor: AppColors.softSand,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        side: BorderSide.none,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Products Grid
        Expanded(
          child: products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 54, color: AppColors.textMuted),
                      const SizedBox(height: 10),
                      Text(
                        'Menu tidak ditemukan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: products.length,
                  itemBuilder: (ctx, index) {
                    final product = products[index];
                    final inCartQty = cart.items
                        .where((i) => i.productId == product.id)
                        .fold(0, (sum, i) => sum + i.quantity);

                    return _buildProductCard(context, product, inCartQty, cart);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product, int inCartQty, CartProvider cart) {
    final isOutOfStock = product.trackStock && product.stock <= 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),
                  ),
                ),
                if (inCartQty > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.espressoDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${inCartQty}x',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.activePillCream,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                if (isOutOfStock)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              ],
            ),
          ),

          // Details Container
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.espressoDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.description ?? 'Pilihan favorit pelanggan kafe',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${product.price.toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.roastedCoffee,
                        ),
                      ),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOutOfStock ? AppColors.softSand : AppColors.activePillCream,
                            foregroundColor: isOutOfStock ? AppColors.textMuted : AppColors.espressoDark,
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: isOutOfStock
                              ? null
                              : () {
                                  cart.addItem(product: product);
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} ditambahkan ke keranjang!'),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: AppColors.espressoDark,
                                    ),
                                  );
                                },
                          child: const Icon(Icons.add_rounded, size: 20),
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
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.oatMilkFoam,
      child: const Center(
        child: Icon(Icons.coffee_rounded, size: 36, color: AppColors.creamLatte),
      ),
    );
  }

  Widget _buildMyOrdersTab(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final auth = context.watch<AuthProvider>();
    final profile = auth.currentProfile;

    final customerOrders = orderProvider.getCustomerOrders(
      customerId: profile?.id,
      customerName: profile?.fullName,
    );

    if (customerOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Pesanan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pesan kopi atau makanan lezatmu sekarang!',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.espressoDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => _tabController.animateTo(0),
              icon: const Icon(Icons.coffee_rounded, size: 18),
              label: const Text('Buka Menu'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customerOrders.length,
      itemBuilder: (ctx, index) {
        final order = customerOrders[index];
        return _buildCustomerOrderCard(order);
      },
    );
  }

  Widget _buildCustomerOrderCard(OrderModel order) {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (order.isWaitingValidation) {
      badgeColor = AppColors.berryRed;
      badgeText = 'Menunggu Validasi Kasir';
      badgeIcon = Icons.hourglass_top_rounded;
    } else if (order.isProcessing) {
      badgeColor = AppColors.amberOrange;
      badgeText = 'Sedang Diracik Barista';
      badgeIcon = Icons.soup_kitchen_rounded;
    } else if (order.isReady) {
      badgeColor = AppColors.matchaGreen;
      badgeText = order.isDelivery ? 'Siap Diantar' : 'Siap Diambil di Kasir';
      badgeIcon = Icons.check_circle_rounded;
    } else if (order.isDelivering) {
      badgeColor = AppColors.coldBrewBlue;
      badgeText = 'Sedang Diantar Kurir';
      badgeIcon = Icons.delivery_dining_rounded;
    } else if (order.isCompleted) {
      badgeColor = AppColors.textMuted;
      badgeText = 'Pesanan Selesai';
      badgeIcon = Icons.task_alt_rounded;
    } else {
      badgeColor = AppColors.berryRed;
      badgeText = 'Dibatalkan';
      badgeIcon = Icons.cancel_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (order.isWaitingValidation || order.isReady) ? badgeColor : const Color(0xFFE5E7EB),
          width: (order.isWaitingValidation || order.isReady) ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status Badge & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(badgeIcon, size: 16, color: badgeColor),
                    const SizedBox(width: 6),
                    Text(
                      badgeText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Order Type & Invoice
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.invoiceNumber,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.espressoDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.softSand,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.isDelivery
                      ? '🛵 DELIVERY'
                      : (order.isDineIn ? '🍽️ MEJA ${order.tableNumber ?? "-"}' : '🛍️ TAKEAWAY'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 20),

          // Items summary
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.quantity}x ${item.productName}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Rp ${item.subtotal.toInt()}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              )),

          const Divider(height: 16),

          // Total Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              Text(
                'Rp ${order.totalAmount.toInt()}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.roastedCoffee,
                ),
              ),
            ],
          ),

          // Step Progress Bar Indicator
          const SizedBox(height: 14),
          _buildProgressTracker(order),
        ],
      ),
    );
  }

  Widget _buildProgressTracker(OrderModel order) {
    int activeStep = 0;
    if (order.isCancelled) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFECEB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 16, color: AppColors.berryRed),
            const SizedBox(width: 8),
            Text(
              'Pesanan dibatalkan atau stok tidak mencukupi.',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.berryRed, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    if (order.isWaitingValidation) {
      activeStep = 1;
    } else if (order.isProcessing || order.isPending) {
      activeStep = 2;
    } else if (order.isReady) {
      activeStep = 3;
    } else if (order.isDelivering) {
      activeStep = 4;
    } else if (order.isCompleted) {
      activeStep = 5;
    }

    final steps = [
      'Validasi',
      'Diracik',
      order.isDelivery ? 'Siap' : 'Siap Ambil',
      if (order.isDelivery) 'Diantar',
      'Selesai',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (idx) {
          final isPassed = idx + 1 <= activeStep;
          final isCurrent = idx + 1 == activeStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPassed
                              ? (isCurrent ? AppColors.amberOrange : AppColors.matchaGreen)
                              : const Color(0xFFCBD5E1),
                        ),
                        child: Center(
                          child: Icon(
                            isPassed ? Icons.check : Icons.circle,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[idx],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                          color: isPassed ? AppColors.espressoDark : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (idx < steps.length - 1)
                  Container(
                    width: 14,
                    height: 2,
                    color: (idx + 1 < activeStep) ? AppColors.matchaGreen : const Color(0xFFE2E8F0),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// =========================================================================
// CHECKOUT BOTTOM SHEET (MODAL PEMESANAN)
// =========================================================================

class _CustomerCheckoutSheet extends StatefulWidget {
  const _CustomerCheckoutSheet();

  @override
  State<_CustomerCheckoutSheet> createState() => _CustomerCheckoutSheetState();
}

class _CustomerCheckoutSheetState extends State<_CustomerCheckoutSheet> {
  String _orderType = 'dine_in'; // 'dine_in', 'takeaway', 'delivery'
  String? _selectedTableNumber;
  String? _selectedTableId;
  String _paymentMethod = 'qris'; // 'qris', 'cash'
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final auth = context.read<AuthProvider>();
    final profile = auth.currentProfile;

    if (cart.items.isEmpty) return;

    if (_orderType == 'dine_in' && _selectedTableNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih nomor meja Anda terlebih dahulu!'), backgroundColor: AppColors.berryRed),
      );
      return;
    }

    if (_orderType == 'delivery' && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan alamat lengkap pengantaran!'), backgroundColor: AppColors.berryRed),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // If QRIS, show QR Code simulation modal
    if (_paymentMethod == 'qris') {
      final qrisPaid = await _showQrisModal(context, cart.totalAmount);
      if (qrisPaid != true) {
        setState(() => _isSubmitting = false);
        return;
      }
    }

    final order = await orderProvider.checkout(
      orderType: _orderType,
      tableId: _selectedTableId,
      tableNumber: _selectedTableNumber,
      customerId: profile?.id,
      customerName: profile?.fullName ?? 'Pelanggan App',
      customerPhone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : profile?.phone,
      deliveryAddress: _orderType == 'delivery' ? _addressController.text.trim() : null,
      items: cart.items,
      paymentMethod: _paymentMethod,
      amountPaid: cart.totalAmount,
      changeAmount: 0.0,
      generalNotes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      initialStatus: 'menunggu_validasi', // Starts at Menunggu Validasi Kasir!
    );

    setState(() => _isSubmitting = false);

    if (order != null && mounted) {
      cart.clearCart();
      Navigator.pop(context, true); // Close bottom sheet and signal success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Pesanan #${order.invoiceNumber} berhasil dikirim ke Kasir!'),
          backgroundColor: AppColors.matchaGreen,
        ),
      );
    }
  }

  Future<bool?> _showQrisModal(BuildContext context, double totalAmount) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            'QRIS COFFI INSTAN',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 160, color: AppColors.espressoDark),
                  Text(
                    'Scan dengan GoPay, OVO, Dana, BCA, dll',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Total: Rp ${totalAmount.toInt()}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.roastedCoffee,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.matchaGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(dCtx, true),
            child: const Text('Saya Sudah Bayar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final tables = context.watch<TableProvider>().tables;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Konfirmasi & Checkout',
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.espressoDark),
            ),
            const SizedBox(height: 16),

            // Pilihan Mode Pesanan
            Text('Pilih Jenis Pesanan:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeChip('🍽️ Makan di Kafe', 'dine_in'),
                const SizedBox(width: 8),
                _buildTypeChip('🛍️ Takeaway', 'takeaway'),
                const SizedBox(width: 8),
                _buildTypeChip('🛵 Delivery', 'delivery'),
              ],
            ),
            const SizedBox(height: 14),

            // Conditional Inputs
            if (_orderType == 'dine_in') ...[
              Text('Pilih Nomor Meja:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedTableNumber,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                hint: const Text('Pilih Meja Anda'),
                items: tables.map((t) {
                  return DropdownMenuItem<String>(
                    value: t.tableNumber,
                    child: Text('${t.tableNumber} (${t.area})'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedTableNumber = val;
                    final match = tables.where((t) => t.tableNumber == val);
                    if (match.isNotEmpty) {
                      _selectedTableId = match.first.id;
                    }
                  });
                },
              ),
            ] else if (_orderType == 'delivery') ...[
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap Pengantaran *',
                  hintText: 'Contoh: Jl. Mawar No. 12, Kamar Kost 3B',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Nomor WhatsApp Penerima',
                  hintText: '081234567890',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],

            const SizedBox(height: 14),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Catatan Pesanan (Opsional)',
                hintText: 'Contoh: Less ice, gula pisah',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 16),
            // Metode Pembayaran
            Text('Metode Pembayaran:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _paymentMethod = 'qris'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _paymentMethod == 'qris' ? AppColors.activePillCream : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _paymentMethod == 'qris' ? AppColors.roastedCoffee : const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.qr_code_scanner, color: AppColors.espressoDark),
                          const SizedBox(height: 4),
                          Text('QRIS Instan', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _paymentMethod = 'cash'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _paymentMethod == 'cash' ? AppColors.activePillCream : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _paymentMethod == 'cash' ? AppColors.roastedCoffee : const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.payments_outlined, color: AppColors.espressoDark),
                          const SizedBox(height: 4),
                          Text(
                            _orderType == 'delivery' ? 'COD (Tunai)' : 'Bayar di Kasir',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal (${cart.totalItemsCount} item)', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
                Text('Rp ${cart.subtotalAmount.toInt()}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PB1 Pajak (10%)', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
                Text('Rp ${cart.taxAmount.toInt()}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Bayar', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.espressoDark)),
                Text(
                  'Rp ${cart.totalAmount.toInt()}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.roastedCoffee),
                ),
              ],
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.espressoDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _isSubmitting ? null : _submitOrder,
                child: _isSubmitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        'Kirim Pesanan Sekarang',
                        style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String type) {
    final isSelected = _orderType == type;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _orderType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.espressoDark : AppColors.softSand,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
