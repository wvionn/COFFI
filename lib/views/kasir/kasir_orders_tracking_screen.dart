import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class KasirOrdersTrackingScreen extends StatefulWidget {
  const KasirOrdersTrackingScreen({super.key});

  @override
  State<KasirOrdersTrackingScreen> createState() => _KasirOrdersTrackingScreenState();
}

class _KasirOrdersTrackingScreenState extends State<KasirOrdersTrackingScreen> {
  String _selectedFilter = 'Semua'; // 'Semua', 'Perlu Validasi', 'Sedang Diracik', 'Siap Ambil'

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final allOrders = orderProvider.orders.where((o) => !o.isCancelled && !o.isCompleted).toList();

    List<OrderModel> displayedOrders;
    if (_selectedFilter == 'Perlu Validasi') {
      displayedOrders = allOrders.where((o) => o.isWaitingValidation).toList();
    } else if (_selectedFilter == 'Sedang Diracik') {
      displayedOrders = allOrders.where((o) => o.isProcessing || o.isPending).toList();
    } else if (_selectedFilter == 'Siap Ambil') {
      displayedOrders = allOrders.where((o) => o.isReady || o.isDelivering).toList();
    } else {
      displayedOrders = allOrders;
    }

    final waitingCount = orderProvider.waitingValidationOrders.length;

    return Scaffold(
      backgroundColor: AppColors.softSand,
      appBar: AppBar(
        title: Text(
          'LIVE STATUS ANTREAN & VALIDASI',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs (Scrollable)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua (${allOrders.length})', 'Semua'),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    '⚡ Perlu Validasi ($waitingCount)',
                    'Perlu Validasi',
                    hasAlert: waitingCount > 0,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Sedang Diracik (${orderProvider.newKitchenOrders.length + orderProvider.inProgressKitchenOrders.length})',
                    'Sedang Diracik',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Siap Ambil/Antar (${orderProvider.readyKitchenOrders.length + orderProvider.deliveringOrders.length})',
                    'Siap Ambil',
                  ),
                ],
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: displayedOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 54, color: AppColors.matchaGreen),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak Ada Antrean Berjalan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Semua pesanan pelanggan sudah selesai.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayedOrders.length,
                    itemBuilder: (context, index) {
                      final order = displayedOrders[index];

                      Color statusColor;
                      String statusText;
                      IconData statusIcon;

                      if (order.isWaitingValidation) {
                        statusColor = AppColors.berryRed;
                        statusText = '🟠 PERLU VALIDASI (Online)';
                        statusIcon = Icons.notifications_active_rounded;
                      } else if (order.isDelivering) {
                        statusColor = AppColors.coldBrewBlue;
                        statusText = '🛵 SEDANG DIANTAR KURIR';
                        statusIcon = Icons.delivery_dining;
                      } else if (order.isReady) {
                        statusColor = AppColors.matchaGreen;
                        statusText = order.isDelivery ? '🟢 SIAP DIANTAR' : '🟢 SIAP DIAMBIL';
                        statusIcon = Icons.check_circle_rounded;
                      } else if (order.isProcessing) {
                        statusColor = AppColors.amberOrange;
                        statusText = '🟡 SEDANG DIRACIK BARISTA';
                        statusIcon = Icons.soup_kitchen;
                      } else {
                        statusColor = AppColors.roastedCoffee;
                        statusText = '⚪ MENUNGGU DIRACIK DAPUR';
                        statusIcon = Icons.hourglass_top;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: order.isWaitingValidation
                                ? AppColors.berryRed
                                : (order.isReady ? AppColors.matchaGreen : const Color(0xFFE5E7EB)),
                            width: (order.isWaitingValidation || order.isReady) ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: order.isWaitingValidation
                                  ? AppColors.berryRed.withOpacity(0.08)
                                  : (order.isReady
                                      ? AppColors.matchaGreen.withOpacity(0.12)
                                      : Colors.black.withOpacity(0.04)),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(statusIcon, color: statusColor, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      statusText,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.softSand,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '⏱️ ${order.elapsedMinutes} mnt lalu',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Customer Name & Order Type Badge
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.activePillCream,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.person_rounded, size: 18, color: AppColors.espressoDark),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Atas Nama: Kak ${order.customerName?.isNotEmpty == true ? order.customerName : "Pelanggan"}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.espressoDark,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '#${order.invoiceNumber} • ',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: order.isDelivery
                                                  ? const Color(0xFFE0F2FE)
                                                  : (order.isDineIn ? const Color(0xFFFEF3C7) : const Color(0xFFF3E8FF)),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              order.isDelivery
                                                  ? '🛵 DELIVERY'
                                                  : (order.isDineIn ? '🍽️ MEJA ${order.tableNumber ?? "-"}' : '🛍️ TAKEAWAY'),
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: order.isDelivery
                                                    ? const Color(0xFF0369A1)
                                                    : (order.isDineIn ? const Color(0xFFB45309) : const Color(0xFF7E22CE)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Rp ${order.totalAmount.toInt()}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.roastedCoffee,
                                  ),
                                ),
                              ],
                            ),

                            // Items List
                            const SizedBox(height: 10),
                            Text(
                              order.items.map((i) => '${i.quantity}x ${i.productName}').join(', '),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),

                            // Notes / Address if any
                            if (order.notes != null && order.notes!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  order.notes!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],

                            // ACTION BUTTONS

                            // 1. Perlu Validasi Action Buttons
                            if (order.isWaitingValidation) ...[
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: SizedBox(
                                      height: 44,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.matchaGreen,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () async {
                                          await orderProvider.updateStatus(order.id, 'pending');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Pesanan Kak ${order.customerName ?? "Pelanggan"} divalidasi & masuk ke Dapur!'),
                                                backgroundColor: AppColors.matchaGreen,
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                                        label: Text(
                                          'Terima & Masuk Dapur',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 1,
                                    child: SizedBox(
                                      height: 44,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.berryRed,
                                          side: const BorderSide(color: AppColors.berryRed),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () async {
                                          await orderProvider.updateStatus(order.id, 'dibatalkan');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Pesanan telah dibatalkan.'),
                                                backgroundColor: AppColors.berryRed,
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          'Tolak',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // 2. Siap Diambil / Diantar Actions
                            if (order.isReady) ...[
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: order.isDelivery ? AppColors.coldBrewBlue : AppColors.matchaGreen,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (order.isDelivery) {
                                      await orderProvider.updateStatus(order.id, 'dikirim');
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Pesanan Kak ${order.customerName ?? "Pelanggan"} sedang diantar kurir!'),
                                            backgroundColor: AppColors.coldBrewBlue,
                                          ),
                                        );
                                      }
                                    } else {
                                      await orderProvider.updateStatus(order.id, 'selesai');
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Pesanan Kak ${order.customerName ?? "Pelanggan"} selesai & diserahkan!'),
                                            backgroundColor: AppColors.matchaGreen,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: Icon(order.isDelivery ? Icons.delivery_dining : Icons.check_circle_outline, size: 20),
                                  label: Text(
                                    order.isDelivery ? 'Mulai Antar (Ke Kurir)' : 'Pesanan Selesai (Diserahkan)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // 3. Sedang Diantar Actions
                            if (order.isDelivering) ...[
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.matchaGreen,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await orderProvider.updateStatus(order.id, 'selesai');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Pesanan Kak ${order.customerName ?? "Pelanggan"} berhasil sampai ke pelanggan!'),
                                          backgroundColor: AppColors.matchaGreen,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.done_all_rounded, size: 20),
                                  label: Text(
                                    'Konfirmasi Pesanan Sampai (Selesai)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String key, {bool hasAlert = false}) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (hasAlert ? AppColors.berryRed : AppColors.roastedCoffee)
              : (hasAlert ? const Color(0xFFFFECEB) : AppColors.softSand),
          borderRadius: BorderRadius.circular(20),
          border: hasAlert && !isSelected ? Border.all(color: AppColors.berryRed.withOpacity(0.5)) : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: (isSelected || hasAlert) ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (hasAlert ? AppColors.berryRed : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
