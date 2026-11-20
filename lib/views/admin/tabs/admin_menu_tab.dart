import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/addon_model.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../providers/menu_provider.dart';
import '../screens/admin_product_form_screen.dart';
import '../widgets/admin_addon_view.dart';
import '../widgets/admin_category_view.dart';
import '../widgets/admin_header.dart';

enum _ProductModuleSection { produk, kategori, varian }

enum _StockFilter { all, active, lowStock, outOfStock }

enum _ProductSort { nameAsc, priceAsc, priceDesc, stockAsc }

class AdminMenuTab extends StatefulWidget {
  final Function(int)? onTabNavigate;

  const AdminMenuTab({super.key, this.onTabNavigate});

  @override
  State<AdminMenuTab> createState() => _AdminMenuTabState();
}

class _AdminMenuTabState extends State<AdminMenuTab> {
  final TextEditingController _searchController = TextEditingController();
  _ProductModuleSection? _activeSectionField = _ProductModuleSection.produk;
  _StockFilter? _stockFilterField = _StockFilter.all;
  _ProductSort? _sortModeField = _ProductSort.nameAsc;
  String? _subViewSearchQueryField = '';

  _ProductModuleSection get _activeSection =>
      _activeSectionField ?? _ProductModuleSection.produk;
  set _activeSection(_ProductModuleSection value) =>
      _activeSectionField = value;

  _StockFilter get _stockFilter => _stockFilterField ?? _StockFilter.all;
  set _stockFilter(_StockFilter value) => _stockFilterField = value;

  _ProductSort get _sortMode => _sortModeField ?? _ProductSort.nameAsc;
  set _sortMode(_ProductSort value) => _sortModeField = value;

  String get _subViewSearchQuery => _subViewSearchQueryField ?? '';
  set _subViewSearchQuery(String value) => _subViewSearchQueryField = value;

  static const List<String> _addonGroupOptions = [
    'TOPPING',
    'SUSU SUBSTITUSI',
    'FLAVOR',
    'TEMPERATURE',
    'SUGAR LEVEL',
  ];

  static const List<String> _addonPresetPhotos = [
    'assets/images/products/coffi_aren.png',
    'assets/images/products/matcha_latte.png',
    'assets/images/products/cafe_latte.png',
    'assets/images/products/dark_choco.png',
    'assets/images/products/iced_americano.png',
    'assets/images/products/royal_thai_tea.png',
    'assets/images/products/butter_croissant.png',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _switchSection(_ProductModuleSection section) {
    if (_activeSection == section) return;
    setState(() {
      _activeSection = section;
      _subViewSearchQuery = '';
      if (section == _ProductModuleSection.produk) {
        final menuQuery = context.read<MenuProvider>().searchQuery;
        _searchController.text = menuQuery;
      } else {
        _searchController.clear();
      }
    });
  }

  String _resolveCategoryName(MenuProvider menu, String? categoryId) {
    if (categoryId == null) return 'UMUM';
    for (final cat in menu.categories) {
      if (cat.id == categoryId) return cat.name;
    }
    return 'UMUM';
  }

  Future<void> _openProductForm(
    BuildContext context, {
    ProductModel? product,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProductFormScreen(existingProduct: product),
      ),
    );
  }

  // =========================================================================
  // FILTER & SORT BOTTOM SHEET (PRODUK)
  // =========================================================================

  void _showFilterSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
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
                    Expanded(
                      child: Text(
                        'Filter & Urutkan Produk',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.figmaCoffee,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _stockFilter = _StockFilter.all;
                          _sortMode = _ProductSort.nameAsc;
                        });
                        setModalState(() {});
                      },
                      child: Text(
                        'Reset',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9C7F6C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'STATUS STOK',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: const Color(0xFF9C7F6C),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSheetPill(
                      label: 'Semua',
                      selected: _stockFilter == _StockFilter.all,
                      onTap: () {
                        setState(() => _stockFilter = _StockFilter.all);
                        setModalState(() {});
                      },
                    ),
                    _buildSheetPill(
                      label: 'Tersedia / Aktif',
                      selected: _stockFilter == _StockFilter.active,
                      onTap: () {
                        setState(() => _stockFilter = _StockFilter.active);
                        setModalState(() {});
                      },
                    ),
                    _buildSheetPill(
                      label: 'Stok Kritis',
                      selected: _stockFilter == _StockFilter.lowStock,
                      onTap: () {
                        setState(() => _stockFilter = _StockFilter.lowStock);
                        setModalState(() {});
                      },
                    ),
                    _buildSheetPill(
                      label: 'Habis / Nonaktif',
                      selected: _stockFilter == _StockFilter.outOfStock,
                      onTap: () {
                        setState(() => _stockFilter = _StockFilter.outOfStock);
                        setModalState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'URUTKAN BERDASARKAN',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: const Color(0xFF9C7F6C),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSheetPill(
                      label: 'Nama (A–Z)',
                      selected: _sortMode == _ProductSort.nameAsc,
                      onTap: () {
                        setState(() => _sortMode = _ProductSort.nameAsc);
                        setModalState(() {});
                      },
                    ),
                    _buildSheetPill(
                      label: 'Harga Termurah',
                      selected: _sortMode == _ProductSort.priceAsc,
                      onTap: () {
                        setState(() => _sortMode = _ProductSort.priceAsc);
                        setModalState(() {});
                      },
                    ),
                    _buildSheetPill(
                      label: 'Harga Termahal',
                      selected: _sortMode == _ProductSort.priceDesc,
                      onTap: () {
                        setState(() => _sortMode = _ProductSort.priceDesc);
                        setModalState(() {});
                      },
                    ),
                    _buildSheetPill(
                      label: 'Stok Paling Sedikit',
                      selected: _sortMode == _ProductSort.stockAsc,
                      onTap: () {
                        setState(() => _sortMode = _ProductSort.stockAsc);
                        setModalState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
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
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'TERAPKAN',
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
      ),
    );
  }

  Widget _buildSheetPill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppColors.figmaCoffee : const Color(0xFFFAF5F0),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.figmaCoffee : const Color(0xFFE8DDD3),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.figmaCoffee,
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // DELETE CONFIRMATION DIALOGS (KATEGORI & ADD-ON)
  // =========================================================================

  void _confirmDeleteCategory(BuildContext context, CategoryModel category) {
    final menu = context.read<MenuProvider>();
    final productCount =
        menu.products.where((p) => p.categoryId == category.id).length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Hapus Kategori?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            color: AppColors.figmaCoffee,
          ),
        ),
        content: Text(
          productCount > 0
              ? 'Kategori "${category.name}" saat ini berisi $productCount produk. Yakin ingin menghapus kategori ini?'
              : 'Kategori "${category.name}" akan dihapus dari daftar kategori.',
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
              backgroundColor: const Color(0xFFE14949),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await menu.deleteCategory(category.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kategori "${category.name}" dihapus.'),
                    backgroundColor: AppColors.figmaCoffee,
                  ),
                );
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

  void _confirmDeleteAddon(BuildContext context, AddonModel addon) {
    final menu = context.read<MenuProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Hapus Add-on?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            color: AppColors.figmaCoffee,
          ),
        ),
        content: Text(
          'Varian / add-on "${addon.name}" akan dihapus dari daftar tambahan produk.',
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
              backgroundColor: const Color(0xFFE14949),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              menu.deleteAddon(addon.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Add-on "${addon.name}" telah dihapus.'),
                  backgroundColor: AppColors.figmaCoffee,
                ),
              );
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

  // =========================================================================
  // CATEGORY FORM SHEET (TAMBAH / EDIT KATEGORI)
  // =========================================================================

  void _showCategoryFormSheet(
    BuildContext context, {
    CategoryModel? existingCategory,
  }) {
    final menu = context.read<MenuProvider>();
    final nameController = TextEditingController(
      text: existingCategory?.name ?? '',
    );
    String selectedIcon = existingCategory?.icon ?? 'coffee';
    final productCount = existingCategory == null
        ? 0
        : menu.products
            .where((p) => p.categoryId == existingCategory.id)
            .length;

    const iconChoices = [
      {'id': 'coffee', 'label': 'Espresso'},
      {'id': 'local_drink', 'label': 'Non-Coffee'},
      {'id': 'coffee_maker', 'label': 'Manual Brew'},
      {'id': 'cake', 'label': 'Pastry'},
      {'id': 'grain', 'label': 'Beans'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
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
                    existingCategory != null
                        ? 'Edit Kategori'
                        : 'Tambah Kategori Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.figmaCoffee,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Nama Kategori',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.figmaCoffee,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    autofocus: existingCategory == null,
                    decoration: _modalInputDecoration(
                      hint: 'Contoh: Espresso-Based, Signature, Pastry',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Tipe / Ikon Kategori',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.figmaCoffee,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: iconChoices.map((item) {
                      final isSelected = selectedIcon == item['id'];
                      return _buildSheetPill(
                        label: item['label']!,
                        selected: isSelected,
                        onTap: () =>
                            setModalState(() => selectedIcon = item['id']!),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  if (existingCategory != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.figmaCoffee,
                          side: const BorderSide(color: Color(0xFFE8DDD3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          menu.selectCategory(existingCategory.id);
                          _switchSection(_ProductModuleSection.produk);
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 17),
                        label: Text(
                          'Lihat $productCount Produk di Kategori Ini',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.figmaCoffee,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        final cat = CategoryModel(
                          id: existingCategory?.id ?? const Uuid().v4(),
                          name: name,
                          icon: selectedIcon,
                          sortOrder: existingCategory?.sortOrder ??
                              (menu.categories.length + 1),
                          isActive: true,
                        );
                        Navigator.pop(ctx);
                        await menu.saveCategory(cat);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Kategori "${cat.name}" berhasil disimpan!',
                              ),
                              backgroundColor: AppColors.figmaReadyGreen,
                            ),
                          );
                        }
                      },
                      child: Text(
                        existingCategory != null
                            ? 'SIMPAN PERUBAHAN'
                            : '+ TAMBAH KATEGORI BARU',
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
        ),
      ),
    );
  }

  // =========================================================================
  // ADD-ON / VARIAN FORM SHEET (TAMBAH / EDIT ADD-ON)
  // =========================================================================

  void _showAddonFormSheet(
    BuildContext context, {
    AddonModel? existingAddon,
  }) {
    final menu = context.read<MenuProvider>();
    final nameController = TextEditingController(
      text: existingAddon?.name ?? '',
    );
    final priceController = TextEditingController(
      text: existingAddon != null && existingAddon.price > 0
          ? CurrencyFormatter.formatNumber(existingAddon.price)
          : '',
    );
    String selectedGroup = existingAddon?.group ?? _addonGroupOptions.first;
    String selectedImage =
        existingAddon?.imageUrl ?? _addonPresetPhotos.first;
    bool isActive = existingAddon?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
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
                    existingAddon != null
                        ? 'Edit Varian / Add-on'
                        : 'Tambah Add-on Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.figmaCoffee,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Nama Varian / Add-on',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.figmaCoffee,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    autofocus: existingAddon == null,
                    decoration: _modalInputDecoration(
                      hint: 'Contoh: Extra Shot, Oat Milk, Syrup Caramel',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Kategori Tambahan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.figmaCoffee,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _addonGroupOptions
                        .map(
                          (g) => _buildSheetPill(
                            label: g,
                            selected: selectedGroup == g,
                            onTap: () => setModalState(() => selectedGroup = g),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Tambahan Harga (Rp)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.figmaCoffee,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    decoration: _modalInputDecoration(
                      hint: '0 untuk Gratis (misal: 5.000)',
                      prefixText: '+Rp ',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Thumbnail',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.figmaCoffee,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 58,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _addonPresetPhotos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final path = _addonPresetPhotos[i];
                        final isSel = selectedImage == path;
                        return GestureDetector(
                          onTap: () =>
                              setModalState(() => selectedImage = path),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSel
                                    ? AppColors.figmaCoffee
                                    : const Color(0xFFE8DDD3),
                                width: isSel ? 2 : 1,
                              ),
                            ),
                            child: AdminProductImage(
                              imageUrl: path,
                              size: 50,
                              borderRadius: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Status Aktif',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.figmaCoffee,
                      ),
                    ),
                    value: isActive,
                    activeColor: AppColors.figmaReadyGreen,
                    onChanged: (val) => setModalState(() => isActive = val),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
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
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        final addon = AddonModel(
                          id: existingAddon?.id ?? const Uuid().v4(),
                          name: name,
                          group: selectedGroup,
                          price: CurrencyFormatter.parse(priceController.text),
                          imageUrl: selectedImage,
                          isActive: isActive,
                        );
                        menu.saveAddon(addon);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Add-on "${addon.name}" berhasil disimpan!',
                            ),
                            backgroundColor: AppColors.figmaReadyGreen,
                          ),
                        );
                      },
                      child: Text(
                        existingAddon != null
                            ? 'SIMPAN PERUBAHAN'
                            : '+ TAMBAH ADD-ON',
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
        ),
      ),
    );
  }

  InputDecoration _modalInputDecoration({
    required String hint,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      prefixStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF9C7F6C),
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        color: const Color(0xFFB8A394),
      ),
      filled: true,
      fillColor: const Color(0xFFFAF6F1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8DDD3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.figmaCoffee, width: 1.4),
      ),
    );
  }

  // =========================================================================
  // MAIN BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();

    if (_activeSection == _ProductModuleSection.produk &&
        _searchController.text != menu.searchQuery) {
      _searchController.value = TextEditingValue(
        text: menu.searchQuery,
        selection: TextSelection.collapsed(offset: menu.searchQuery.length),
      );
    }

    // Dynamic header texts matching Images 1, 3, and 4
    final String headerTitle;
    final String headerSubtitle;
    final String searchHint;
    final String fabLabel;

    switch (_activeSection) {
      case _ProductModuleSection.produk:
        headerTitle = 'Kelola Produk';
        headerSubtitle = 'Total: ${menu.products.length} Menu';
        searchHint = 'Cari produk...';
        fabLabel = 'Tambah Produk';
        break;
      case _ProductModuleSection.kategori:
        headerTitle = 'Kelola Kategori';
        headerSubtitle = 'Total: ${menu.categories.length} Kategori';
        searchHint = 'Cari kategori...';
        fabLabel = 'Tambah Kategori';
        break;
      case _ProductModuleSection.varian:
        headerTitle = 'Kelola Varian & Add-on';
        headerSubtitle = 'Manajemen Tambahan Produk';
        searchHint = 'Cari varian atau add-on...';
        fabLabel = 'Tambah Add-on';
        break;
    }

    // Filter & sort products for Produk sub-view
    final List<ProductModel> displayedProducts = menu.filteredProducts.where((p) {
      switch (_stockFilter) {
        case _StockFilter.active:
          return p.isActive && !p.isOutOfStock;
        case _StockFilter.lowStock:
          return p.isLowStock;
        case _StockFilter.outOfStock:
          return !p.isActive || p.isOutOfStock;
        case _StockFilter.all:
          return true;
      }
    }).toList();

    displayedProducts.sort((a, b) {
      switch (_sortMode) {
        case _ProductSort.priceAsc:
          return a.price.compareTo(b.price);
        case _ProductSort.priceDesc:
          return b.price.compareTo(a.price);
        case _ProductSort.stockAsc:
          return a.stock.compareTo(b.stock);
        case _ProductSort.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });

    final selectedCategoryLabel = menu.selectedCategoryId == null
        ? 'Semua'
        : _resolveCategoryName(menu, menu.selectedCategoryId);
    final hasExtraFilter =
        _stockFilter != _StockFilter.all || _sortMode != _ProductSort.nameAsc;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'admin_produk_fab',
        backgroundColor: const Color(0xFF4A2E21),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        onPressed: () {
          switch (_activeSection) {
            case _ProductModuleSection.produk:
              _openProductForm(context);
              break;
            case _ProductModuleSection.kategori:
              _showCategoryFormSheet(context);
              break;
            case _ProductModuleSection.varian:
              _showAddonFormSheet(context);
              break;
          }
        },
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          fabLabel,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: Column(
        children: [
          // Top White Panel matching Minimalist Cafe POS Design
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFAF6F0),
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
                    // Row 1: Coffee Icon Badge + Title/Subtitle + Hamburger Button
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
                                  color: const Color(0xFF8C7262),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          color: const Color(0xFFFDFBF8),
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
                                  color: const Color(0xFFE5D8CC),
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

                    const SizedBox(height: 14),

                    // Row 2: Segmented Pill Tab Bar (Produk | Kategori | Varian & Add-on)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE4DA),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          _buildSectionTab(
                            label: 'Produk',
                            section: _ProductModuleSection.produk,
                          ),
                          _buildSectionTab(
                            label: 'Kategori',
                            section: _ProductModuleSection.kategori,
                          ),
                          _buildSectionTab(
                            label: 'Varian & Add-on',
                            section: _ProductModuleSection.varian,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Row 3: Rounded Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFBF8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFE5D8CC),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          if (_activeSection == _ProductModuleSection.produk) {
                            menu.setSearchQuery(val);
                          } else {
                            setState(() => _subViewSearchQuery = val);
                          }
                          setState(() {});
                        },
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color: const Color(0xFF4A2E21),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF8C7262),
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: Color(0xFF8C7262),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    if (_activeSection ==
                                        _ProductModuleSection.produk) {
                                      menu.setSearchQuery('');
                                    } else {
                                      _subViewSearchQuery = '';
                                    }
                                    setState(() {});
                                  },
                                )
                              : null,
                          hintText: searchHint,
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            color: const Color(0xFF9C8678),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),

                    // Row 4: Category Dropdown Pill + Filter Icon Button
                    if (_activeSection == _ProductModuleSection.produk) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: PopupMenuButton<String>(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              onSelected: (val) {
                                menu.selectCategory(
                                  val == '__ALL__' ? null : val,
                                );
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem<String>(
                                  value: '__ALL__',
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Semua Kategori (${menu.products.length})',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight:
                                                menu.selectedCategoryId == null
                                                    ? FontWeight.w800
                                                    : FontWeight.w500,
                                            color: const Color(0xFF4A2E21),
                                          ),
                                        ),
                                      ),
                                      if (menu.selectedCategoryId == null)
                                        const Icon(
                                          Icons.check_rounded,
                                          size: 16,
                                          color: Color(0xFF4A2E21),
                                        ),
                                    ],
                                  ),
                                ),
                                ...menu.categories.map((cat) {
                                  final count = menu.products
                                      .where((p) => p.categoryId == cat.id)
                                      .length;
                                  final isSel =
                                      menu.selectedCategoryId == cat.id;
                                  return PopupMenuItem<String>(
                                    value: cat.id,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${cat.name} ($count)',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: isSel
                                                  ? FontWeight.w800
                                                  : FontWeight.w500,
                                              color: const Color(0xFF4A2E21),
                                            ),
                                          ),
                                        ),
                                        if (isSel)
                                          const Icon(
                                            Icons.check_rounded,
                                            size: 16,
                                            color: Color(0xFF4A2E21),
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                              child: Container(
                                height: 42,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDFBF8),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFE5D8CC),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Kategori: $selectedCategoryLabel',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF4A2E21),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 20,
                                      color: Color(0xFF4A2E21),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Material(
                                color: const Color(0xFFFDFBF8),
                                borderRadius: BorderRadius.circular(14),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => _showFilterSortSheet(context),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: hasExtraFilter
                                            ? const Color(0xFF4A2E21)
                                            : const Color(0xFFE5D8CC),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.tune_rounded,
                                      size: 20,
                                      color: Color(0xFF4A2E21),
                                    ),
                                  ),
                                ),
                              ),
                              if (hasExtraFilter)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4A2E21),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Active Sub-View Content
          Expanded(
            child: RefreshIndicator(
              color: AppColors.figmaCoffee,
              onRefresh: () => menu.refreshProducts(),
              child: _buildActiveSectionBody(
                context: context,
                menu: menu,
                displayedProducts: displayedProducts,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTab({
    required String label,
    required _ProductModuleSection section,
  }) {
    final isSelected = _activeSection == section;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchSection(section),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4A2E21) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF4A2E21).withOpacity(0.16),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF5D4638),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSectionBody({
    required BuildContext context,
    required MenuProvider menu,
    required List<ProductModel> displayedProducts,
  }) {
    switch (_activeSection) {
      case _ProductModuleSection.kategori:
        return AdminCategoryView(
          searchQuery: _subViewSearchQuery,
          onEditCategory: (cat) => _showCategoryFormSheet(
            context,
            existingCategory: cat,
          ),
          onDeleteCategory: (cat) => _confirmDeleteCategory(context, cat),
        );

      case _ProductModuleSection.varian:
        return AdminAddonView(
          searchQuery: _subViewSearchQuery,
          onEditAddon: (addon) => _showAddonFormSheet(
            context,
            existingAddon: addon,
          ),
          onDeleteAddon: (addon) => _confirmDeleteAddon(context, addon),
        );

      case _ProductModuleSection.produk:
        if (displayedProducts.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 96),
            children: [
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEFE5DB)),
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
                    'Ubah filter kategori atau tambah produk baru melalui tombol di kanan bawah.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: const Color(0xFF9C7F6C),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 136),
          itemCount: displayedProducts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = displayedProducts[index];
            final categoryName = _resolveCategoryName(menu, product.categoryId);
            return _buildProductCard(
              context: context,
              menu: menu,
              product: product,
              categoryName: categoryName,
            );
          },
        );
    }
  }

  void _showToggleUndoToast(
    BuildContext context, {
    required MenuProvider menu,
    required ProductModel product,
    required bool turnedOn,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        backgroundColor: const Color(0xFFF3F4F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Expanded(
              child: Text(
                turnedOn
                    ? '${product.name} diaktifkan'
                    : '${product.name} dinonaktifkan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                messenger.hideCurrentSnackBar();
                menu.toggleSoldOut(product.id, turnedOn);
              },
              child: Text(
                '(Urungkan)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A2E21),
                ),
              ),
            ),
          ],
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
    final bool isAvailable = product.isActive && !product.isOutOfStock;
    final Color badgeBg;
    final Color badgeFg;
    final String badgeText;

    if (product.isOutOfStock) {
      // Actual empty stock
      badgeBg = const Color(0xFFFEE2E2);
      badgeFg = const Color(0xFFDC2626);
      badgeText = 'Habis';
    } else if (!product.isActive) {
      // Manually disabled via toggle while stock still exists
      badgeBg = const Color(0xFFE5E7EB);
      badgeFg = const Color(0xFF4B5563);
      badgeText = 'Nonaktif';
    } else if (product.isLowStock) {
      badgeBg = const Color(0xFFFEF3C7);
      badgeFg = const Color(0xFFB45309);
      badgeText = 'Sisa ${product.stock}';
    } else {
      badgeBg = const Color(0xFFDCFCE7);
      badgeFg = const Color(0xFF16A34A);
      badgeText = 'Tersedia';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFE6DC), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A2E21).withOpacity(0.05),
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
          onTap: () => _openProductForm(context, product: product),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Real Product Image from Supabase / Local Assets
                Stack(
                  children: [
                    Opacity(
                      opacity: isAvailable ? 1.0 : 0.55,
                      child: AdminProductImage(
                        imageUrl: product.imageUrl,
                        size: 64,
                        borderRadius: 16,
                      ),
                    ),
                    if (product.isOutOfStock)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A2E21).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'HABIS',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 14),

                // Product Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: const Color(0xFF8C7262),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: isAvailable
                              ? const Color(0xFF23160D)
                              : const Color(0xFF6B584C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(product.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isAvailable
                              ? const Color(0xFF23160D)
                              : const Color(0xFF8C7262),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Right Column: Status Pill Badge + Espresso Toggle Switch
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: badgeFg,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _EspressoToggleSwitch(
                      value: isAvailable,
                      onChanged: (nextVal) {
                        if (nextVal && product.isOutOfStock) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Stok "${product.name}" sedang 0. Perbarui stok di Edit Produk.',
                              ),
                              backgroundColor: const Color(0xFF4A2E21),
                              action: SnackBarAction(
                                label: 'Edit Stok',
                                textColor: const Color(0xFFFEF3C7),
                                onPressed: () =>
                                    _openProductForm(context, product: product),
                              ),
                            ),
                          );
                          return;
                        }
                        menu.toggleSoldOut(product.id, !nextVal);
                        _showToggleUndoToast(
                          context,
                          menu: menu,
                          product: product,
                          turnedOn: nextVal,
                        );
                      },
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

class _EspressoToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _EspressoToggleSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 48,
        height: 27,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF4A2E21) : const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 21,
            height: 21,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
