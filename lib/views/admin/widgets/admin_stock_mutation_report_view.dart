import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/product_model.dart';
import '../../../models/stock_movement_model.dart';

class AdminStockMutationReportView extends StatelessWidget {
  final List<StockMovementModel> movements;
  final List<ProductModel> products;
  final Future<void> Function() onRefresh;

  const AdminStockMutationReportView({
    super.key,
    required this.movements,
    required this.products,
    required this.onRefresh,
  });

  static const _monthAbbr = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MEI',
    'JUN',
    'JUL',
    'AGU',
    'SEP',
    'OKT',
    'NOV',
    'DES',
  ];

  String _formatDateGroupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);
    final dayMonth = '${target.day} ${_monthAbbr[target.month - 1]}';

    if (target == today) return 'HARI INI, $dayMonth';
    if (target == yesterday) return 'KEMARIN, $dayMonth';
    return '$dayMonth ${target.year}';
  }

  String _resolveUnit(StockMovementModel movement, Map<String, ProductModel> map) {
    final product = map[movement.productId];
    return product?.displayUnit ?? 'cup';
  }

  String _resolveProductName(
    StockMovementModel movement,
    Map<String, ProductModel> map,
  ) {
    if (movement.productName.trim().isNotEmpty &&
        movement.productName.trim().toLowerCase() != 'produk') {
      return movement.productName.trim();
    }
    return map[movement.productId]?.name ?? 'Produk';
  }

  String _resolveReasonLabel(StockMovementModel m) {
    final raw = m.notes?.trim() ?? '';
    if (raw.isNotEmpty) {
      if (raw.toLowerCase().startsWith('opname:')) {
        return 'Stock Opname';
      }
      if (raw.toLowerCase().contains('restock')) {
        return 'Restock';
      }
      if (raw.toLowerCase().contains('pesanan') ||
          raw.toLowerCase().contains('penjualan')) {
        return 'Penjualan';
      }
      return raw;
    }
    if (m.isIn) return 'Restock';
    if (m.isOut) return 'Penjualan';
    return 'Stock Opname';
  }

  void _showMovementDetailSheet(
    BuildContext context,
    StockMovementModel m,
    String productName,
    String unit,
  ) {
    final fullDate = DateFormat('dd MMM yyyy, HH:mm').format(m.createdAt);
    final isIn = m.isIn;
    final isOut = m.isOut;
    final String deltaText;
    final Color deltaColor;
    final String typeLabel;

    if (isIn) {
      deltaText = '+${CurrencyFormatter.formatNumber(m.quantity.abs())} $unit';
      deltaColor = const Color(0xFF16A34A);
      typeLabel = 'STOK MASUK (IN)';
    } else if (isOut) {
      deltaText = '-${CurrencyFormatter.formatNumber(m.quantity.abs())} $unit';
      deltaColor = const Color(0xFFDC2626);
      typeLabel = 'STOK KELUAR (OUT)';
    } else {
      final sign = m.quantity >= 0 ? '+' : '-';
      deltaText = '$sign${CurrencyFormatter.formatNumber(m.quantity.abs())} $unit';
      deltaColor = const Color(0xFFB45309);
      typeLabel = 'PENYESUAIAN (ADJ)';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
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
                  _buildTypeIconBox(m),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2B1B12),
                          ),
                        ),
                        Text(
                          fullDate,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF9C7F6C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    deltaText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: deltaColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF6F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFE5DB)),
                ),
                child: Column(
                  children: [
                    _detailRow('Tipe Mutasi', typeLabel, valueColor: deltaColor),
                    const SizedBox(height: 8),
                    _detailRow(
                      'Stok Sebelum',
                      '${CurrencyFormatter.formatNumber(m.stockBefore)} $unit',
                    ),
                    const SizedBox(height: 8),
                    _detailRow(
                      'Stok Sesudah',
                      '${CurrencyFormatter.formatNumber(m.stockAfter)} $unit',
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    _detailRow(
                      'Keterangan',
                      (m.notes != null && m.notes!.trim().isNotEmpty)
                          ? m.notes!.trim()
                          : _resolveReasonLabel(m),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2E21),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
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

  Widget _detailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8C7262),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
              color: valueColor ?? const Color(0xFF2B1B12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final productMap = <String, ProductModel>{
      for (final p in products) p.id: p,
    };

    int totalMasuk = 0;
    int totalKeluar = 0;
    for (final m in movements) {
      if (m.isIn) {
        totalMasuk += m.quantity.abs();
      } else if (m.isOut) {
        totalKeluar += m.quantity.abs();
      } else {
        if (m.quantity >= 0) {
          totalMasuk += m.quantity;
        } else {
          totalKeluar += m.quantity.abs();
        }
      }
    }

    // Group sorted movements by calendar date
    final sorted = List<StockMovementModel>.from(movements)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final List<({DateTime day, List<StockMovementModel> items})> groups = [];
    for (final m in sorted) {
      final day = DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day);
      if (groups.isEmpty || groups.last.day != day) {
        groups.add((day: day, items: [m]));
      } else {
        groups.last.items.add(m);
      }
    }

    final timeFmt = DateFormat('HH:mm');

    return RefreshIndicator(
      color: const Color(0xFF4A2E21),
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          // HERO CARD: RINGKASAN MUTASI (Matching Reference Image)
          _buildSummaryHeroCard(
            totalMasuk: totalMasuk,
            totalKeluar: totalKeluar,
          ),

          const SizedBox(height: 20),

          if (groups.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1E8DF)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF6F0),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.swap_vert_rounded,
                      size: 28,
                      color: Color(0xFFA68B7B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada riwayat mutasi stok',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4A2E21),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Setiap transaksi penjualan, restock, atau stock opname akan tercatat otomatis di sini.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF9C7F6C),
                    ),
                  ),
                ],
              ),
            )
          else
            ...groups.map((group) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          _formatDateGroupHeader(group.day),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: const Color(0xFF9C7F6C),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFEDE4DA),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...group.items.map((m) {
                    final productName = _resolveProductName(m, productMap);
                    final unit = _resolveUnit(m, productMap);
                    return _buildMovementCard(
                      context: context,
                      movement: m,
                      productName: productName,
                      unit: unit,
                      timeText: timeFmt.format(m.createdAt),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSummaryHeroCard({
    required int totalMasuk,
    required int totalKeluar,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5D3C2B), Color(0xFF4A2E21)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x284A2E21),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -6,
              top: 0,
              bottom: 0,
              width: 145,
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Color(0x55FFFFFF),
                    Color(0x99FFFFFF),
                  ],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/products/coffi_aren.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'RINGKASAN MUTASI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: Colors.white.withOpacity(0.88),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${CurrencyFormatter.formatNumber(totalMasuk)} Item',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'TOTAL MASUK',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.7,
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${CurrencyFormatter.formatNumber(totalKeluar)} Item',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'TOTAL KELUAR',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.7,
                                color: Colors.white.withOpacity(0.75),
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
      ),
    );
  }

  Widget _buildTypeIconBox(StockMovementModel m) {
    final Color bg;
    final Color fg;
    final IconData icon;

    if (m.isIn) {
      bg = const Color(0xFFECFDF5);
      fg = const Color(0xFF16A34A);
      icon = Icons.add_rounded;
    } else if (m.isOut) {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFDC2626);
      icon = Icons.remove_rounded;
    } else {
      bg = const Color(0xFFFEF9E7);
      fg = const Color(0xFFD97706);
      icon = Icons.warning_rounded;
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: fg, size: 22),
    );
  }

  Widget _buildMovementCard({
    required BuildContext context,
    required StockMovementModel movement,
    required String productName,
    required String unit,
    required String timeText,
  }) {
    final String badgeLabel;
    final Color badgeBg;
    final Color badgeFg;
    final String qtyText;
    final Color qtyColor;

    if (movement.isIn) {
      badgeLabel = 'IN';
      badgeBg = const Color(0xFFDCFCE7);
      badgeFg = const Color(0xFF16A34A);
      qtyText = '+${CurrencyFormatter.formatNumber(movement.quantity.abs())} $unit';
      qtyColor = const Color(0xFF16A34A);
    } else if (movement.isOut) {
      badgeLabel = 'OUT';
      badgeBg = const Color(0xFFFEE2E2);
      badgeFg = const Color(0xFFDC2626);
      qtyText = '-${CurrencyFormatter.formatNumber(movement.quantity.abs())} $unit';
      qtyColor = const Color(0xFFDC2626);
    } else {
      badgeLabel = 'ADJ';
      badgeBg = const Color(0xFFFEF3C7);
      badgeFg = const Color(0xFFB45309);
      final sign = movement.quantity >= 0 ? '+' : '-';
      qtyText = '$sign${CurrencyFormatter.formatNumber(movement.quantity.abs())} $unit';
      qtyColor = const Color(0xFFC27803);
    }

    final reason = _resolveReasonLabel(movement);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () =>
              _showMovementDetailSheet(context, movement, productName, unit),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1E8DF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A38220F),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTypeIconBox(movement),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2B1B12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              badgeLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                                color: badgeFg,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$timeText • $reason',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9C7F6C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      qtyText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: qtyColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Sisa: ${CurrencyFormatter.formatNumber(movement.stockAfter)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFA68B7B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
