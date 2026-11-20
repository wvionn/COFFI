import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/order_model.dart';
import '../../../models/product_model.dart';
import '../../../providers/admin_dashboard_provider.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/order_provider.dart';
import '../widgets/admin_header.dart';

class AdminDashboardTab extends StatelessWidget {
  final Function(int) onTabNavigate;

  const AdminDashboardTab({super.key, required this.onTabNavigate});

  static const List<String> _hourLabels = [
    '08:00',
    '10:00',
    '12:00',
    '14:00',
    '16:00',
    '18:00',
    '20:00',
    '22:00',
  ];

  static const List<String> _periods = [
    'Hari Ini',
    'Kemarin',
    '7 Hari Terakhir',
    'Bulan Ini',
  ];

  String _shortPeriodLabel(String period) {
    switch (period) {
      case '7 Hari Terakhir':
        return '7 HARI';
      case 'Bulan Ini':
        return 'BULAN INI';
      case 'Kemarin':
        return 'KEMARIN';
      case 'Semua':
        return 'SEMUA';
      case 'Kustom':
        return 'KUSTOM';
      default:
        return 'HARI INI';
    }
  }

  String _transactionSubtitle(String period) {
    switch (period) {
      case '7 Hari Terakhir':
        return 'Dalam 7 hari';
      case 'Bulan Ini':
        return 'Bulan ini';
      case 'Kemarin':
        return 'Kemarin';
      case 'Semua':
        return 'Total semua';
      case 'Kustom':
        return 'Rentang terpilih';
      default:
        return 'Valid hari ini';
    }
  }

  /// Calculate previous-period sales for a real growth trend indicator.
  double _calculatePreviousPeriodOmset(
    List<OrderModel> allOrders,
    AdminDashboardProvider dashboard,
  ) {
    final period = dashboard.selectedPeriod;
    final now = DateTime.now();
    final prevOrders = allOrders.where((order) {
      if (order.isCancelled || order.isWaitingValidation) return false;
      final created = order.createdAt;

      if (period == 'Hari Ini') {
        final yesterday = now.subtract(const Duration(days: 1));
        return created.year == yesterday.year &&
            created.month == yesterday.month &&
            created.day == yesterday.day;
      } else if (period == 'Kemarin') {
        final twoDaysAgo = now.subtract(const Duration(days: 2));
        return created.year == twoDaysAgo.year &&
            created.month == twoDaysAgo.month &&
            created.day == twoDaysAgo.day;
      } else if (period == '7 Hari Terakhir') {
        final diffDays = now.difference(created).inDays;
        return diffDays > 7 && diffDays <= 14;
      } else if (period == 'Bulan Ini') {
        final prevMonth = DateTime(now.year, now.month - 1);
        return created.year == prevMonth.year &&
            created.month == prevMonth.month;
      } else if (period == 'Kustom' && dashboard.customDateRange != null) {
        final r = dashboard.customDateRange!;
        final spanDays = r.end.difference(r.start).inDays + 1;
        final prevStart = r.start.subtract(Duration(days: spanDays));
        final prevEnd = r.start.subtract(const Duration(seconds: 1));
        return !created.isBefore(prevStart) && !created.isAfter(prevEnd);
      }
      return false;
    });

    return prevOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  _ChartSeries _buildChartSeries(List<OrderModel> orders, String period) {
    final now = DateTime.now();

    if (period == '7 Hari Terakhir') {
      final labels = <String>[];
      final buckets = List<double>.filled(7, 0.0);
      final days = List.generate(
        7,
        (i) => DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: 6 - i)),
      );

      for (final d in days) {
        labels.add(DateFormat('dd/MM').format(d));
      }

      for (final order in orders) {
        final od = DateTime(
          order.createdAt.year,
          order.createdAt.month,
          order.createdAt.day,
        );
        for (int i = 0; i < days.length; i++) {
          if (od == days[i]) {
            buckets[i] += order.totalAmount;
            break;
          }
        }
      }
      return _ChartSeries(labels: labels, values: buckets);
    }

    if (period == 'Bulan Ini') {
      const labels = ['Mgg 1', 'Mgg 2', 'Mgg 3', 'Mgg 4', 'Mgg 5'];
      final buckets = List<double>.filled(labels.length, 0.0);
      for (final order in orders) {
        final weekIdx = ((order.createdAt.day - 1) ~/ 7).clamp(0, 4);
        buckets[weekIdx] += order.totalAmount;
      }
      return _ChartSeries(labels: labels, values: buckets);
    }

    // Default: Hourly breakdown for 'Hari Ini' & 'Kemarin'
    final buckets = List<double>.filled(_hourLabels.length, 0.0);
    for (final order in orders) {
      final hour = order.createdAt.hour;
      int idx;
      if (hour < 9) {
        idx = 0;
      } else if (hour <= 10) {
        idx = 1;
      } else if (hour <= 12) {
        idx = 2;
      } else if (hour <= 14) {
        idx = 3;
      } else if (hour <= 16) {
        idx = 4;
      } else if (hour <= 18) {
        idx = 5;
      } else if (hour <= 20) {
        idx = 6;
      } else {
        idx = 7;
      }
      buckets[idx] += order.totalAmount;
    }
    return _ChartSeries(labels: _hourLabels, values: buckets);
  }

  String _formatAxisAmount(double value) {
    if (value <= 0) return '0k';
    if (value >= 1000000) {
      final m = value / 1000000;
      return '${m == m.roundToDouble() ? m.toInt() : m.toStringAsFixed(1)}M';
    }
    final k = (value / 1000).round();
    return '${k}k';
  }

  String _resolveCategoryName(MenuProvider menu, ProductModel? product) {
    if (product?.categoryId == null) return 'Signature Menu';
    for (final cat in menu.categories) {
      if (cat.id == product!.categoryId) {
        return cat.name;
      }
    }
    return 'Signature Menu';
  }

  String _resolveUnit(String productName, String categoryName) {
    final combined = '${productName.toLowerCase()} ${categoryName.toLowerCase()}';
    const pcsKeywords = [
      'pastry',
      'food',
      'snack',
      'meal',
      'croissant',
      'roti',
      'nasi',
      'fries',
      'cake',
      'dessert',
      'beans',
    ];
    for (final kw in pcsKeywords) {
      if (combined.contains(kw)) return 'PCS';
    }
    return 'CUP';
  }

  ProductModel? _findMatchingProduct(MenuProvider menu, String itemName) {
    final lower = itemName.toLowerCase().trim();
    for (final p in menu.products) {
      if (p.name.toLowerCase().trim() == lower) return p;
    }
    for (final p in menu.products) {
      if (p.name.toLowerCase().contains(lower) ||
          lower.contains(p.name.toLowerCase())) {
        return p;
      }
    }
    final words = lower.split(' ').where((w) => w.length >= 4).toList();
    for (final p in menu.products) {
      final pName = p.name.toLowerCase();
      if (words.any((w) => pName.contains(w))) return p;
    }
    return null;
  }

  void _showTopProductDetail(
    BuildContext context,
    _TopMenuEntry entry,
    MenuProvider menu,
  ) {
    final product = entry.product;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                  AdminProductImage(
                    imageUrl: entry.imageUrl,
                    size: 62,
                    borderRadius: 16,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.figmaCoffee,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.category,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: const Color(0xFF9C7F6C),
                          ),
                        ),
                        if (product != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${CurrencyFormatter.format(product.price)} • Stok ${product.trackStock ? '${product.stock} porsi' : 'Bebas'}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.figmaCoffee,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7EFE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${entry.quantity} ${entry.unit}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.figmaCoffee,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.figmaCoffee,
                        side: const BorderSide(color: Color(0xFFE5D8CC)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        onTabNavigate(2);
                      },
                      child: Text(
                        'Kelola Stok',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.figmaCoffee,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        menu.selectCategory(null);
                        menu.setSearchQuery(entry.name);
                        onTabNavigate(1);
                      },
                      child: Text(
                        'Lihat di Produk',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final dashboard = context.watch<AdminDashboardProvider>();

    final filteredOrders = dashboard.getFilteredOrders(orderProvider.orders);
    final totalOmset = dashboard.calculateTotalOmset(filteredOrders);
    final grossProfit = dashboard.calculateGrossProfit(filteredOrders);
    final averageMargin = dashboard.calculateAverageMargin(filteredOrders);
    final previousOmset = _calculatePreviousPeriodOmset(
      orderProvider.orders,
      dashboard,
    );

    final double? growthPercent;
    if (previousOmset > 0) {
      growthPercent = ((totalOmset - previousOmset) / previousOmset) * 100;
    } else if (totalOmset > 0) {
      growthPercent = 100.0;
    } else {
      growthPercent = null;
    }

    final lowStockItems = menu.lowStockProducts;
    final topSellingMap = dashboard.getTopSellingItems(filteredOrders);
    final chartSeries = _buildChartSeries(
      filteredOrders,
      dashboard.selectedPeriod,
    );

    final List<_TopMenuEntry> topEntries = [];
    if (topSellingMap.isNotEmpty) {
      topSellingMap.entries.take(4).forEach((entry) {
        final matched = _findMatchingProduct(menu, entry.key);
        final catName = _resolveCategoryName(menu, matched);
        topEntries.add(
          _TopMenuEntry(
            name: matched?.name ?? entry.key,
            category: catName,
            imageUrl: matched?.imageUrl,
            quantity: entry.value,
            unit: _resolveUnit(matched?.name ?? entry.key, catName),
            product: matched,
          ),
        );
      });
    } else {
      for (final p in menu.products.take(3)) {
        final catName = _resolveCategoryName(menu, p);
        topEntries.add(
          _TopMenuEntry(
            name: p.name,
            category: catName,
            imageUrl: p.imageUrl,
            quantity: 0,
            unit: _resolveUnit(p.name, catName),
            product: p,
          ),
        );
      }
    }

    final maxQty = topEntries.isEmpty
        ? 0
        : topEntries.map((e) => e.quantity).reduce(math.max);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F1),
      body: Column(
        children: [
          AdminHeader(onTabNavigate: onTabNavigate),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.figmaCoffee,
              onRefresh: () async {
                await Future.wait([
                  menu.refreshProducts(),
                  orderProvider.init(),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. STANDOUT TOTAL OMZET HERO CARD
                    _buildSalesHeroCard(
                      totalOmset: totalOmset,
                      grossProfit: grossProfit,
                      averageMargin: averageMargin,
                      periodLabel: _shortPeriodLabel(dashboard.selectedPeriod),
                      growthPercent: growthPercent,
                      onTap: () => onTabNavigate(4),
                    ),

                    const SizedBox(height: 14),

                    // 2. TRANSAKSI & STOK KRITIS ROW
                    Row(
                      children: [
                        Expanded(
                          child: _buildTransactionCard(
                            count: filteredOrders.length,
                            subtitle:
                                _transactionSubtitle(dashboard.selectedPeriod),
                            onTap: () => onTabNavigate(3),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildLowStockCard(
                            lowStockCount: lowStockItems.length,
                            onTap: () => onTabNavigate(2),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // 3. GRAFIK PENJUALAN CARD
                    _buildSalesChartCard(
                      series: chartSeries,
                      selectedPeriod: dashboard.selectedPeriod,
                      onPeriodSelected: (period) => dashboard.setPeriod(period),
                    ),

                    const SizedBox(height: 18),

                    // 4. MENU TERLARIS CARD
                    _buildTopMenuCard(
                      context: context,
                      menu: menu,
                      entries: topEntries,
                      maxQty: maxQty,
                      onViewAll: () {
                        menu.setSearchQuery('');
                        onTabNavigate(1);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesHeroCard({
    required double totalOmset,
    required double grossProfit,
    required double averageMargin,
    required String periodLabel,
    required double? growthPercent,
    required VoidCallback onTap,
  }) {
    final isNegative = (growthPercent ?? 0) < 0;
    final Color trendBg;
    final Color trendFg;
    final String trendText;

    if (growthPercent == null) {
      trendBg = Colors.white.withOpacity(0.14);
      trendFg = const Color(0xFFF3DFCE);
      trendText = '0%';
    } else if (isNegative) {
      trendBg = const Color(0xFFDC2626).withOpacity(0.24);
      trendFg = const Color(0xFFFECACA);
      trendText = '-${growthPercent.abs().round()}%';
    } else {
      trendBg = const Color(0xFF16A34A).withOpacity(0.26);
      trendFg = const Color(0xFFBBF7D0);
      trendText = '+${growthPercent.abs().round()}%';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5A3726),
            Color(0xFF42271B),
            Color(0xFF2F1B12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A2E21).withOpacity(0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Warm decorative radial highlights
            Positioned(
              right: -28,
              top: -28,
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD9A679).withOpacity(0.14),
                ),
              ),
            ),
            Positioned(
              right: 26,
              bottom: -36,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7C29B).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: const Color(0xFFE7C29B).withOpacity(0.35),
                              ),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 18,
                              color: Color(0xFFFBE7CE),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOTAL OMZET',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: const Color(0xFFF3DFCE),
                                  ),
                                ),
                                Text(
                                  'Periode $periodLabel',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: trendBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: trendFg.withOpacity(0.28),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (growthPercent != null) ...[
                                  Icon(
                                    isNegative
                                        ? Icons.trending_down_rounded
                                        : Icons.trending_up_rounded,
                                    size: 14,
                                    color: trendFg,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  trendText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: trendFg,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          CurrencyFormatter.format(totalOmset),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.7,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.11),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Laba Kotor ${CurrencyFormatter.formatCompact(grossProfit)} • Margin ${averageMargin.toStringAsFixed(0)}%',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFF6E7D8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Detail',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFFDE68A),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: Color(0xFFFDE68A),
                                ),
                              ],
                            ),
                          ],
                        ),
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

  Widget _buildTransactionCard({
    required int count,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3ECE4), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.figmaCoffee.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRANSAKSI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: const Color(0xFFA0806D),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_rounded,
                      size: 22,
                      color: Color(0xFF936F5A),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$count',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: AppColors.figmaCoffee,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFB39D8E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLowStockCard({
    required int lowStockCount,
    required VoidCallback onTap,
  }) {
    final hasWarning = lowStockCount > 0;
    const warningGold = Color(0xFFC5A200);
    final accentColor = hasWarning ? warningGold : AppColors.figmaReadyGreen;
    final bgColor =
        hasWarning ? const Color(0xFFFFF8F5) : const Color(0xFFF5FCF8);
    final borderColor =
        hasWarning ? const Color(0xFFEAE3B0) : const Color(0xFFC5EFDC);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.figmaCoffee.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STOK KRITIS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      hasWarning
                          ? Icons.warning_rounded
                          : Icons.check_circle_rounded,
                      size: 22,
                      color: accentColor,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '$lowStockCount Item',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  hasWarning ? 'Butuh Restock' : 'Semua Aman',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalesChartCard({
    required _ChartSeries series,
    required String selectedPeriod,
    required ValueChanged<String> onPeriodSelected,
  }) {
    final buckets = series.values;
    final labels = series.labels;
    final rawMax = buckets.isEmpty ? 0.0 : buckets.reduce(math.max);
    final double interval;
    final double maxY;

    if (rawMax <= 0) {
      interval = 200000;
      maxY = 800000;
    } else if (rawMax <= 100000) {
      interval = 25000;
      maxY = 100000;
    } else if (rawMax <= 400000) {
      interval = 100000;
      maxY = 400000;
    } else {
      final step = ((rawMax * 1.15) / 4 / 50000).ceil() * 50000.0;
      interval = math.max(step, 100000);
      maxY = interval * 4;
    }

    final spots = List.generate(
      buckets.length,
      (i) => FlSpot(i.toDouble(), buckets[i]),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3ECE4), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.figmaCoffee.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Grafik Penjualan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.figmaCoffee,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: onPeriodSelected,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                itemBuilder: (_) => _periods
                    .map(
                      (p) => PopupMenuItem<String>(
                        value: p,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                p,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: p == selectedPeriod
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: AppColors.figmaCoffee,
                                ),
                              ),
                            ),
                            if (p == selectedPeriod)
                              const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: AppColors.figmaCoffee,
                              ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EFE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _shortPeriodLabel(selectedPeriod),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: const Color(0xFF9C7F6C),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 15,
                        color: Color(0xFF9C7F6C),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 205,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: math.max(1, labels.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: Color(0xFFF1E8DF),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(
                        color: Color(0xFFE4D8CC),
                        width: 1,
                      ),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          if (value > maxY) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              _formatAxisAmount(value),
                              textAlign: TextAlign.right,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFB39D8E),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[idx],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFB39D8E),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.figmaCoffee,
                      tooltipBorderRadius: BorderRadius.circular(12),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.toInt().clamp(
                            0,
                            labels.length - 1,
                          );
                          return LineTooltipItem(
                            '${labels[idx]}\n${CurrencyFormatter.format(spot.y)}',
                            GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      preventCurveOverShooting: true,
                      color: const Color(0xFF6B4736),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 3.5,
                          color: const Color(0xFF6B4736),
                          strokeWidth: 0,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF6B4736).withOpacity(0.11),
                            const Color(0xFF6B4736).withOpacity(0.01),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMenuCard({
    required BuildContext context,
    required MenuProvider menu,
    required List<_TopMenuEntry> entries,
    required int maxQty,
    required VoidCallback onViewAll,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3ECE4), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.figmaCoffee.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Menu Terlaris',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.figmaCoffee,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onViewAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'LIHAT SEMUA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: const Color(0xFF9C7F6C),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Belum ada data penjualan menu.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ...List.generate(entries.length, (index) {
              final item = entries[index];
              final ratio = maxQty > 0
                  ? (item.quantity / maxQty).clamp(0.14, 1.0)
                  : 0.0;
              final barColor = index == 0
                  ? const Color(0xFF6B4736)
                  : AppColors.figmaHazelnut;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == entries.length - 1 ? 0 : 12,
                ),
                child: Material(
                  color: const Color(0xFFFCF8F4),
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _showTopProductDetail(context, item, menu),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFEFE6DC),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          AdminProductImage(
                            imageUrl: item.imageUrl,
                            size: 54,
                            borderRadius: 14,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.figmaCoffee,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFA88D7B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 82,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    text: '${item.quantity}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.figmaCoffee,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: ' ${item.unit}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFFA88D7B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 6,
                                  width: 78,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8DACC),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: ratio,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: barColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ChartSeries {
  final List<String> labels;
  final List<double> values;

  const _ChartSeries({required this.labels, required this.values});
}

class _TopMenuEntry {
  final String name;
  final String category;
  final String? imageUrl;
  final int quantity;
  final String unit;
  final ProductModel? product;

  const _TopMenuEntry({
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.quantity,
    required this.unit,
    this.product,
  });
}
