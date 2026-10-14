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
  String _selectedFilter = 'Semua'; // 'Semua', 'Sedang Diracik', 'Siap Ambil'

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final allOrders = orderProvider.orders.where((o) => !o.isCancelled && !o.isCompleted).toList();

    List<OrderModel> displayedOrders;
    if (_selectedFilter == 'Sedang Diracik') {
      displayedOrders = allOrders.where((o) => o.isProcessing || o.isPending).toList();
    } else if (_selectedFilter == 'Siap Ambil') {
      displayedOrders = allOrders.where((o) => o.isReady).toList();
    } else {
      displayedOrders = allOrders;
    }

    return Scaffold(
      backgroundColor: AppColors.softSand,
      appBar: AppBar(
        title: Text(
          'LIVE STATUS ANTREAN PESANAN',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                _buildFilterChip('Semua (${allOrders.length})', 'Semua'),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Sedang Diracik (${orderProvider.newKitchenOrders.length + orderProvider.inProgressKitchenOrders.length})',
                  'Sedang Diracik',
                ),
                const SizedBox(width: 8),
                _buildFilterChip('Siap Ambil (${orderProvider.readyKitchenOrders.length})', 'Siap Ambil'),
              ],
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
                          'Semua pesanan pelanggan sudah selesai diambil.',
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

                      if (order.isReady) {
                        statusColor = AppColors.matchaGreen;
                        statusText = '🟢 SIAP DIAMBIL';
                        statusIcon = Icons.check_circle_rounded;
                      } else if (order.isProcessing) {
                        statusColor = AppColors.amberOrange;
                        statusText = '🟡 SEDANG DIRACIK BARISTA';
                        statusIcon = Icons.soup_kitchen;
                      } else {
                        statusColor = AppColors.coldBrewBlue;
                        statusText = '⚪ MENUNGGU ANTREAN';
                        statusIcon = Icons.hourglass_top;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: order.isReady ? AppColors.matchaGreen : const Color(0xFFE5E7EB),
                            width: order.isReady ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: order.isReady
                                  ? AppColors.matchaGreen.withOpacity(0.12)
                                  : Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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

                            // Customer Name prominently displayed
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.espressoDark,
                                        ),
                                      ),
                                      Text(
                                        'No. Antrean: #${order.invoiceNumber}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            Text(
                              order.items.map((i) => '${i.quantity}x ${i.productName}').join(', '),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),

                            // Direct "Pesanan Selesai" button when ready
                            if (order.isReady) ...[
                              const SizedBox(height: 16),
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
                                          content: Text('Pesanan Kak ${order.customerName ?? "Pelanggan"} selesai & diserahkan!'),
                                          backgroundColor: AppColors.matchaGreen,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.check_circle_outline, size: 20),
                                  label: Text(
                                    'Pesanan Selesai',
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

  Widget _buildFilterChip(String label, String key) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.roastedCoffee : AppColors.softSand,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
