import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/admin_dashboard_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/order_provider.dart';
import '../../kasir/kasir_main_screen.dart';

class AdminDashboardTab extends StatelessWidget {
  final Function(int) onTabNavigate;

  const AdminDashboardTab({super.key, required this.onTabNavigate});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final menu = context.watch<MenuProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final dashboard = context.watch<AdminDashboardProvider>();

    final todayOrders = dashboard.getFilteredOrders(orderProvider.orders);
    final totalOmset = dashboard.calculateTotalOmset(todayOrders);
    final netProfit = dashboard.calculateGrossProfit(todayOrders);
    final activeTickets =
        orderProvider.newKitchenOrders.length +
        orderProvider.inProgressKitchenOrders.length;
    final lowStockItems = menu.lowStockProducts;

    String todayDate;
    try {
      todayDate = DateFormat(
        'EEEE, dd MMM yyyy',
        'id_ID',
      ).format(DateTime.now());
    } catch (_) {
      todayDate = DateFormat('dd MMM yyyy').format(DateTime.now());
    }

    return Scaffold(
      backgroundColor: AppColors.oatMilkFoam,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cafeku Owner Dashboard',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Halo, ${auth.currentProfile?.fullName ?? "Owner"} • $todayDate',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.creamLatte,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Omset Hari Ini Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.coffeeGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.espressoDark.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
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
                          const Icon(
                            Icons.monetization_on_rounded,
                            color: AppColors.creamLatte,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'OMSET HARI INI',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.creamLatte,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.matchaGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '+18% ↗',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    CurrencyFormatter.format(totalOmset),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${todayOrders.length} Transaksi  |  Estimasi Laba: ${CurrencyFormatter.format(netProfit)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.creamLatte,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Ringkasan Operasional (4 Cards Grid)
            Text(
              'RINGKASAN OPERASIONAL:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.confirmation_number_outlined,
                    iconColor: AppColors.roastedCoffee,
                    title: 'Antrean Aktif',
                    value: '$activeTickets Antrean',
                    subtitle: 'Menunggu & diracik',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const KasirMainScreen(isOpenedFromAdmin: true),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.soup_kitchen_rounded,
                    iconColor: AppColors.amberOrange,
                    title: 'Pesanan Dapur',
                    value:
                        '${orderProvider.inProgressKitchenOrders.length} Diracik',
                    subtitle: 'Proses barista',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.warning_amber_rounded,
                    iconColor: lowStockItems.isNotEmpty
                        ? AppColors.berryRed
                        : AppColors.matchaGreen,
                    title: 'Stok Menipis',
                    value: '${lowStockItems.length} Bahan',
                    subtitle: lowStockItems.isNotEmpty
                        ? 'Perlu Restock'
                        : 'Semua Aman',
                    onTap: () => onTabNavigate(2), // Tab stok
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.people_alt_rounded,
                    iconColor: AppColors.coldBrewBlue,
                    title: 'Staf Aktif',
                    value: '${auth.demoStaff.length} Staf',
                    subtitle: 'Kasir & Barista',
                    onTap: () => onTabNavigate(4), // Tab staf / settings
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),



            // Critical Low Stock Warning
            if (lowStockItems.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.berryRed.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.berryRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PERINGATAN STOK KRITIS:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.berryRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...lowStockItems.take(3).map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '• ${item.name}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              item.stock == 0 ? 'HABIS' : 'Sisa ${item.stock}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: item.stock == 0
                                    ? AppColors.berryRed
                                    : AppColors.amberOrange,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warmCaramel,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => onTabNavigate(2),
                        child: const Text('RESTOCK SEKARANG ➔'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.espressoDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
