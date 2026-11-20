import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/product_model.dart';
import '../../../models/stock_movement_model.dart';
import '../../../providers/menu_provider.dart';
import '../widgets/admin_header.dart';

enum _StockSection { inventaris, riwayat }

class AdminStockTab extends StatefulWidget {
  const AdminStockTab({super.key});

  @override
  State<AdminStockTab> createState() => _AdminStockTabState();
}

class _AdminStockTabState extends State<AdminStockTab> {
  final TextEditingController _searchController = TextEditingController();
  _StockSection? _activeSectionField = _StockSection.inventaris;
  bool? _onlyCriticalField = false;
  String? _movementTypeFilter; // null = semua, 'in', 'out', 'adjustment'
  DateTime _lastUpdated = DateTime.now();

  _StockSection get _activeSection =>
      _activeSectionField ?? _StockSection.inventaris;
  set _activeSection(_StockSection val) => _activeSectionField = val;

  bool get _onlyCritical => _onlyCriticalField ?? false;
  set _onlyCritical(bool val) => _onlyCriticalField = val;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =========================================================================
  // MODAL 1: RESTOCK CEPAT (BOTTOM SHEET)
  // =========================================================================

  void _showRestockSheet(BuildContext context, ProductModel product) {
    final menu = context.read<MenuProvider>();
    final qtyController = TextEditingController(text: '10');
    final costController = TextEditingController(
      text: CurrencyFormatter.formatNumber(product.costPrice * 10),
    );
    final notesController = TextEditingController(text: 'Restock supplier');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final addQty = int.tryParse(qtyController.text.trim()) ?? 0;
          final afterStock = product.stock + addQty;

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
                        AdminProductImage(
                          imageUrl: product.imageUrl,
                          size: 50,
                          borderRadius: 14,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Restock Produk',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF9C7F6C),
                                ),
                              ),
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4A2E21),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Live Stock Preview Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF6F0),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEFE5DB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 18,
                            color: Color(0xFF4A2E21),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Stok: ${CurrencyFormatter.formatNumber(product.stock)} ➔ ${CurrencyFormatter.formatNumber(afterStock)} ${product.displayUnit}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF4A2E21),
                              ),
                            ),
                          ),
                          if (addQty > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '+$addQty',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF16A34A),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    Text(
                      'Tambah Cepat',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8C7262),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [5, 10, 25, 50, 100].map((preset) {
                        final isSelected = addQty == preset;
                        return Material(
                          color: isSelected
                              ? const Color(0xFF4A2E21)
                              : const Color(0xFFFAF5F0),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              qtyController.text = preset.toString();
                              costController.text =
                                  CurrencyFormatter.formatNumber(
                                product.costPrice * preset,
                              );
                              setModalState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF4A2E21)
                                      : const Color(0xFFE8DDD3),
                                ),
                              ),
                              child: Text(
                                '+$preset',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF4A2E21),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 14),
                    _buildLabel('Jumlah Masuk (${product.displayUnit})'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final q = int.tryParse(val.trim()) ?? 0;
                        costController.text = CurrencyFormatter.formatNumber(
                          product.costPrice * q,
                        );
                        setModalState(() {});
                      },
                      decoration: _sheetInputDecoration(hint: '10'),
                    ),

                    const SizedBox(height: 12),
                    _buildLabel('Total Biaya Beli Modal (Rp)'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [ThousandsSeparatorInputFormatter()],
                      decoration: _sheetInputDecoration(
                        hint: '0',
                        prefixText: 'Rp  ',
                      ),
                    ),

                    const SizedBox(height: 12),
                    _buildLabel('Catatan Restock'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      decoration: _sheetInputDecoration(
                        hint: 'Contoh: Restock supplier pagi',
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF8C7262),
                                side: const BorderSide(
                                  color: Color(0xFFE8DDD3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                'Batal',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () async {
                                final qty =
                                    int.tryParse(qtyController.text.trim()) ??
                                        0;
                                final cost =
                                    CurrencyFormatter.parse(costController.text);
                                if (qty <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Jumlah restock harus lebih dari 0.',
                                      ),
                                      backgroundColor: AppColors.berryRed,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.pop(ctx);
                                await menu.restockProduct(
                                  productId: product.id,
                                  quantity: qty,
                                  buyCost: cost,
                                  notes: notesController.text.trim(),
                                );
                                if (mounted) {
                                  setState(() => _lastUpdated = DateTime.now());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Stok "${product.name}" berhasil ditambah +$qty ${product.displayUnit}!',
                                      ),
                                      backgroundColor: const Color(0xFF16A34A),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: Text(
                                'Simpan Restock',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                ),
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

  // =========================================================================
  // MODAL 2: STOCK OPNAME (KOREKSI FISIK)
  // =========================================================================

  void _showOpnameSheet(BuildContext context, ProductModel product) {
    final menu = context.read<MenuProvider>();
    final actualController = TextEditingController(
      text: product.stock.toString(),
    );
    final reasonController = TextEditingController(text: 'Koreksi fisik harian');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final actual =
              int.tryParse(actualController.text.trim()) ?? product.stock;
          final diff = actual - product.stock;

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
                    Text(
                      'Stock Opname: ${product.name}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A2E21),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stok sistem saat ini: ${CurrencyFormatter.formatNumber(product.stock)} ${product.displayUnit}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: const Color(0xFF8C7262),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Stok Fisik Aktual (${product.displayUnit})'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: actualController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setModalState(() {}),
                      decoration: _sheetInputDecoration(
                        hint: product.stock.toString(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      diff == 0
                          ? 'Selisih: 0 (Sesuai sistem)'
                          : 'Selisih penyesuaian: ${diff > 0 ? '+$diff' : '$diff'} ${product.displayUnit}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: diff < 0
                            ? const Color(0xFFDC2626)
                            : (diff > 0
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF8C7262)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLabel('Alasan Penyesuaian'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: reasonController,
                      decoration: _sheetInputDecoration(
                        hint: 'Misal: Tumpah, rusak, selisih hitung',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A2E21),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final finalActual = (int.tryParse(
                                    actualController.text.trim(),
                                  ) ??
                                  product.stock)
                              .clamp(0, 999999);
                          Navigator.pop(ctx);
                          await menu.stockOpname(
                            productId: product.id,
                            actualPhysicalStock: finalActual,
                            reason: reasonController.text.trim(),
                          );
                          if (mounted) {
                            setState(() => _lastUpdated = DateTime.now());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Stok fisik "${product.name}" disesuaikan menjadi $finalActual ${product.displayUnit}.',
                                ),
                                backgroundColor: const Color(0xFF4A2E21),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'SIMPAN KOREKSI OPNAME',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
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

  // =========================================================================
  // MODAL 3: LIHAT DETAIL INVENTARIS PRODUK
  // =========================================================================

  void _showInventoryDetailSheet(BuildContext context, ProductModel product) {
    final menu = context.read<MenuProvider>();
    final productMovements = menu.stockMovements
        .where((m) => m.productId == product.id)
        .take(5)
        .toList();
    final dateFormat = DateFormat('dd MMM, HH:mm');

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
                    AdminProductImage(
                      imageUrl: product.imageUrl,
                      size: 58,
                      borderRadius: 16,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A2E21),
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildStatusBadge(product),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Key Inventory Metrics Grid
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6F0),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFEFE5DB)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDetailStat(
                          'STOK SAAT INI',
                          '${CurrencyFormatter.formatNumber(product.stock)} ${product.displayUnit}',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 34,
                        color: const Color(0xFFE8DDD3),
                      ),
                      Expanded(
                        child: _buildDetailStat(
                          'BATAS KRITIS',
                          '${product.minStock} ${product.displayUnit}',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 34,
                        color: const Color(0xFFE8DDD3),
                      ),
                      Expanded(
                        child: _buildDetailStat(
                          'HPP / UNIT',
                          CurrencyFormatter.format(product.costPrice),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'RIWAYAT MUTASI TERAKHIR',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: const Color(0xFF8C7262),
                  ),
                ),
                const SizedBox(height: 8),

                if (productMovements.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCF8F4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEFE6DC)),
                    ),
                    child: Text(
                      'Belum ada catatan mutasi untuk produk ini.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF9C7F6C),
                      ),
                    ),
                  )
                else
                  ...productMovements.map((mov) {
                    final deltaText = mov.isOut
                        ? '-${mov.quantity.abs()}'
                        : (mov.quantity >= 0
                            ? '+${mov.quantity}'
                            : '${mov.quantity}');
                    final deltaColor = mov.isIn
                        ? const Color(0xFF16A34A)
                        : (mov.isOut
                            ? const Color(0xFFDC2626)
                            : const Color(0xFFB45309));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCF8F4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEFE6DC)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mov.notes ?? 'Mutasi stok',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF4A2E21),
                                    ),
                                  ),
                                  Text(
                                    '${dateFormat.format(mov.createdAt)} • ${mov.stockBefore} ➔ ${mov.stockAfter}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: const Color(0xFF9C7F6C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              deltaText,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: deltaColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFFAF5F0),
                            foregroundColor: const Color(0xFF4A2E21),
                            side: const BorderSide(color: Color(0xFFE8DDD3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showOpnameSheet(context, product);
                          },
                          icon: const Icon(Icons.tune_rounded, size: 17),
                          label: Text(
                            'Stock Opname',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showRestockSheet(context, product);
                          },
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: Text(
                            'Restock',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
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

  Widget _buildDetailStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: const Color(0xFF9C7F6C),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4A2E21),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF4A2E21),
      ),
    );
  }

  InputDecoration _sheetInputDecoration({
    required String hint,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      prefixStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF8C7262),
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        color: const Color(0xFFB8A394),
      ),
      filled: true,
      fillColor: const Color(0xFFFAF6F0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8DDD3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4A2E21), width: 1.4),
      ),
    );
  }

  // =========================================================================
  // MAIN BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final query = _searchController.text.trim().toLowerCase();
    final criticalCount = menu.lowStockProducts.length;
    final totalCount = menu.products.length;
    final lastUpdateTime = DateFormat('HH:mm').format(_lastUpdated);

    final filteredProducts = menu.products.where((p) {
      if (_onlyCritical && !(p.isLowStock || p.isOutOfStock)) return false;
      if (query.isNotEmpty) {
        return p.name.toLowerCase().contains(query) ||
            (p.description?.toLowerCase().contains(query) ?? false);
      }
      return true;
    }).toList();

    final filteredMovements = menu.stockMovements.where((m) {
      if (_movementTypeFilter != null && m.type != _movementTypeFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        return m.productName.toLowerCase().contains(query) ||
            (m.notes?.toLowerCase().contains(query) ?? false);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: Column(
        children: [
          // Top White Header Section matching Reference Image
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
                    // Header Row: Coffee Badge + Manajemen Stok + Hamburger Menu
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
                                'Manajemen Stok',
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
                                'Inventaris Bahan & Produk',
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

                    // Segmented Switcher: Daftar Inventaris | Riwayat Mutasi
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE4DA),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          _buildSectionPill(
                            label: 'Daftar Inventaris',
                            section: _StockSection.inventaris,
                          ),
                          _buildSectionPill(
                            label: 'Riwayat Mutasi',
                            section: _StockSection.riwayat,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Rounded Search Bar matching Reference Image
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCF8F4),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFEFE5DB),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color: const Color(0xFF4A2E21),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFFA88D7B),
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: Color(0xFFA88D7B),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          hintText: _activeSection == _StockSection.inventaris
                              ? 'Cari bahan atau produk...'
                              : 'Cari riwayat mutasi stok...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            color: const Color(0xFFBBA89A),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Active Content Area
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF4A2E21),
              onRefresh: () async {
                await menu.refreshProducts();
                if (mounted) setState(() => _lastUpdated = DateTime.now());
              },
              child: _activeSection == _StockSection.inventaris
                  ? _buildInventoryList(
                      context: context,
                      products: filteredProducts,
                      criticalCount: criticalCount,
                      totalCount: totalCount,
                      lastUpdateTime: lastUpdateTime,
                    )
                  : _buildMovementsList(
                      context: context,
                      movements: filteredMovements,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionPill({
    required String label,
    required _StockSection section,
  }) {
    final isSelected = _activeSection == section;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_activeSection == section) return;
          setState(() {
            _activeSection = section;
            _searchController.clear();
          });
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

  Widget _buildInventoryList({
    required BuildContext context,
    required List<ProductModel> products,
    required int criticalCount,
    required int totalCount,
    required String lastUpdateTime,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        // 2 Summary KPI Cards: KRITIS & TOTAL (matching Reference Image)
        Row(
          children: [
            Expanded(
              child: _buildKpiSummaryCard(
                icon: Icons.shopping_bag_rounded,
                iconBg: const Color(0xFFFBF1EE),
                iconColor: const Color(0xFF7D5D49),
                label: 'KRITIS',
                value: '$criticalCount Item',
                valueColor: criticalCount > 0
                    ? const Color(0xFFC5A200)
                    : const Color(0xFF16A34A),
                isSelected: _onlyCritical,
                onTap: () => setState(() => _onlyCritical = !_onlyCritical),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildKpiSummaryCard(
                icon: Icons.inventory_2_rounded,
                iconBg: const Color(0xFFF5EFE9),
                iconColor: const Color(0xFF4A2E21),
                label: 'TOTAL',
                value: '$totalCount Item',
                valueColor: const Color(0xFF23160D),
                isSelected: !_onlyCritical,
                onTap: () => setState(() => _onlyCritical = false),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Section Title Row: DAFTAR INVENTARIS + Terakhir Update: HH:mm
        Row(
          children: [
            Expanded(
              child: Text(
                _onlyCritical ? 'STOK KRITIS & HABIS' : 'DAFTAR INVENTARIS',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: const Color(0xFF8C7262),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Terakhir Update: $lastUpdateTime',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFA88D7B),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (products.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFEFE5DB)),
                  ),
                  child: Icon(
                    _onlyCritical
                        ? Icons.check_circle_outline_rounded
                        : Icons.inventory_2_outlined,
                    color: _onlyCritical
                        ? const Color(0xFF16A34A)
                        : AppColors.figmaHazelnut,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _onlyCritical
                      ? 'Semua stok aman!'
                      : 'Item inventaris tidak ditemukan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A2E21),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _onlyCritical
                      ? 'Tidak ada bahan atau produk dalam status kritis.'
                      : 'Coba ubah kata kunci pencarian Anda.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: const Color(0xFF9C7F6C),
                  ),
                ),
              ],
            ),
          )
        else
          ...products.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildInventoryCard(context, product),
            ),
          ),
      ],
    );
  }

  Widget _buildKpiSummaryCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF4A2E21).withOpacity(0.35)
              : const Color(0xFFF0E6DC),
          width: isSelected ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A2E21).withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 21),
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
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: const Color(0xFF9C7F6C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: valueColor,
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
  }

  Widget _buildStatusBadge(ProductModel product) {
    if (product.isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.close_rounded,
              size: 13,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(width: 4),
            Text(
              'HABIS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      );
    }

    if (product.isLowStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_rounded,
              size: 13,
              color: Color(0xFFC5A200),
            ),
            const SizedBox(width: 4),
            Text(
              'KRITIS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: const Color(0xFFC5A200),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'AMAN',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(BuildContext context, ProductModel product) {
    final isOut = product.isOutOfStock;
    final isLow = product.isLowStock;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isLow
              ? const Color(0xFFF6D5D5)
              : const Color(0xFFF0E6DC),
          width: isLow ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isLow ? const Color(0xFFDC2626) : const Color(0xFF4A2E21))
                .withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Product Thumbnail + Name & Stock + Status Badge
          Row(
            children: [
              Opacity(
                opacity: isOut ? 0.55 : 1.0,
                child: AdminProductImage(
                  imageUrl: product.imageUrl,
                  size: 56,
                  borderRadius: 14,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: isOut
                            ? const Color(0xFF9E8E82)
                            : const Color(0xFF23160D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${CurrencyFormatter.formatNumber(product.stock)} ${product.displayUnit}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(product),
            ],
          ),

          const SizedBox(height: 14),

          // Bottom Action Row: > Lihat Detail + + Restock (matching Reference Image)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFFCF8F4),
                      foregroundColor: const Color(0xFF7D5D49),
                      side: const BorderSide(color: Color(0xFFEFE5DB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () =>
                        _showInventoryDetailSheet(context, product),
                    icon: const Icon(Icons.chevron_right_rounded, size: 18),
                    label: Text(
                      'Lihat Detail',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _showRestockSheet(context, product),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(
                      'Restock',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SUB-VIEW 2: RIWAYAT MUTASI STOK
  // =========================================================================

  Widget _buildMovementsList({
    required BuildContext context,
    required List<StockMovementModel> movements,
  }) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMovementFilterChip('Semua', null),
              const SizedBox(width: 8),
              _buildMovementFilterChip('Stok Masuk', 'in'),
              const SizedBox(width: 8),
              _buildMovementFilterChip('Terjual / Keluar', 'out'),
              const SizedBox(width: 8),
              _buildMovementFilterChip('Stock Opname', 'adjustment'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (movements.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFEFE5DB)),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AppColors.figmaHazelnut,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Belum ada riwayat mutasi stok',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A2E21),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Log restock, penjualan, dan opname akan tercatat di sini.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: const Color(0xFF9C7F6C),
                  ),
                ),
              ],
            ),
          )
        else
          ...movements.map((mov) {
            final isIn = mov.isIn;
            final isOut = mov.isOut;
            final iconBg = isIn
                ? const Color(0xFFECFDF5)
                : (isOut
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFFFFBEB));
            final accent = isIn
                ? const Color(0xFF16A34A)
                : (isOut
                    ? const Color(0xFFDC2626)
                    : const Color(0xFFB45309));
            final deltaLabel = isOut
                ? '-${mov.quantity.abs()}'
                : (mov.quantity >= 0 ? '+${mov.quantity}' : '${mov.quantity}');

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF0E6DC)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A2E21).withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isIn
                            ? Icons.arrow_downward_rounded
                            : (isOut
                                ? Icons.arrow_upward_rounded
                                : Icons.tune_rounded),
                        color: accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mov.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A2E21),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${mov.notes ?? "Mutasi stok"} • ${dateFormat.format(mov.createdAt)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
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
                          deltaLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF5F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${mov.stockBefore} ➔ ${mov.stockAfter}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF7D5D49),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMovementFilterChip(String label, String? typeValue) {
    final isSelected = _movementTypeFilter == typeValue;
    return Material(
      color: isSelected ? const Color(0xFF4A2E21) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _movementTypeFilter = typeValue),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF4A2E21)
                  : const Color(0xFFE8DDD3),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF7D5D49),
            ),
          ),
        ),
      ),
    );
  }
}
