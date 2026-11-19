import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/product_model.dart';
import '../../../providers/menu_provider.dart';
import '../widgets/admin_header.dart';

enum _ProductStatusFilter { all, active, lowStock }

class AdminMenuTab extends StatefulWidget {
  final Function(int)? onTabNavigate;

  const AdminMenuTab({super.key, this.onTabNavigate});

  @override
  State<AdminMenuTab> createState() => _AdminMenuTabState();
}

class _AdminMenuTabState extends State<AdminMenuTab> {
  final TextEditingController _searchController = TextEditingController();
  _ProductStatusFilter _statusFilter = _ProductStatusFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _resolveCategoryName(MenuProvider menu, String? categoryId) {
    if (categoryId == null) return 'Umum';
    for (final cat in menu.categories) {
      if (cat.id == categoryId) return cat.name;
    }
    return 'Umum';
  }

  void _showQuickRestockDialog(BuildContext context, ProductModel product) {
    final menu = context.read<MenuProvider>();
    final qtyController = TextEditingController(text: '10');
    final costController = TextEditingController(
      text: (product.costPrice * 10).toInt().toString(),
    );
    final notesController = TextEditingController(text: 'Restock cepat admin');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.figmaSoftCream,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_box_rounded,
                color: AppColors.figmaCoffee,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Restock ${product.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 15.5,
                  color: AppColors.figmaCoffee,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stok saat ini: ${product.stock} porsi (Min: ${product.minStock})',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF9C7F6C),
                ),
              ),
              const SizedBox(height: 14),
              _buildFieldLabel('Jumlah Tambah Stok'),
              const SizedBox(height: 6),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(hint: '10'),
              ),
              const SizedBox(height: 12),
              _buildFieldLabel('Total Biaya Modal'),
              const SizedBox(height: 6),
              TextField(
                controller: costController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(hint: '0', prefixText: 'Rp '),
              ),
              const SizedBox(height: 12),
              _buildFieldLabel('Catatan'),
              const SizedBox(height: 6),
              TextField(
                controller: notesController,
                decoration: _inputDecoration(hint: 'Catatan restock...'),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9C7F6C),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.figmaCoffee,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final qty = int.tryParse(qtyController.text.trim()) ?? 0;
              final cost = double.tryParse(costController.text.trim()) ?? 0.0;
              if (qty <= 0) return;
              menu.restockProduct(
                productId: product.id,
                quantity: qty,
                buyCost: cost,
                notes: notesController.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Stok "${product.name}" bertambah +$qty porsi.',
                  ),
                  backgroundColor: AppColors.figmaReadyGreen,
                ),
              );
            },
            child: Text(
              'Simpan Stok',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductForm(BuildContext context, {ProductModel? existingProduct}) {
    final menu = context.read<MenuProvider>();

    final nameController = TextEditingController(
      text: existingProduct?.name ?? '',
    );
    final descController = TextEditingController(
      text: existingProduct?.description ?? '',
    );
    final priceController = TextEditingController(
      text: existingProduct != null ? existingProduct.price.toInt().toString() : '',
    );
    final hppController = TextEditingController(
      text: existingProduct != null ? existingProduct.costPrice.toInt().toString() : '',
    );
    final stockController = TextEditingController(
      text: existingProduct?.stock.toString() ?? '20',
    );
    final minStockController = TextEditingController(
      text: existingProduct?.minStock.toString() ?? '5',
    );
    final imageController = TextEditingController(
      text: existingProduct?.imageUrl ?? '',
    );

    String? selectedCategoryId = existingProduct?.categoryId ??
        (menu.categories.isNotEmpty ? menu.categories.first.id : null);
    bool trackStock = existingProduct?.trackStock ?? true;
    bool isActive = existingProduct?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final price = double.tryParse(priceController.text) ?? 0.0;
          final hpp = double.tryParse(hppController.text) ?? 0.0;
          final profit = (price - hpp).clamp(0.0, double.infinity);
          final margin =
              price > 0 ? (((price - hpp) / price) * 100).toStringAsFixed(1) : '0';

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Color(0xFFFAF6F1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.figmaSubtleBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 12, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.figmaCoffee,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          existingProduct != null
                              ? Icons.edit_rounded
                              : Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              existingProduct != null
                                  ? 'Edit Produk'
                                  : 'Tambah Produk Baru',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.figmaCoffee,
                              ),
                            ),
                            Text(
                              existingProduct != null
                                  ? 'Perbarui detail, harga, dan stok produk'
                                  : 'Tambahkan menu baru ke katalog COFFI',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF9C7F6C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.figmaCoffee,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFFEDE4DB), height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      MediaQuery.of(ctx).viewInsets.bottom + 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live Preview Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFF0E6DC)),
                          ),
                          child: Row(
                            children: [
                              AdminProductImage(
                                imageUrl: imageController.text.trim(),
                                size: 58,
                                borderRadius: 14,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nameController.text.trim().isEmpty
                                          ? 'Nama Produk Preview'
                                          : nameController.text.trim(),
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
                                      CurrencyFormatter.format(price),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.figmaHazelnut,
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
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Margin $margin%',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.figmaReadyGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildFieldLabel('Nama Produk'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: nameController,
                          onChanged: (_) => setModalState(() {}),
                          decoration: _inputDecoration(
                            hint: 'Contoh: COFFI Aren Signature',
                          ),
                        ),
                        const SizedBox(height: 14),

                        _buildFieldLabel('Kategori'),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: menu.categories.any(
                            (c) => c.id == selectedCategoryId,
                          )
                              ? selectedCategoryId
                              : null,
                          decoration: _inputDecoration(hint: 'Pilih kategori'),
                          dropdownColor: Colors.white,
                          items: menu.categories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    c.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: AppColors.figmaCoffee,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setModalState(() => selectedCategoryId = val),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('Harga Jual'),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: priceController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setModalState(() {}),
                                    decoration: _inputDecoration(
                                      hint: '22000',
                                      prefixText: 'Rp ',
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
                                  _buildFieldLabel('HPP (Modal)'),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: hppController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setModalState(() {}),
                                    decoration: _inputDecoration(
                                      hint: '10000',
                                      prefixText: 'Rp ',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4EAE1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.trending_up_rounded,
                                size: 18,
                                color: AppColors.figmaCoffee,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Estimasi Laba/Porsi: ${CurrencyFormatter.format(profit)} ($margin%)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.figmaCoffee,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Toggles Container
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE8DDD3)),
                          ),
                          child: Column(
                            children: [
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  'Status Produk Aktif',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.figmaCoffee,
                                  ),
                                ),
                                subtitle: Text(
                                  'Tampilkan di katalog pelanggan & kasir',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: const Color(0xFF9C7F6C),
                                  ),
                                ),
                                value: isActive,
                                activeColor: AppColors.figmaReadyGreen,
                                onChanged: (val) =>
                                    setModalState(() => isActive = val),
                              ),
                              const Divider(
                                color: Color(0xFFF3ECE4),
                                height: 1,
                              ),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  'Lacak Stok Otomatis',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.figmaCoffee,
                                  ),
                                ),
                                subtitle: Text(
                                  'Kurangi stok tiap transaksi berhasil',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: const Color(0xFF9C7F6C),
                                  ),
                                ),
                                value: trackStock,
                                activeColor: AppColors.figmaCoffee,
                                onChanged: (val) =>
                                    setModalState(() => trackStock = val),
                              ),
                            ],
                          ),
                        ),

                        if (trackStock) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Stok Tersedia'),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: stockController,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDecoration(hint: '20'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Batas Stok Kritis'),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: minStockController,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDecoration(hint: '5'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 14),

                        _buildFieldLabel('URL / Asset Foto Produk (Opsional)'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: imageController,
                          onChanged: (_) => setModalState(() {}),
                          decoration: _inputDecoration(
                            hint:
                                'https://... atau assets/images/products/...',
                          ),
                        ),

                        const SizedBox(height: 14),

                        _buildFieldLabel('Deskripsi Singkat'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: descController,
                          maxLines: 2,
                          decoration: _inputDecoration(
                            hint:
                                'Espresso khas COFFI dengan susu segar & gula aren...',
                          ),
                        ),

                        const SizedBox(height: 22),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.figmaCoffee,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              if (nameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Nama produk wajib diisi.'),
                                    backgroundColor: AppColors.berryRed,
                                  ),
                                );
                                return;
                              }

                              final product = ProductModel(
                                id: existingProduct?.id ?? const Uuid().v4(),
                                categoryId: selectedCategoryId,
                                name: nameController.text.trim(),
                                description: descController.text.trim(),
                                price: double.tryParse(priceController.text) ??
                                    0.0,
                                costPrice:
                                    double.tryParse(hppController.text) ?? 0.0,
                                stock: int.tryParse(stockController.text) ?? 0,
                                minStock:
                                    int.tryParse(minStockController.text) ?? 5,
                                trackStock: trackStock,
                                isActive: isActive,
                                imageUrl: imageController.text.trim().isNotEmpty
                                    ? imageController.text.trim()
                                    : (existingProduct?.imageUrl ??
                                        'assets/images/products/coffi_aren.png'),
                              );

                              menu.saveProduct(product);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Produk "${product.name}" berhasil disimpan!',
                                  ),
                                  backgroundColor: AppColors.figmaReadyGreen,
                                ),
                              );
                            },
                            child: Text(
                              'SIMPAN PRODUK',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: AppColors.figmaCoffee,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        color: const Color(0xFFB8A394),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8DDD3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.figmaCoffee, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();

    if (_searchController.text != menu.searchQuery) {
      _searchController.value = TextEditingValue(
        text: menu.searchQuery,
        selection: TextSelection.collapsed(offset: menu.searchQuery.length),
      );
    }

    final totalCount = menu.products.length;
    final activeCount = menu.products.where((p) => p.isActive).length;
    final lowStockCount = menu.lowStockProducts.length;

    final List<ProductModel> displayedProducts = menu.filteredProducts.where((p) {
      switch (_statusFilter) {
        case _ProductStatusFilter.active:
          return p.isActive;
        case _ProductStatusFilter.lowStock:
          return p.isLowStock || p.isOutOfStock;
        case _ProductStatusFilter.all:
          return true;
      }
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F1),
      body: Column(
        children: [
          AdminHeader(onTabNavigate: widget.onTabNavigate),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.figmaCoffee,
              onRefresh: () => menu.refreshProducts(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Page Heading + Add Product Pill CTA
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kelola Produk',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                        color: AppColors.figmaCoffee,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Atur katalog menu, harga, dan ketersediaan',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFFA0806D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () => _showProductForm(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.figmaCoffee,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 11,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: Text(
                                  'Tambah',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // 3 Compact Summary Filter Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryFilterCard(
                                  label: 'SEMUA',
                                  value: '$totalCount',
                                  isSelected:
                                      _statusFilter == _ProductStatusFilter.all,
                                  accentColor: AppColors.figmaCoffee,
                                  onTap: () => setState(
                                    () =>
                                        _statusFilter = _ProductStatusFilter.all,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildSummaryFilterCard(
                                  label: 'AKTIF',
                                  value: '$activeCount',
                                  isSelected: _statusFilter ==
                                      _ProductStatusFilter.active,
                                  accentColor: AppColors.figmaReadyGreen,
                                  onTap: () => setState(
                                    () => _statusFilter =
                                        _ProductStatusFilter.active,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildSummaryFilterCard(
                                  label: 'STOK KRITIS',
                                  value: '$lowStockCount',
                                  isSelected: _statusFilter ==
                                      _ProductStatusFilter.lowStock,
                                  accentColor: lowStockCount > 0
                                      ? const Color(0xFFC5A200)
                                      : AppColors.figmaReadyGreen,
                                  isWarningHighlight: lowStockCount > 0,
                                  onTap: () => setState(
                                    () => _statusFilter =
                                        _ProductStatusFilter.lowStock,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFEFE5DB),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.figmaCoffee.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                menu.setSearchQuery(val);
                                setState(() {});
                              },
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                color: AppColors.figmaCoffee,
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
                                          menu.setSearchQuery('');
                                          setState(() {});
                                        },
                                      )
                                    : null,
                                hintText: 'Cari nama menu atau deskripsi...',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  color: const Color(0xFFB39D8E),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),

                  // Category Filter Pills
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildCategoryPill(
                            label: 'Semua',
                            count: totalCount,
                            isSelected: menu.selectedCategoryId == null,
                            onTap: () => menu.selectCategory(null),
                          ),
                          ...menu.categories.map((cat) {
                            final count = menu.products
                                .where((p) => p.categoryId == cat.id)
                                .length;
                            return _buildCategoryPill(
                              label: cat.name,
                              count: count,
                              isSelected: menu.selectedCategoryId == cat.id,
                              onTap: () => menu.selectCategory(cat.id),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  // Product List or Empty State
                  if (displayedProducts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFEFE5DB),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: AppColors.figmaHazelnut,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Produk tidak ditemukan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.figmaCoffee,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Coba ubah filter kategori atau kata kunci pencarian.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  color: const Color(0xFF9C7F6C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = displayedProducts[index];
                            final categoryName = _resolveCategoryName(
                              menu,
                              product.categoryId,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildProductCard(
                                context: context,
                                menu: menu,
                                product: product,
                                categoryName: categoryName,
                              ),
                            );
                          },
                          childCount: displayedProducts.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryFilterCard({
    required String label,
    required String value,
    required bool isSelected,
    required Color accentColor,
    bool isWarningHighlight = false,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected
        ? (isWarningHighlight ? const Color(0xFFFFF8F0) : Colors.white)
        : (isWarningHighlight ? const Color(0xFFFFFAF6) : Colors.white);

    final borderColor = isSelected
        ? accentColor
        : (isWarningHighlight
            ? const Color(0xFFEAE3B0)
            : const Color(0xFFF0E6DC));

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.figmaCoffee.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: isWarningHighlight
                      ? const Color(0xFFC5A200)
                      : const Color(0xFFA0806D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPill({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? AppColors.figmaCoffee : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.figmaCoffee
                    : const Color(0xFFEFE5DB),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF7D6352),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.18)
                        : const Color(0xFFF7EFE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF9C7F6C),
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

  Widget _buildProductCard({
    required BuildContext context,
    required MenuProvider menu,
    required ProductModel product,
    required String categoryName,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF3ECE4), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.figmaCoffee.withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Opacity(
                opacity: product.isActive ? 1.0 : 0.45,
                child: AdminProductImage(
                  imageUrl: product.imageUrl,
                  size: 66,
                  borderRadius: 16,
                ),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7EFE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9C7F6C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: product.isActive
                            ? AppColors.figmaCoffee
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(
                          CurrencyFormatter.format(product.price),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.figmaCoffee,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Margin ${product.marginPercentage.toStringAsFixed(0)}%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.figmaReadyGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'HPP ${CurrencyFormatter.format(product.costPrice)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFFA88D7B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // Active Toggle
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 30,
                    child: Switch(
                      value: product.isActive,
                      activeColor: Colors.white,
                      activeTrackColor: AppColors.figmaLimitedGreen,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFDCD2C8),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) => menu.toggleSoldOut(product.id, !val),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.isActive ? 'Aktif' : 'Nonaktif',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: product.isActive
                          ? AppColors.figmaReadyGreen
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF3ECE4), height: 1),
          const SizedBox(height: 10),

          // Footer: Stock Pill + Quick Actions
          Row(
            children: [
              Expanded(child: _buildStockPill(product)),
              const SizedBox(width: 8),
              if (product.trackStock) ...[
                _buildActionChip(
                  icon: Icons.add_rounded,
                  label: 'Stok',
                  bgColor: const Color(0xFFFCF8F4),
                  borderColor: const Color(0xFFEFE5DB),
                  fgColor: AppColors.figmaCoffee,
                  onTap: () => _showQuickRestockDialog(context, product),
                ),
                const SizedBox(width: 8),
              ],
              _buildActionChip(
                icon: Icons.edit_outlined,
                label: 'Edit',
                bgColor: const Color(0xFFF4EAE1),
                borderColor: const Color(0xFFE9DACA),
                fgColor: AppColors.figmaCoffee,
                onTap: () =>
                    _showProductForm(context, existingProduct: product),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockPill(ProductModel product) {
    if (!product.trackStock) {
      return _stockChipContainer(
        bg: const Color(0xFFFCF8F4),
        border: const Color(0xFFEFE6DC),
        icon: Icons.all_inclusive_rounded,
        color: const Color(0xFF9C7F6C),
        text: 'Bebas Stok',
      );
    }

    if (product.isOutOfStock) {
      return _stockChipContainer(
        bg: const Color(0xFFFEF2F2),
        border: const Color(0xFFFECACA),
        icon: Icons.error_outline_rounded,
        color: AppColors.berryRed,
        text: 'Stok Habis',
      );
    }

    if (product.isLowStock) {
      return _stockChipContainer(
        bg: const Color(0xFFFFF8F5),
        border: const Color(0xFFEAE3B0),
        icon: Icons.warning_rounded,
        color: const Color(0xFFC5A200),
        text: 'Sisa ${product.stock} • Kritis',
      );
    }

    return _stockChipContainer(
      bg: const Color(0xFFFCF8F4),
      border: const Color(0xFFEFE6DC),
      icon: Icons.inventory_2_outlined,
      color: const Color(0xFF7D6352),
      text: 'Stok: ${product.stock} porsi',
    );
  }

  Widget _stockChipContainer({
    required Color bg,
    required Color border,
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color fgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: fgColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
