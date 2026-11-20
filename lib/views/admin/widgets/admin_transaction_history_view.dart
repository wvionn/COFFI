import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/order_model.dart';

class AdminTransactionHistoryView extends StatelessWidget {
  final List<OrderModel> orders;
  final double totalOmset;
  final int visibleLimit;
  final String lastUpdateTime;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final ValueChanged<OrderModel> onOrderTap;

  const AdminTransactionHistoryView({
    super.key,
    required this.orders,
    required this.totalOmset,
    required this.visibleLimit,
    required this.lastUpdateTime,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onOrderTap,
  });

  String _formatCompactOmzet(double amount) {
    if (amount >= 1000000) {
      final inM = amount / 1000000;
      return '${inM.toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      final inK = amount / 1000;
      final formatted =
          inK % 1 == 0 ? inK.toStringAsFixed(0) : inK.toStringAsFixed(1);
      return '${formatted}k';
    }
    return CurrencyFormatter.formatNumber(amount);
  }

  String _formatInvoiceTitle(String rawInvoice) {
    final trimmed = rawInvoice.trim();
    if (trimmed.isEmpty) return '#CF-0000';
    return trimmed.startsWith('#') ? trimmed : '#$trimmed';
  }

  ({String label, IconData? icon, Color bg, Color fg}) _statusMeta(
    OrderModel order,
  ) {
    if (order.isCompleted) {
      return (
        label: 'SELESAI',
        icon: Icons.check_rounded,
        bg: const Color(0xFFDCFCE7),
        fg: const Color(0xFF16A34A),
      );
    }
    if (order.isCancelled) {
      return (
        label: 'BATAL',
        icon: Icons.close_rounded,
        bg: const Color(0xFFFEE2E2),
        fg: const Color(0xFFDC2626),
      );
    }
    if (order.isReady) {
      return (
        label: 'SIAP',
        icon: Icons.done_all_rounded,
        bg: const Color(0xFFDBEAFE),
        fg: const Color(0xFF1D4ED8),
      );
    }
    if (order.isDelivering) {
      return (
        label: 'DIKIRIM',
        icon: Icons.delivery_dining_rounded,
        bg: const Color(0xFFE0E7FF),
        fg: const Color(0xFF4338CA),
      );
    }
    if (order.isProcessing) {
      return (
        label: 'DIPROSES',
        icon: Icons.local_fire_department_rounded,
        bg: const Color(0xFFFEF3C7),
        fg: const Color(0xFFB45309),
      );
    }
    if (order.isWaitingValidation) {
      return (
        label: 'VALIDASI',
        icon: Icons.hourglass_top_rounded,
        bg: const Color(0xFFFEF3C7),
        fg: const Color(0xFFB45309),
      );
    }
    return (
      label: 'PENDING',
      icon: Icons.schedule_rounded,
      bg: const Color(0xFFFEF3C7),
      fg: const Color(0xFFB45309),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleOrders = orders.take(visibleLimit).toList();
    final hasMore = orders.length > visibleLimit;
    final timeFormat = DateFormat('HH:mm');

    return RefreshIndicator(
      color: const Color(0xFF4A2E21),
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          // 2 KPI Summary Cards: TOTAL ORDER & OMZET
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.receipt_long_rounded,
                  iconBg: const Color(0xFFF5EFE9),
                  iconColor: const Color(0xFF4A2E21),
                  label: 'TOTAL ORDER',
                  value: '${orders.length}',
                  valueColor: const Color(0xFF2B1B12),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.shopping_bag_rounded,
                  iconBg: const Color(0xFFECFDF5),
                  iconColor: const Color(0xFF16A34A),
                  label: 'OMZET',
                  value: _formatCompactOmzet(totalOmset),
                  valueColor: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Section Header: AKTIVITAS TERBARU + Terakhir update
          Row(
            children: [
              Expanded(
                child: Text(
                  'AKTIVITAS TERBARU',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: const Color(0xFF9C7F6C),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Terakhir update $lastUpdateTime',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFA68B7B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (visibleOrders.isEmpty)
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
                      Icons.receipt_long_outlined,
                      size: 28,
                      color: Color(0xFFA68B7B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada transaksi ditemukan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4A2E21),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coba ubah rentang periode atau kata kunci pencarian.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF9C7F6C),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            ...visibleOrders.map(
              (order) => _buildTransactionCard(order, timeFormat),
            ),
            const SizedBox(height: 4),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onLoadMore,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFEFE5DB)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A38220F),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    hasMore
                        ? 'Muat Lebih Banyak (${orders.length - visibleOrders.length} lagi)'
                        : 'Muat Lebih Banyak',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4A2E21),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1E8DF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A38220F),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: const Color(0xFF9C7F6C),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: valueColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(OrderModel order, DateFormat timeFormat) {
    final isCancelled = order.isCancelled;
    final isQris = order.isQrisOrDigitalPayment;
    final status = _statusMeta(order);

    final Color iconBg = isCancelled
        ? const Color(0xFFFEF2F2)
        : (isQris ? const Color(0xFFF5F3FF) : const Color(0xFFEFF6FF));
    final Color iconColor = isCancelled
        ? const Color(0xFFDC2626)
        : (isQris ? const Color(0xFF7C3AED) : const Color(0xFF2563EB));
    final IconData paymentIcon =
        isQris ? Icons.qr_code_2_rounded : Icons.payments_rounded;

    final int totalItemQty = order.items.fold(0, (s, i) => s + i.quantity);
    final String cashierLabel =
        (order.cashierName != null && order.cashierName!.trim().isNotEmpty)
            ? order.cashierName!.trim()
            : 'Kasir';

    final String footerText;
    if (isCancelled && order.notes != null && order.notes!.trim().isNotEmpty) {
      footerText = '${order.notes!.trim()} • Kasir: $cashierLabel';
    } else {
      final unit = totalItemQty == 1 ? 'Item' : 'Items';
      footerText = '$totalItemQty $unit • Kasir: $cashierLabel';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onOrderTap(order),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1E8DF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A38220F),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(paymentIcon, color: iconColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatInvoiceTitle(order.invoiceNumber),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2B1B12),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${timeFormat.format(order.createdAt)} • ${order.paymentMethodLabel}',
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
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.format(order.totalAmount),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isCancelled
                                ? const Color(0xFF7D695E)
                                : const Color(0xFF2B1B12),
                            decoration: isCancelled
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: const Color(0xFF7D695E),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: status.bg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (status.icon != null) ...[
                                Icon(status.icon, size: 11, color: status.fg),
                                const SizedBox(width: 3),
                              ],
                              Text(
                                status.label,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                  color: status.fg,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 11),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF3EBE3),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        footerText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA68B7B),
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
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4A2E21),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 17,
                          color: Color(0xFF4A2E21),
                        ),
                      ],
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
