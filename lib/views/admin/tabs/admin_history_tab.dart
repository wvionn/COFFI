import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/order_model.dart';
import '../../../providers/admin_dashboard_provider.dart';
import '../../../providers/order_provider.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_transaction_history_view.dart';

class AdminHistoryTab extends StatefulWidget {
  const AdminHistoryTab({super.key});

  @override
  State<AdminHistoryTab> createState() => _AdminHistoryTabState();
}

class _AdminHistoryTabState extends State<AdminHistoryTab> {
  bool? _showSearchField = false;
  String? _statusFilter; // null = semua, 'selesai', 'proses', 'dibatalkan'
  int? _visibleLimitField = 10;
  DateTime? _lastUpdatedField = DateTime.now();

  final TextEditingController _searchController = TextEditingController();

  bool get _showSearch => _showSearchField ?? false;
  set _showSearch(bool val) => _showSearchField = val;

  int get _visibleLimit => _visibleLimitField ?? 10;
  set _visibleLimit(int val) => _visibleLimitField = val;

  DateTime get _lastUpdated => _lastUpdatedField ?? DateTime.now();
  set _lastUpdated(DateTime val) => _lastUpdatedField = val;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPeriodPickerSheet(
    BuildContext context,
    AdminDashboardProvider dashboard,
  ) {
    const presets = [
      ('Hari Ini', 'Transaksi dan ringkasan hari ini'),
      ('Kemarin', 'Data penjualan 1 hari sebelumnya'),
      ('7 Hari Terakhir', 'Rekap mingguan 7 hari terakhir'),
      ('Bulan Ini', 'Akumulasi sejak awal bulan'),
      ('Semua', 'Seluruh data transaksi tersimpan'),
    ];

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
          child: SingleChildScrollView(
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
                Text(
                  'Pilih Periode Transaksi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A2E21),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Filter riwayat transaksi penjualan harian',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF9C7F6C),
                  ),
                ),
                const SizedBox(height: 14),
                ...presets.map((entry) {
                  final isSelected = dashboard.selectedPeriod == entry.$1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: isSelected
                          ? const Color(0xFF4A2E21)
                          : const Color(0xFFFAF6F0),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          dashboard.setPeriod(entry.$1);
                          setState(() {
                            _visibleLimit = 10;
                            _lastUpdated = DateTime.now();
                          });
                          Navigator.pop(ctx);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.$1,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF4A2E21),
                                      ),
                                    ),
                                    Text(
                                      entry.$2,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: isSelected
                                            ? Colors.white70
                                            : const Color(0xFF9C7F6C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final now = DateTime.now();
                      final currentRange = dashboard.getEffectiveDateRange();
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2023, 1, 1),
                        lastDate: DateTime(now.year + 1, 12, 31),
                        initialDateRange: DateTimeRange(
                          start: currentRange.start,
                          end: currentRange.end.isAfter(now)
                              ? now
                              : currentRange.end,
                        ),
                        builder: (c, child) {
                          return Theme(
                            data: Theme.of(c).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF4A2E21),
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: Color(0xFF4A2E21),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        dashboard.setCustomDateRange(picked);
                        if (mounted) {
                          setState(() {
                            _visibleLimit = 10;
                            _lastUpdated = DateTime.now();
                          });
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.date_range_rounded,
                      size: 18,
                      color: Color(0xFF4A2E21),
                    ),
                    label: Text(
                      'Pilih Rentang Tanggal Kustom',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A2E21),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: Color(0xFF4A2E21)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetailSheet(BuildContext context, OrderModel order) {
    final orderProvider = context.read<OrderProvider>();
    final dateFmt = DateFormat('dd MMM yyyy, HH:mm');
    final profit = order.totalAmount - order.totalHpp;
    final canComplete = !order.isCompleted && !order.isCancelled;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
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
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: order.isCancelled
                            ? const Color(0xFFFEF2F2)
                            : (order.isQrisOrDigitalPayment
                                  ? const Color(0xFFF5F3FF)
                                  : const Color(0xFFEFF6FF)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        order.isQrisOrDigitalPayment
                            ? Icons.qr_code_2_rounded
                            : Icons.payments_rounded,
                        color: order.isCancelled
                            ? const Color(0xFFDC2626)
                            : (order.isQrisOrDigitalPayment
                                  ? const Color(0xFF7C3AED)
                                  : const Color(0xFF2563EB)),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.invoiceNumber.startsWith('#')
                                ? order.invoiceNumber
                                : '#${order.invoiceNumber}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2B1B12),
                            ),
                          ),
                          Text(
                            '${dateFmt.format(order.createdAt)} • ${order.paymentMethodLabel}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF9C7F6C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: order.isCompleted
                            ? const Color(0xFFDCFCE7)
                            : (order.isCancelled
                                  ? const Color(0xFFFEE2E2)
                                  : const Color(0xFFFEF3C7)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status.replaceAll('_', ' ').toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: order.isCompleted
                              ? const Color(0xFF16A34A)
                              : (order.isCancelled
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFFB45309)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEFE5DB)),
                  ),
                  child: Column(
                    children: [
                      _buildKeyValueRow(
                        'Kasir',
                        order.cashierName ?? 'Kasir Outlet',
                      ),
                      const SizedBox(height: 6),
                      _buildKeyValueRow(
                        'Tipe Layanan',
                        order.isDineIn
                            ? 'Dine-In (${order.tableNumber ?? 'Meja'})'
                            : (order.isDelivery ? 'Delivery' : 'Takeaway'),
                      ),
                      if (order.customerName != null &&
                          order.customerName!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _buildKeyValueRow('Pelanggan', order.customerName!),
                      ],
                      if (order.notes != null &&
                          order.notes!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _buildKeyValueRow('Catatan', order.notes!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'RINCIAN MENU (${order.items.length})',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: const Color(0xFF9C7F6C),
                  ),
                ),
                const SizedBox(height: 8),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF6F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${item.quantity}x',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A2E21),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2B1B12),
                                ),
                              ),
                              if (item.notes != null &&
                                  item.notes!.trim().isNotEmpty)
                                Text(
                                  item.notes!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: const Color(0xFF9C7F6C),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(item.subtotal),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4A2E21),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 20, color: Color(0xFFEFE5DB)),
                _buildKeyValueRow(
                  'Subtotal',
                  CurrencyFormatter.format(order.subtotalAmount),
                ),
                const SizedBox(height: 5),
                _buildKeyValueRow(
                  'Pajak (PB1 10%)',
                  CurrencyFormatter.format(order.taxAmount),
                ),
                const SizedBox(height: 6),
                _buildKeyValueRow(
                  'Total Pembayaran',
                  CurrencyFormatter.format(order.totalAmount),
                  isBold: true,
                ),
                if (!order.isCancelled) ...[
                  const SizedBox(height: 6),
                  _buildKeyValueRow(
                    'Estimasi Laba (HPP ${CurrencyFormatter.format(order.totalHpp)})',
                    CurrencyFormatter.format(profit),
                    valueColor: const Color(0xFF16A34A),
                    isBold: true,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (canComplete) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final ok = await orderProvider.updateStatus(
                              order.id,
                              'dibatalkan',
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted && ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Transaksi ${order.invoiceNumber} dibatalkan.',
                                  ),
                                  backgroundColor: const Color(0xFFDC2626),
                                ),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Batalkan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ok = await orderProvider.updateStatus(
                              order.id,
                              'selesai',
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted && ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Transaksi ${order.invoiceNumber} ditandai selesai.',
                                  ),
                                  backgroundColor: const Color(0xFF16A34A),
                                ),
                              );
                            }
                          },
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
                            'Tandai Selesai',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ] else
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final receiptText = StringBuffer()
                              ..writeln('COFFI POS - STRUK TRANSAKSI')
                              ..writeln('Invoice: ${order.invoiceNumber}')
                              ..writeln(
                                'Waktu: ${dateFmt.format(order.createdAt)}',
                              )
                              ..writeln('Metode: ${order.paymentMethodLabel}')
                              ..writeln('Status: ${order.status.toUpperCase()}')
                              ..writeln('---');
                            for (final i in order.items) {
                              receiptText.writeln(
                                '${i.quantity}x ${i.productName} = ${CurrencyFormatter.format(i.subtotal)}',
                              );
                            }
                            receiptText.writeln('---');
                            receiptText.writeln(
                              'Total: ${CurrencyFormatter.format(order.totalAmount)}',
                            );
                            await Clipboard.setData(
                              ClipboardData(text: receiptText.toString()),
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ringkasan struk disalin.'),
                                  backgroundColor: Color(0xFF4A2E21),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.copy_rounded, size: 17),
                          label: Text(
                            'Salin Ringkasan Struk',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A2E21),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
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
      ),
    );
  }

  Widget _buildKeyValueRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8C7262),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF2B1B12),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String? statusValue) {
    final isSelected = _statusFilter == statusValue;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = statusValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A2E21) : const Color(0xFFFAF6F0),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A2E21)
                : const Color(0xFFEFE5DB),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF7D695E),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final dashboard = context.watch<AdminDashboardProvider>();

    final validOrders = dashboard.getFilteredOrders(orderProvider.orders);
    final allPeriodOrders = dashboard.getFilteredOrdersIncludingCancelled(
      orderProvider.orders,
    );
    final totalOmset = dashboard.calculateTotalOmset(validOrders);

    final query = _searchController.text.trim().toLowerCase();
    final filteredOrders = allPeriodOrders.where((o) {
      if (_statusFilter == 'selesai' && !o.isCompleted) return false;
      if (_statusFilter == 'dibatalkan' && !o.isCancelled) return false;
      if (_statusFilter == 'proses' && (o.isCompleted || o.isCancelled)) {
        return false;
      }
      if (query.isNotEmpty) {
        return o.invoiceNumber.toLowerCase().contains(query) ||
            (o.cashierName?.toLowerCase().contains(query) ?? false) ||
            (o.customerName?.toLowerCase().contains(query) ?? false) ||
            o.paymentMethodLabel.toLowerCase().contains(query) ||
            o.items.any((i) => i.productName.toLowerCase().contains(query));
      }
      return true;
    }).toList();

    final dateRange = dashboard.getEffectiveDateRange();
    final dateFmt = DateFormat('dd/MM/yyyy');
    final dateRangeText =
        '${dateFmt.format(dateRange.start)} - ${dateFmt.format(dateRange.end)}';
    final lastUpdateTime = DateFormat('HH:mm').format(_lastUpdated);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: Column(
        children: [
          // Top White Header matching Riwayat Transaksi reference image
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFEFE6DC), width: 1),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A2E21),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.coffee_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Riwayat Transaksi',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  color: const Color(0xFF4A2E21),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                'Laporan Penjualan Harian',
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
                        Material(
                          color: const Color(0xFFFAF5F0),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => AdminHeader.showQuickMenu(context),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFEFE5DB),
                                ),
                              ),
                              child: const Icon(
                                Icons.menu_rounded,
                                color: Color(0xFF4A2E21),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: const Color(0xFFFCF8F4),
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () =>
                                  _showPeriodPickerSheet(context, dashboard),
                              child: Container(
                                height: 46,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFEFE5DB),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 17,
                                      color: Color(0xFFA88D7B),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        dashboard.selectedPeriod == 'Kustom'
                                            ? dateRangeText
                                            : dashboard.selectedPeriod,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF4A2E21),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 20,
                                      color: Color(0xFFA88D7B),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          color: _showSearch
                              ? const Color(0xFF4A2E21)
                              : const Color(0xFFFCF8F4),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setState(() {
                                _showSearch = !_showSearch;
                                if (!_showSearch) {
                                  _searchController.clear();
                                  _statusFilter = null;
                                }
                              });
                            },
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _showSearch
                                      ? const Color(0xFF4A2E21)
                                      : const Color(0xFFEFE5DB),
                                ),
                              ),
                              child: Icon(
                                _showSearch
                                    ? Icons.close_rounded
                                    : Icons.search_rounded,
                                size: 20,
                                color: _showSearch
                                    ? Colors.white
                                    : const Color(0xFF4A2E21),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_showSearch) ...[
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCF8F4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEFE5DB)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: const Color(0xFF4A2E21),
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: Color(0xFFA88D7B),
                            ),
                            hintText:
                                'Cari #invoice, kasir, menu, QRIS/Cash...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: const Color(0xFFBBA89A),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 11,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('Semua', null),
                            const SizedBox(width: 6),
                            _buildFilterChip('Selesai', 'selesai'),
                            const SizedBox(width: 6),
                            _buildFilterChip('Diproses', 'proses'),
                            const SizedBox(width: 6),
                            _buildFilterChip('Batal', 'dibatalkan'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: AdminTransactionHistoryView(
              orders: filteredOrders,
              totalOmset: totalOmset,
              visibleLimit: _visibleLimit,
              lastUpdateTime: lastUpdateTime,
              onRefresh: () async {
                await orderProvider.init();
                if (mounted) {
                  setState(() => _lastUpdated = DateTime.now());
                }
              },
              onLoadMore: () async {
                if (filteredOrders.length > _visibleLimit) {
                  setState(() => _visibleLimit += 10);
                } else {
                  await orderProvider.init();
                  if (mounted) {
                    setState(() => _lastUpdated = DateTime.now());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Semua transaksi terbaru sudah dimuat.'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Color(0xFF4A2E21),
                      ),
                    );
                  }
                }
              },
              onOrderTap: (order) =>
                  _showTransactionDetailSheet(context, order),
            ),
          ),
        ],
      ),
    );
  }
}
