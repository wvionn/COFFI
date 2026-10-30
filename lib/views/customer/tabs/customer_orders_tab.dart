import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/order_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';

class CustomerOrdersTab extends StatelessWidget {
  final VoidCallback onGoToMenu;

  const CustomerOrdersTab({super.key, required this.onGoToMenu});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final auth = context.watch<AuthProvider>();
    final profile = auth.currentProfile;

    final customerOrders = orderProvider.getCustomerOrders(
      customerId: profile?.id,
      customerName: profile?.fullName,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Status & Riwayat Pesanan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),

        Expanded(
          child: customerOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.figmaSoftCream,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          size: 46,
                          color: AppColors.figmaHazelnut,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum Ada Pesanan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pesan kopi atau pastry favoritmu sekarang!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.figmaCoffee,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        ),
                        onPressed: onGoToMenu,
                        icon: const Icon(Icons.coffee_rounded, size: 18),
                        label: Text(
                          'Eksplor Menu',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                  itemCount: customerOrders.length,
                  itemBuilder: (ctx, index) {
                    final order = customerOrders[index];
                    return _buildOrderCard(context, order);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
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
      badgeText = order.isDelivery ? 'Siap Diantar' : 'Siap Diambil di Bar/Kasir';
      badgeIcon = Icons.check_circle_rounded;
    } else if (order.isDelivering) {
      badgeColor = AppColors.coldBrewBlue;
      badgeText = 'Sedang Diantar Kurir';
      badgeIcon = Icons.delivery_dining_rounded;
    } else if (order.isCompleted) {
      badgeColor = AppColors.textMuted;
      badgeText = 'Pesanan Selesai';
      badgeIcon = Icons.done_all_rounded;
    } else {
      badgeColor = AppColors.berryRed;
      badgeText = 'Dibatalkan';
      badgeIcon = Icons.cancel_rounded;
    }

    final timeStr = DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEADBCE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38220F).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.invoiceNumber,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 13, color: badgeColor),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            '$timeStr • ${order.orderType == 'dine_in' ? 'Dine In (${order.tableNumber ?? "Meja"})' : 'Take Away'}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),

          const Divider(height: 20, color: Color(0xFFF0E7DD)),

          // Items summary
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.quantity}x ${item.productName}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatRupiah(item.subtotal),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 10),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                CurrencyFormatter.formatRupiah(order.totalAmount),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.figmaCoffee,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
