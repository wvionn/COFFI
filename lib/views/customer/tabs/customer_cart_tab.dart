import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/table_provider.dart';
import '../widgets/customer_payment_sheet.dart';

class CustomerCartTab extends StatelessWidget {
  final VoidCallback onGoToMenu;
  final VoidCallback onOrderPlaced;

  const CustomerCartTab({
    super.key,
    required this.onGoToMenu,
    required this.onOrderPlaced,
  });

  void _showOrderTypePicker(BuildContext context) {
    final cart = context.read<CartProvider>();
    final tableProv = context.read<TableProvider>();
    final availableTables =
        tableProv.tables.where((t) => t.isAvailable).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final isDineIn = cart.isDineIn;

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
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
                  const SizedBox(height: 14),
                  Text(
                    'Pilih Tipe Pesanan & Meja',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.figmaCoffee,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mode Switcher
                  Row(
                    children: [
                      Expanded(
                        child: _buildModalModeCard(
                          title: 'Dine In (Santap Kafe)',
                          subtitle: 'Pilih meja di tempat',
                          icon: Icons.restaurant_rounded,
                          isSelected: isDineIn,
                          onTap: () {
                            cart.setOrderType('dine_in');
                            setModalState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModalModeCard(
                          title: 'Take Away (Bungkus)',
                          subtitle: 'Bawa pulang pesanan',
                          icon: Icons.takeout_dining_rounded,
                          isSelected: !isDineIn,
                          onTap: () {
                            cart.setOrderType('takeaway');
                            setModalState(() {});
                          },
                        ),
                      ),
                    ],
                  ),

                  if (isDineIn) ...[
                    const SizedBox(height: 18),
                    Text(
                      'PILIH NOMOR MEJA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: const Color(0xFFA18A7B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableTables.map((table) {
                        final isChosen =
                            cart.selectedTable?.id == table.id;
                        return InkWell(
                          onTap: () {
                            cart.setSelectedTable(table);
                            setModalState(() {});
                            Navigator.pop(ctx);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isChosen
                                  ? AppColors.figmaCoffee
                                  : const Color(0xFFF7EFE9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isChosen
                                    ? AppColors.figmaCoffee
                                    : const Color(0xFFEADBCE),
                              ),
                            ),
                            child: Text(
                              table.tableNumber,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isChosen
                                    ? Colors.white
                                    : AppColors.figmaCoffee,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.figmaCoffee,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Simpan & Lanjutkan'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF7EFE9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.figmaCoffee : const Color(0xFFEADBCE),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.figmaCoffee : const Color(0xFF8C7769),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.figmaCoffee,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                color: const Color(0xFF9E8E82),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDineIn = cart.isDineIn;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Keranjang Saya
          Text(
            'Keranjang Saya',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: AppColors.figmaCoffee,
            ),
          ),

          const SizedBox(height: 18),

          // Tipe Pesanan Banner Card (Reference matching)
          Material(
            color: const Color(0xFFF7EFE8),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => _showOrderTypePicker(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFEADBCE),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    // Fork & Knife Icon Box
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.figmaCoffee,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Tipe Pesanan Text Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TIPE PESANAN',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: const Color(0xFFA18A7B),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isDineIn
                                ? 'DINE IN — ${cart.selectedTable?.tableNumber ?? "Meja M-05"}'
                                : 'TAKE AWAY — Bungkus',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.figmaCoffee,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFB19A8A),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Empty Cart State or Items List
          if (cart.items.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFEADBCE)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7EFE9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.remove_shopping_cart_outlined,
                      size: 32,
                      color: AppColors.figmaHazelnut,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Keranjang masih kosong',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.figmaCoffee,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih menu favorit Anda sekarang.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF9E8E82),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.figmaCoffee,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                    ),
                    onPressed: onGoToMenu,
                    child: Text(
                      'Eksplor Menu Sekarang',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Cart Items
            ...cart.items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFEFE8DE),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38220F).withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Product Image (Square Rounded 74x74)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 74,
                        height: 74,
                        child: _buildItemImage(item.imageUrl, item.productName),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Details Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name & Trash Button Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.productName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                    color: AppColors.figmaCoffee,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => cart.removeItem(item.id),
                                behavior: HitTestBehavior.opaque,
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 6, bottom: 4),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    color: Color(0xFFD67D72),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 2),

                          // Variants Subtitle
                          Text(
                            item.notes?.isNotEmpty == true
                                ? item.notes!
                                : 'Signature Brew',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF9E8E82),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Price & Quantity Stepper Row (FIXED: Never line-wraps!)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Fixed Price: Given ample width, clean formatting on 1 line
                              Expanded(
                                child: Text(
                                  CurrencyFormatter.formatK(item.subtotal),
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.visible,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                    color: AppColors.figmaCoffee,
                                  ),
                                ),
                              ),

                              // Pill Stepper: - qty +
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3ECE5),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => cart.decrementItem(item.id),
                                      borderRadius: BorderRadius.circular(12),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        child: Icon(
                                          Icons.remove_rounded,
                                          size: 15,
                                          color: AppColors.figmaCoffee,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.figmaCoffee,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => cart.incrementItem(item.id),
                                      borderRadius: BorderRadius.circular(12),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        child: Icon(
                                          Icons.add_rounded,
                                          size: 15,
                                          color: AppColors.figmaCoffee,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // Dashed Divider
            CustomPaint(
              size: const Size(double.infinity, 1),
              painter: _DashedLinePainter(color: const Color(0xFFEADBCE)),
            ),

            const SizedBox(height: 16),

            // Cost Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA18A7B),
                  ),
                ),
                Text(
                  CurrencyFormatter.formatK(cart.subtotalAmount),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.figmaCoffee,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PB1 Tax (10%)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA18A7B),
                  ),
                ),
                Text(
                  CurrencyFormatter.formatK(cart.taxAmount),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.figmaCoffee,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total Bayar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.figmaCoffee,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 2),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.figmaCoffee,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    CurrencyFormatter.formatK(cart.totalAmount),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.figmaCoffee,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // PILIH PEMBAYARAN > Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.figmaCoffee,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  CustomerPaymentSheet.show(
                    context,
                    onOrderSuccess: onOrderPlaced,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PILIH PEMBAYARAN',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemImage(String? url, String productName) {
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('assets/')) {
        return Image.asset(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackImage(productName),
        );
      }
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(productName),
      );
    }
    return _fallbackImage(productName);
  }

  Widget _fallbackImage(String productName) {
    final lower = productName.toLowerCase();
    if (lower.contains('croissant') || lower.contains('pastry')) {
      return Image.asset(
        'assets/images/products/butter_croissant.png',
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      'assets/images/products/coffi_aren.png',
      fit: BoxFit.cover,
    );
  }
}

/// Custom painter for dotted / dashed divider line
class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

