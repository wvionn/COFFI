import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/product_model.dart';
import '../../../providers/menu_provider.dart';
import '../widgets/admin_header.dart';

class AdminProductFormScreen extends StatefulWidget {
  final ProductModel? existingProduct;

  const AdminProductFormScreen({super.key, this.existingProduct});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  static const List<String> _units = [
    'cup',
    'pcs',
    'botol',
    'pack',
    'porsi',
    'kg',
    'liter',
  ];

  static const List<_PresetPhoto> _presetPhotos = [
    _PresetPhoto(
      label: 'COFFI Aren',
      path: 'assets/images/products/coffi_aren.png',
    ),
    _PresetPhoto(
      label: 'Croissant',
      path: 'assets/images/products/butter_croissant.png',
    ),
    _PresetPhoto(
      label: 'Americano',
      path: 'assets/images/products/iced_americano.png',
    ),
    _PresetPhoto(
      label: 'Cafe Latte',
      path: 'assets/images/products/cafe_latte.png',
    ),
    _PresetPhoto(
      label: 'Matcha Latte',
      path: 'assets/images/products/matcha_latte.png',
    ),
    _PresetPhoto(
      label: 'Dark Choco',
      path: 'assets/images/products/dark_choco.png',
    ),
    _PresetPhoto(
      label: 'Thai Tea',
      path: 'assets/images/products/royal_thai_tea.png',
    ),
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _hppController;
  late final TextEditingController _priceController;
  late final TextEditingController _descController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;
  late final TextEditingController _imageUrlController;

  String? _selectedCategoryId;
  late String _selectedUnit;
  late bool _isActive;
  bool _isSaving = false;

  bool get _isEditMode => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _hppController = TextEditingController(
      text: p != null && p.costPrice > 0
          ? CurrencyFormatter.formatNumber(p.costPrice)
          : '',
    );
    _priceController = TextEditingController(
      text: p != null && p.price > 0
          ? CurrencyFormatter.formatNumber(p.price)
          : '',
    );
    _descController = TextEditingController(text: p?.description ?? '');
    _stockController = TextEditingController(text: (p?.stock ?? 50).toString());
    _minStockController = TextEditingController(
      text: (p?.minStock ?? 5).toString(),
    );
    _imageUrlController = TextEditingController(
      text: p?.imageUrl ?? 'assets/images/products/coffi_aren.png',
    );

    _selectedCategoryId = p?.categoryId;
    final currentUnit = p?.displayUnit;
    _selectedUnit =
        (currentUnit != null && _units.contains(currentUnit)) ? currentUnit : 'pcs';
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hppController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _showPhotoPickerSheet() {
    final tempUrlController = TextEditingController(
      text: _imageUrlController.text.startsWith('http')
          ? _imageUrlController.text
          : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
                  'Pilih Foto Produk',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.figmaCoffee,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih dari katalog foto COFFI atau masukkan URL gambar.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF9C7F6C),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetPhotos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, index) {
                      final preset = _presetPhotos[index];
                      final isSelected =
                          _imageUrlController.text.trim() == preset.path;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _imageUrlController.text = preset.path);
                          Navigator.pop(ctx);
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.figmaCoffee
                                      : const Color(0xFFE8DDD3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: AdminProductImage(
                                imageUrl: preset.path,
                                size: 62,
                                borderRadius: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              preset.label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: AppColors.figmaCoffee,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF0E6DC)),
                const SizedBox(height: 12),
                Text(
                  'Atau URL Gambar (HTTPS)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.figmaCoffee,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tempUrlController,
                        decoration: _fieldDecoration(hint: 'https://...'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.figmaCoffee,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          final url = tempUrlController.text.trim();
                          if (url.isNotEmpty) {
                            setState(() => _imageUrlController.text = url);
                          }
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          'Pakai',
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
      ),
    );
  }

  Future<void> _submitSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama produk wajib diisi.'),
          backgroundColor: AppColors.berryRed,
        ),
      );
      return;
    }

    final price = CurrencyFormatter.parse(_priceController.text);
    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harga jual harus lebih dari Rp 0.'),
          backgroundColor: AppColors.berryRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final menu = context.read<MenuProvider>();
    final categoryId = _selectedCategoryId ??
        (menu.categories.isNotEmpty ? menu.categories.first.id : null);

    final product = ProductModel(
      id: widget.existingProduct?.id ?? const Uuid().v4(),
      categoryId: categoryId,
      name: name,
      description: _descController.text.trim(),
      price: price,
      costPrice: CurrencyFormatter.parse(_hppController.text),
      stock: (int.tryParse(_stockController.text.trim()) ?? 0).clamp(0, 999999),
      minStock:
          (int.tryParse(_minStockController.text.trim()) ?? 5).clamp(0, 999999),
      trackStock: true,
      isActive: _isActive,
      imageUrl: _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : 'assets/images/products/coffi_aren.png',
      unit: _selectedUnit,
    );

    await menu.saveProduct(product);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditMode
              ? 'Produk "${product.name}" berhasil diperbarui!'
              : 'Produk "${product.name}" berhasil ditambahkan!',
        ),
        backgroundColor: AppColors.figmaReadyGreen,
      ),
    );
    Navigator.pop(context, true);
  }

  void _confirmDeleteProduct() {
    final existing = widget.existingProduct;
    if (existing == null) return;
    final menu = context.read<MenuProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Hapus Produk?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4A2E21),
          ),
        ),
        content: Text(
          'Produk "${existing.name}" akan dihapus permanen dari katalog menu COFFI.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF7D6352),
          ),
        ),
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
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await menu.deleteProduct(existing.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Produk "${existing.name}" telah dihapus.'),
                    backgroundColor: const Color(0xFF4A2E21),
                  ),
                );
                Navigator.pop(context, true);
              }
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final categories = menu.categories;

    // Ensure selectedCategoryId stays valid with available categories
    final effectiveCategoryId =
        categories.any((c) => c.id == _selectedCategoryId)
            ? _selectedCategoryId
            : (categories.isNotEmpty ? categories.first.id : null);

    final price = CurrencyFormatter.parse(_priceController.text);
    final hpp = CurrencyFormatter.parse(_hppController.text);
    final profit = (price - hpp).clamp(0.0, double.infinity);
    final marginPct = price > 0 ? ((price - hpp) / price) * 100 : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: Column(
        children: [
          // Top Header matching Reference Image 2
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFF0E6DC), width: 1),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Material(
                      color: const Color(0xFFFAF5F0),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFEFE5DB),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF4A2E21),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _isEditMode ? 'Edit Produk' : 'Tambah Produk',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4A2E21),
                        ),
                      ),
                    ),
                    if (_isEditMode)
                      Material(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _confirmDeleteProduct,
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFDC2626),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Foto Produk
                  _buildLabel('Foto Produk'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFE8DDD3),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.figmaCoffee.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AdminProductImage(
                          imageUrl: _imageUrlController.text.trim(),
                          size: 86,
                          borderRadius: 17,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: OutlinedButton.icon(
                                onPressed: _showPhotoPickerSheet,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF6EFE8),
                                  foregroundColor: const Color(0xFF7D5D49),
                                  side: const BorderSide(
                                    color: Color(0xFFE8DDD3),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  _isEditMode ? 'Ganti Foto' : 'Pilih Foto',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Format JPG/PNG, Maks. 2MB',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFFA88D7B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 2. Nama Produk
                  _buildLabel('Nama Produk'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: _inputTextStyle(),
                    decoration: _fieldDecoration(hint: 'Contoh: COFFI Aren'),
                  ),

                  const SizedBox(height: 16),

                  // 3. Kategori
                  _buildLabel('Kategori'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: effectiveCategoryId,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF9C7F6C),
                    ),
                    dropdownColor: Colors.white,
                    style: _inputTextStyle(),
                    decoration: _fieldDecoration(hint: 'Pilih kategori'),
                    items: categories
                        .map(
                          (cat) => DropdownMenuItem<String>(
                            value: cat.id,
                            child: Text(cat.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategoryId = val),
                  ),

                  const SizedBox(height: 16),

                  // 4. Satuan Produk
                  _buildLabel('Satuan Produk'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF9C7F6C),
                    ),
                    dropdownColor: Colors.white,
                    style: _inputTextStyle(),
                    decoration: _fieldDecoration(hint: 'Pilih satuan'),
                    items: _units
                        .map(
                          (unit) => DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedUnit = val);
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Contoh: pcs, cup, botol, pack, kg, liter',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFFA88D7B),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5. HPP (Rp)
                  _buildLabel('HPP (Rp)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _hppController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    style: _inputTextStyle(),
                    onChanged: (_) => setState(() {}),
                    decoration: _fieldDecoration(
                      hint: 'Contoh: 10.500',
                      prefixText: 'Rp  ',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 6. Harga Jual (Rp)
                  _buildLabel('Harga Jual (Rp)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    style: _inputTextStyle(),
                    onChanged: (_) => setState(() {}),
                    decoration: _fieldDecoration(
                      hint: 'Contoh: 25.000',
                      prefixText: 'Rp  ',
                    ),
                  ),

                  if (price > 0) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: marginPct >= 0
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: marginPct >= 0
                              ? const Color(0xFFC5EFDC)
                              : const Color(0xFFFECACA),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            marginPct >= 0
                                ? Icons.trending_up_rounded
                                : Icons.warning_amber_rounded,
                            size: 16,
                            color: marginPct >= 0
                                ? AppColors.figmaReadyGreen
                                : AppColors.berryRed,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Margin ${marginPct.toStringAsFixed(1)}% • Laba ${CurrencyFormatter.format(profit)}/$_selectedUnit',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: marginPct >= 0
                                    ? AppColors.figmaReadyGreen
                                    : AppColors.berryRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // 7. Deskripsi
                  _buildLabel('Deskripsi'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    style: _inputTextStyle(),
                    decoration: _fieldDecoration(
                      hint:
                          'Espresso + Susu Gula Aren khas COFFI dengan tekstur yang creamy dan manis yang pas.',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 8. Stok Awal & Batas Kritis Card (matching Image 2)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF0E6DC)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.figmaCoffee.withOpacity(0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status Produk Aktif',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.figmaCoffee,
                                    ),
                                  ),
                                  Text(
                                    'Tampil di kasir & katalog pelanggan',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: const Color(0xFFA88D7B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isActive,
                              activeColor: Colors.white,
                              activeTrackColor: AppColors.figmaLimitedGreen,
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: const Color(0xFFDCD2C8),
                              onChanged: (val) =>
                                  setState(() => _isActive = val),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFFF3ECE4), height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isEditMode ? 'Stok Saat Ini' : 'Stok Awal',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF9C7F6C),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _stockController,
                                    keyboardType: TextInputType.number,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.figmaCoffee,
                                    ),
                                    decoration: _stockInputDecoration(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Batas Kritis',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF9C7F6C),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _minStockController,
                                    keyboardType: TextInputType.number,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.figmaCoffee,
                                    ),
                                    decoration: _stockInputDecoration(),
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
          ),

          // Sticky Bottom Action Bar: BATAL + SIMPAN PRODUK (matching Image 2)
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFF0E6DC), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D38220F),
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF8C6A56),
                            side: const BorderSide(
                              color: Color(0xFFE8DDD3),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'BATAL',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _submitSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.figmaCoffee,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add_rounded, size: 20),
                          label: Text(
                            'SIMPAN PRODUK',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.figmaCoffee,
      ),
    );
  }

  TextStyle _inputTextStyle() {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.figmaCoffee,
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      prefixStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFA0806D),
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFB8A394),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  InputDecoration _stockInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFFAF6F1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8DDD3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.figmaCoffee, width: 1.4),
      ),
    );
  }
}

class _PresetPhoto {
  final String label;
  final String path;

  const _PresetPhoto({required this.label, required this.path});
}
