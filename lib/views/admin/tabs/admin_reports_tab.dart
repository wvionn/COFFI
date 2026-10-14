import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/admin_dashboard_provider.dart';
import '../../../providers/order_provider.dart';

class AdminReportsTab extends StatelessWidget {
  const AdminReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final dashboard = context.watch<AdminDashboardProvider>();

    final filteredOrders = dashboard.getFilteredOrders(orderProvider.orders);
    final totalOmset = dashboard.calculateTotalOmset(filteredOrders);
    final totalHpp = dashboard.calculateTotalHpp(filteredOrders);
    final grossProfit = dashboard.calculateGrossProfit(filteredOrders);
    final averageMargin = dashboard.calculateAverageMargin(filteredOrders);
    final aov = dashboard.calculateAverageOrderValue(filteredOrders);
    final topSelling = dashboard.getTopSellingItems(filteredOrders);

    final dateFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: AppColors.oatMilkFoam,
      appBar: AppBar(
        title: const Text('LAPORAN PENJUALAN & ANALITIK'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Filter Selector
            Row(
              children: [
                const Icon(Icons.date_range, size: 20, color: AppColors.roastedCoffee),
                const SizedBox(width: 8),
                Text(
                  'Periode Laporan:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: dashboard.selectedPeriod,
                  underline: const SizedBox(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.espressoDark,
                  ),
                  items: ['Hari Ini', 'Kemarin', '7 Hari Terakhir', 'Bulan Ini']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) dashboard.setPeriod(val);
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Financial Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RINGKASAN FINANSIAL',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildStatRow('Total Omset (Kotor):', CurrencyFormatter.format(totalOmset), isBold: true),
                  _buildStatRow('Total HPP (Modal):', CurrencyFormatter.format(totalHpp)),
                  const Divider(height: 16),
                  _buildStatRow('Laba Kotor:', CurrencyFormatter.format(grossProfit), isBold: true, highlightColor: AppColors.matchaGreen),
                  _buildStatRow('Rata-rata Margin:', '${averageMargin.toStringAsFixed(1)}%'),
                  _buildStatRow('Total Transaksi:', '${filteredOrders.length} Pesanan'),
                  _buildStatRow('Rata-rata Belanja (AOV):', CurrencyFormatter.format(aov)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Top 5 Best Sellers
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: AppColors.warmCaramel, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'TOP 5 MENU TERLARIS:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (topSelling.isEmpty)
                    Text(
                      'Belum ada transaksi di periode ini',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                    )
                  else
                    ...topSelling.entries.toList().asMap().entries.map((entry) {
                      final rank = entry.key + 1;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: rank == 1
                                    ? AppColors.warmCaramel
                                    : (rank <= 3 ? AppColors.creamLatte : AppColors.oatMilkFoam),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$rank',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: rank == 1 ? Colors.white : AppColors.espressoDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.key,
                                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              '${item.value} porsi',
                              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.roastedCoffee),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recent Transactions
            Text(
              'RIWAYAT TRANSAKSI TERAKHIR:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            if (filteredOrders.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Text('Belum ada transaksi', style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted)),
              )
            else
              ...filteredOrders.take(10).map((order) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.creamLatte.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt, size: 18, color: AppColors.espressoDark),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${order.invoiceNumber} • ${dateFormat.format(order.createdAt)}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              order.isDineIn ? (order.tableNumber ?? "Meja") : "Takeaway: ${order.customerName ?? 'Tamu'}",
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(order.totalAmount),
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.roastedCoffee),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isBold = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: highlightColor ?? AppColors.espressoDark,
            ),
          ),
        ],
      ),
    );
  }
}
