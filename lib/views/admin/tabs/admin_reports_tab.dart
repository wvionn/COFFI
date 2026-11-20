import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/admin_dashboard_provider.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/order_provider.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_stock_mutation_report_view.dart';

enum _ReportSection { laporan, mutasi }

class AdminReportsTab extends StatefulWidget {
  const AdminReportsTab({super.key});

  @override
  State<AdminReportsTab> createState() => _AdminReportsTabState();
}

class _AdminReportsTabState extends State<AdminReportsTab> {
  _ReportSection? _activeSectionField = _ReportSection.laporan;
  bool? _showShiftSearchField = false;
  bool? _showMutationFilterField = false;
  String? _mutationTypeFilter; // null = semua, 'in', 'out', 'adjustment'

  final TextEditingController _shiftSearchController = TextEditingController();
  final TextEditingController _mutationSearchController =
      TextEditingController();

  _ReportSection get _activeSection =>
      _activeSectionField ?? _ReportSection.laporan;
  set _activeSection(_ReportSection val) => _activeSectionField = val;

  bool get _showShiftSearch => _showShiftSearchField ?? false;
  set _showShiftSearch(bool val) => _showShiftSearchField = val;

  bool get _showMutationFilter => _showMutationFilterField ?? false;
  set _showMutationFilter(bool val) => _showMutationFilterField = val;

  @override
  void dispose() {
    _shiftSearchController.dispose();
    _mutationSearchController.dispose();
    super.dispose();
  }

  // =========================================================================
  // FORMATTING HELPERS
  // =========================================================================

  String _formatKCurrency(double amount) {
    final absVal = amount.abs();
    final sign = amount < 0 ? '-' : '';
    if (absVal == 0) return 'Rp 0';
    if (absVal >= 100000) {
      final inK = (absVal / 1000).round();
      return '${sign}Rp ${CurrencyFormatter.formatNumber(inK)}k';
    }
    return '${sign}Rp ${CurrencyFormatter.formatNumber(absVal)}';
  }

  String _formatCategoryCurrency(double amount) {
    if (amount >= 1000000) {
      final inM = amount / 1000000;
      return 'Rp ${inM.toStringAsFixed(1)}M';
    }
    if (amount >= 100000) {
      final inK = (amount / 1000).round();
      return 'Rp ${CurrencyFormatter.formatNumber(inK)}k';
    }
    return CurrencyFormatter.format(amount);
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'KS';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(1, 2))
          .toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  Color _avatarBgFor(String name) {
    const palette = [
      Color(0xFFE0F2FE),
      Color(0xFFFCE7F3),
      Color(0xFFDCFCE7),
      Color(0xFFFEF3C7),
      Color(0xFFEDE9FE),
    ];
    final hash = name.codeUnits.fold(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }

  Color _avatarFgFor(String name) {
    const palette = [
      Color(0xFF0369A1),
      Color(0xFFBE185D),
      Color(0xFF15803D),
      Color(0xFFB45309),
      Color(0xFF6D28D9),
    ];
    final hash = name.codeUnits.fold(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }

  // =========================================================================
  // PERIOD & CUSTOM DATE RANGE PICKER
  // =========================================================================

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
                  'Pilih Periode Laporan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A2E21),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Filter analitik penjualan dan ringkasan shift',
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

  // =========================================================================
  // MODAL: REKONSILIASI SHIFT (Z-REPORT DETAIL)
  // =========================================================================

  void _showShiftReconciliationSheet(
    BuildContext context,
    AdminDashboardProvider dashboard,
    ShiftReportSummary shift,
  ) {
    final physicalController = TextEditingController(
      text: CurrencyFormatter.formatNumber(shift.physicalTotal),
    );
    final dateFmt = DateFormat('dd/MM/yyyy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final inputVal = CurrencyFormatter.parse(physicalController.text);
          final previewVariance = inputVal - shift.systemTotal;
          final previewBalanced = previewVariance.abs() < 1;

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
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
                            color: _avatarBgFor(shift.cashierName),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _initials(shift.cashierName),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _avatarFgFor(shift.cashierName),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shift.cashierName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4A2E21),
                                ),
                              ),
                              Text(
                                '${dateFmt.format(shift.date)} • ${shift.shiftLabel} (${shift.orderCount} order)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF9C7F6C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildShiftStatusBadge(previewBalanced),
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
                          _buildKeyValueRow(
                            'Total Sistem',
                            CurrencyFormatter.format(shift.systemTotal),
                            isBold: true,
                          ),
                          const SizedBox(height: 6),
                          _buildKeyValueRow(
                            'Pembayaran Cash',
                            CurrencyFormatter.format(shift.cashTotal),
                          ),
                          const SizedBox(height: 6),
                          _buildKeyValueRow(
                            'Pembayaran QRIS / Non-Tunai',
                            CurrencyFormatter.format(shift.qrisTotal),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1, color: Color(0xFFEFE5DB)),
                          ),
                          _buildKeyValueRow(
                            'Selisih (Fisik - Sistem)',
                            previewBalanced
                                ? 'Rp 0 (Balance)'
                                : '${previewVariance > 0 ? '+' : ''}${CurrencyFormatter.format(previewVariance)}',
                            isBold: true,
                            valueColor: previewBalanced
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Total Setoran Fisik (Rp)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A2E21),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: physicalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [ThousandsSeparatorInputFormatter()],
                      onChanged: (_) => setModalState(() {}),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A2E21),
                      ),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9C7F6C),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFAF6F0),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8DDD3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF4A2E21),
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (shift.isReconciled) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await dashboard.resetShiftReconciliation(
                                  shift.key,
                                );
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFE5D7C9),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Reset',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF7D695E),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              final entered = CurrencyFormatter.parse(
                                physicalController.text,
                              );
                              await dashboard.recordShiftReconciliation(
                                shift.key,
                                entered,
                              );
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Rekonsiliasi ${shift.cashierName} (${shift.shiftLabel}) disimpan.',
                                    ),
                                    backgroundColor: const Color(0xFF4A2E21),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A2E21),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Simpan Rekonsiliasi Shift',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
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
        },
      ),
    );
  }

  void _showAllShiftsModal(
    BuildContext context,
    AdminDashboardProvider dashboard,
    List<ShiftReportSummary> allShifts,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFAF6F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.figmaSubtleBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Semua Ringkasan Shift (Z-Report)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A2E21),
                            ),
                          ),
                          Text(
                            'Ketuk shift untuk mengisi atau memeriksa kas fisik',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: const Color(0xFF9C7F6C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF4A2E21),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: allShifts.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada data shift tercatat',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: const Color(0xFF9C7F6C),
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: allShifts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, idx) {
                          final s = allShifts[idx];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFF1E8DF),
                              ),
                            ),
                            child: _buildShiftRowItem(
                              shift: s,
                              onTap: () {
                                Navigator.pop(ctx);
                                _showShiftReconciliationSheet(
                                  context,
                                  dashboard,
                                  s,
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // MAIN BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final menuProvider = context.watch<MenuProvider>();
    final dashboard = context.watch<AdminDashboardProvider>();

    final validOrders = dashboard.getFilteredOrders(orderProvider.orders);

    final totalOmset = dashboard.calculateTotalOmset(validOrders);
    final cashTotal = dashboard.calculateCashTotal(validOrders);
    final qrisTotal = dashboard.calculateQrisTotal(validOrders);
    final totalHpp = dashboard.calculateTotalHpp(validOrders);
    final grossProfit = dashboard.calculateGrossProfit(validOrders);
    final averageMargin = dashboard.calculateAverageMargin(validOrders);
    final aov = dashboard.calculateAverageOrderValue(validOrders);
    final topSelling = dashboard.getTopSellingItems(validOrders);
    final categoryStats = dashboard.getCategorySalesStats(
      validOrders,
      menuProvider.products,
      menuProvider.categories,
    );
    final allShifts = dashboard.getShiftSummaries(validOrders);

    final shiftQuery = _shiftSearchController.text.trim().toLowerCase();
    final filteredShifts = shiftQuery.isEmpty
        ? allShifts
        : allShifts
            .where(
              (s) =>
                  s.cashierName.toLowerCase().contains(shiftQuery) ||
                  s.shiftLabel.toLowerCase().contains(shiftQuery),
            )
            .toList();

    final mutationQuery = _mutationSearchController.text.trim().toLowerCase();
    final productNameById = <String, String>{
      for (final p in menuProvider.products) p.id: p.name.toLowerCase(),
    };
    final filteredMovements = menuProvider.stockMovements.where((m) {
      if (_mutationTypeFilter != null && m.type != _mutationTypeFilter) {
        return false;
      }
      if (mutationQuery.isNotEmpty) {
        final mappedName = productNameById[m.productId] ?? '';
        return m.productName.toLowerCase().contains(mutationQuery) ||
            mappedName.contains(mutationQuery) ||
            (m.notes?.toLowerCase().contains(mutationQuery) ?? false);
      }
      return true;
    }).toList();

    final dateRange = dashboard.getEffectiveDateRange();
    final dateFmt = DateFormat('dd/MM/yyyy');
    final dateRangeText =
        '${dateFmt.format(dateRange.start)} - ${dateFmt.format(dateRange.end)}';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: Column(
        children: [
          _buildTopHeader(
            context: context,
            dashboard: dashboard,
            dateRangeText: dateRangeText,
          ),
          Expanded(
            child: _activeSection == _ReportSection.laporan
                ? _buildSalesReportBody(
                    context: context,
                    dashboard: dashboard,
                    orderProvider: orderProvider,
                    totalOmset: totalOmset,
                    cashTotal: cashTotal,
                    qrisTotal: qrisTotal,
                    totalHpp: totalHpp,
                    grossProfit: grossProfit,
                    averageMargin: averageMargin,
                    aov: aov,
                    validOrderCount: validOrders.length,
                    shifts: filteredShifts,
                    allShifts: allShifts,
                    categoryStats: categoryStats,
                    topSelling: topSelling,
                  )
                : AdminStockMutationReportView(
                    movements: filteredMovements,
                    products: menuProvider.products,
                    onRefresh: () => menuProvider.refreshProducts(),
                  ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // HEADER & 2-TAB SEGMENTED BAR (Laporan Penjualan | Mutasi Stok)
  // =========================================================================

  Widget _buildTopHeader({
    required BuildContext context,
    required AdminDashboardProvider dashboard,
    required String dateRangeText,
  }) {
    final isLaporan = _activeSection == _ReportSection.laporan;
    final headerTitle =
        isLaporan ? 'Laporan Penjualan' : 'Laporan Mutasi Stok';
    final headerSubtitle = isLaporan
        ? 'Analitik & Ringkasan Shift'
        : 'Audit Pergerakan Barang';

    return Container(
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
                          headerTitle,
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
                          headerSubtitle,
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

              // Segmented Switcher: Laporan Penjualan | Mutasi Stok
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE4DA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _buildSectionPill(
                      label: 'Laporan Penjualan',
                      section: _ReportSection.laporan,
                    ),
                    _buildSectionPill(
                      label: 'Mutasi Stok',
                      section: _ReportSection.mutasi,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              if (isLaporan)
                Material(
                  color: const Color(0xFFFCF8F4),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showPeriodPickerSheet(context, dashboard),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEFE5DB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.date_range_rounded,
                            size: 19,
                            color: Color(0xFFA88D7B),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              dateRangeText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF4A2E21),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.filter_list_rounded,
                            size: 19,
                            color: Color(0xFFA88D7B),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCF8F4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEFE5DB)),
                        ),
                        child: TextField(
                          controller: _mutationSearchController,
                          onChanged: (_) => setState(() {}),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            color: const Color(0xFF4A2E21),
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 19,
                              color: Color(0xFFA88D7B),
                            ),
                            suffixIcon:
                                _mutationSearchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: Color(0xFFA88D7B),
                                        ),
                                        onPressed: () {
                                          _mutationSearchController.clear();
                                          setState(() {});
                                        },
                                      )
                                    : null,
                            hintText: 'Cari item...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              color: const Color(0xFFBBA89A),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: (_showMutationFilter ||
                              _mutationTypeFilter != null)
                          ? const Color(0xFF4A2E21)
                          : const Color(0xFFFCF8F4),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(
                          () => _showMutationFilter = !_showMutationFilter,
                        ),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: (_showMutationFilter ||
                                      _mutationTypeFilter != null)
                                  ? const Color(0xFF4A2E21)
                                  : const Color(0xFFEFE5DB),
                            ),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: (_showMutationFilter ||
                                    _mutationTypeFilter != null)
                                ? Colors.white
                                : const Color(0xFF4A2E21),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_showMutationFilter) ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildMutationFilterChip('Semua', null),
                        const SizedBox(width: 6),
                        _buildMutationFilterChip('Masuk (IN)', 'in'),
                        const SizedBox(width: 6),
                        _buildMutationFilterChip('Keluar (OUT)', 'out'),
                        const SizedBox(width: 6),
                        _buildMutationFilterChip('Opname (ADJ)', 'adjustment'),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionPill({
    required String label,
    required _ReportSection section,
  }) {
    final isSelected = _activeSection == section;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_activeSection == section) return;
          setState(() => _activeSection = section);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4A2E21) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF5D4638),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMutationFilterChip(String label, String? typeValue) {
    final isSelected = _mutationTypeFilter == typeValue;
    return GestureDetector(
      onTap: () => setState(() => _mutationTypeFilter = typeValue),
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

  // =========================================================================
  // BODY 1: LAPORAN PENJUALAN
  // =========================================================================

  Widget _buildSalesReportBody({
    required BuildContext context,
    required AdminDashboardProvider dashboard,
    required OrderProvider orderProvider,
    required double totalOmset,
    required double cashTotal,
    required double qrisTotal,
    required double totalHpp,
    required double grossProfit,
    required double averageMargin,
    required double aov,
    required int validOrderCount,
    required List<ShiftReportSummary> shifts,
    required List<ShiftReportSummary> allShifts,
    required List<CategorySalesStat> categoryStats,
    required Map<String, int> topSelling,
  }) {
    final displayedShifts = shifts.take(3).toList();

    return RefreshIndicator(
      color: const Color(0xFF4A2E21),
      onRefresh: () => orderProvider.init(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          _buildTotalOmzetHeroCard(
            totalOmset: totalOmset,
            grossProfit: grossProfit,
            averageMargin: averageMargin,
            validOrderCount: validOrderCount,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildPaymentMetricCard(
                  icon: Icons.payments_rounded,
                  iconBg: const Color(0xFFEFF6FF),
                  iconColor: const Color(0xFF2563EB),
                  label: 'CASH',
                  amount: _formatKCurrency(cashTotal),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildPaymentMetricCard(
                  icon: Icons.qr_code_2_rounded,
                  iconBg: const Color(0xFFF5F3FF),
                  iconColor: const Color(0xFF7C3AED),
                  label: 'QRIS',
                  amount: _formatKCurrency(qrisTotal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'RINGKASAN SHIFT (Z-REPORT)',
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
              Material(
                color: _showShiftSearch
                    ? const Color(0xFF4A2E21)
                    : Colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    setState(() {
                      _showShiftSearch = !_showShiftSearch;
                      if (!_showShiftSearch) _shiftSearchController.clear();
                    });
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _showShiftSearch
                            ? const Color(0xFF4A2E21)
                            : const Color(0xFFEFE5DB),
                      ),
                    ),
                    child: Icon(
                      _showShiftSearch
                          ? Icons.close_rounded
                          : Icons.search_rounded,
                      size: 17,
                      color: _showShiftSearch
                          ? Colors.white
                          : const Color(0xFF4A2E21),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showShiftSearch) ...[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEFE5DB)),
              ),
              child: TextField(
                controller: _shiftSearchController,
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
                  hintText: 'Cari nama kasir atau shift...',
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
          ],
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF1E8DF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A38220F),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: displayedShifts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 28,
                      horizontal: 18,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 30,
                          color: Color(0xFFB8A394),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada ringkasan shift pada periode ini',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9C7F6C),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: List.generate(displayedShifts.length, (index) {
                      final shift = displayedShifts[index];
                      return Column(
                        children: [
                          _buildShiftRowItem(
                            shift: shift,
                            onTap: () => _showShiftReconciliationSheet(
                              context,
                              dashboard,
                              shift,
                            ),
                          ),
                          if (index < displayedShifts.length - 1)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFF3EBE3),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _showAllShiftsModal(context, dashboard, allShifts),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEFE5DB)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0838220F),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lihat Semua Ringkasan Shift',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A2E21),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 19,
                      color: Color(0xFF4A2E21),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _buildSalesStatisticsCard(categoryStats),
          const SizedBox(height: 16),
          _buildProfitAndTopMenuCard(
            totalHpp: totalHpp,
            grossProfit: grossProfit,
            averageMargin: averageMargin,
            aov: aov,
            topSelling: topSelling,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalOmzetHeroCard({
    required double totalOmset,
    required double grossProfit,
    required double averageMargin,
    required int validOrderCount,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 118,
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
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
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
                        'TOTAL OMZET',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      CurrencyFormatter.format(totalOmset),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$validOrderCount Transaksi • Laba ${CurrencyFormatter.formatCompact(grossProfit)} (${averageMargin.toStringAsFixed(0)}%)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMetricCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: const Color(0xFF9C7F6C),
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2B1B12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftRowItem({
    required ShiftReportSummary shift,
    required VoidCallback onTap,
  }) {
    final dateFmt = DateFormat('dd/MM/yy');
    final variance = shift.variance;
    final Color selisihColor = shift.isBalanced
        ? const Color(0xFF2B1B12)
        : (variance < 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A));
    final String selisihText = shift.isBalanced
        ? 'Rp 0'
        : '${variance > 0 ? '+' : ''}${_formatKCurrency(variance)}';

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _avatarBgFor(shift.cashierName),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials(shift.cashierName),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: _avatarFgFor(shift.cashierName),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shift.cashierName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2B1B12),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${dateFmt.format(shift.date)} • ${shift.shiftLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9C7F6C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildShiftStatusBadge(shift.isBalanced),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildShiftMetricColumn(
                    label: 'SISTEM',
                    value: _formatKCurrency(shift.systemTotal),
                    align: CrossAxisAlignment.start,
                  ),
                ),
                Expanded(
                  child: _buildShiftMetricColumn(
                    label: 'FISIK',
                    value: _formatKCurrency(shift.physicalTotal),
                    align: CrossAxisAlignment.start,
                  ),
                ),
                Expanded(
                  child: _buildShiftMetricColumn(
                    label: 'SELISIH',
                    value: selisihText,
                    valueColor: selisihColor,
                    align: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftStatusBadge(bool isBalanced) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isBalanced ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isBalanced ? 'BALANCE' : 'VARIANCE',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: isBalanced ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        ),
      ),
    );
  }

  Widget _buildShiftMetricColumn({
    required String label,
    required String value,
    required CrossAxisAlignment align,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: const Color(0xFFA68B7B),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: valueColor ?? const Color(0xFF2B1B12),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesStatisticsCard(List<CategorySalesStat> stats) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1E8DF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A38220F),
            blurRadius: 16,
            offset: Offset(0, 5),
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
                  'Statistik Penjualan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2B1B12),
                  ),
                ),
              ),
              Text(
                'Per Kategori',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9C7F6C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (stats.isEmpty)
            Text(
              'Belum ada penjualan produk di periode ini.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF9C7F6C),
              ),
            )
          else
            ...stats.asMap().entries.map((entry) {
              final idx = entry.key;
              final stat = entry.value;
              final Color barBg = idx == 0
                  ? const Color(0xFF5A3929)
                  : (idx == 1
                      ? const Color(0xFFB89379)
                      : const Color(0xFFFAF6F0));
              final Color? barBorder =
                  idx >= 2 ? const Color(0xFFCBB4A4) : null;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: idx < stats.length - 1 ? 14 : 0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 34,
                      decoration: BoxDecoration(
                        color: barBg,
                        borderRadius: BorderRadius.circular(6),
                        border: barBorder != null
                            ? Border.all(color: barBorder, width: 1.2)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2B1B12),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${CurrencyFormatter.formatNumber(stat.itemCount)} Pesanan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF9C7F6C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCategoryCurrency(stat.revenue),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A2E21),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildProfitAndTopMenuCard({
    required double totalHpp,
    required double grossProfit,
    required double averageMargin,
    required double aov,
    required Map<String, int> topSelling,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1E8DF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A38220F),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Laba & Menu Terlaris',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2B1B12),
            ),
          ),
          const SizedBox(height: 12),
          _buildKeyValueRow(
            'Total HPP (Modal)',
            CurrencyFormatter.format(totalHpp),
          ),
          const SizedBox(height: 6),
          _buildKeyValueRow(
            'Laba Kotor',
            CurrencyFormatter.format(grossProfit),
            isBold: true,
            valueColor: const Color(0xFF16A34A),
          ),
          const SizedBox(height: 6),
          _buildKeyValueRow(
            'Rata-rata Margin',
            '${averageMargin.toStringAsFixed(1)}%',
          ),
          const SizedBox(height: 6),
          _buildKeyValueRow(
            'Rata-rata Belanja (AOV)',
            CurrencyFormatter.format(aov),
          ),
          if (topSelling.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF3EBE3)),
            ),
            Text(
              'TOP 5 MENU TERLARIS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: const Color(0xFF9C7F6C),
              ),
            ),
            const SizedBox(height: 10),
            ...topSelling.entries.toList().asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: rank == 1
                            ? const Color(0xFF4A2E21)
                            : const Color(0xFFFAF6F0),
                        shape: BoxShape.circle,
                        border: rank == 1
                            ? null
                            : Border.all(color: const Color(0xFFEFE5DB)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$rank',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: rank == 1
                              ? Colors.white
                              : const Color(0xFF4A2E21),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2B1B12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.value} porsi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A2E21),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
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
}
