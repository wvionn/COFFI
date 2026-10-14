import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/product_model.dart';
import '../../../providers/menu_provider.dart';

class AdminMenuTab extends StatelessWidget {
  const AdminMenuTab({super.key});

  void _showProductForm(BuildContext context, {ProductModel? existingProduct}) {
    final menu = context.read<MenuProvider>();

    final nameController = TextEditingController(text: existingProduct?.name ?? '');
    final descController = TextEditingController(text: existingProduct?.description ?? '');
    final priceController = TextEditingController(text: existingProduct?.price.toInt().toString() ?? '');
    final hppController = TextEditingController(text: existingProduct?.costPrice.toInt().toString() ?? '');
    final stockController = TextEditingController(text: existingProduct?.stock.toString() ?? '20');
    final minStockController = TextEditingController(text: existingProduct?.minStock.toString() ?? '5');
    final imageController = TextEditingController(text: existingProduct?.imageUrl ?? '');

    String? selectedCategoryId = existingProduct?.categoryId ?? (menu.categories.isNotEmpty ? menu.categories.first.id : null);
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
          final margin = price > 0 ? (((price - hpp) / price) * 100).toStringAsFixed(1) : '0';

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.88,
            decoration: const BoxDecoration(
              color: AppColors.oatMilkFoam,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderSubtle, borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        existingProduct != null ? 'EDIT MENU CAFE' : 'TAMBAH MENU BARU',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.espressoDark),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nama Menu:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(hintText: 'e.g. Caramel Macchiato'),
                        ),
                        const SizedBox(height: 14),

                        Text('Kategori Menu:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: selectedCategoryId,
                          decoration: const InputDecoration(),
                          items: menu.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (val) => setModalState(() => selectedCategoryId = val),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Harga Jual:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: priceController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setModalState(() {}),
                                    decoration: const InputDecoration(prefixText: 'Rp '),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('HPP (Harga Modal):', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: hppController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setModalState(() {}),
                                    decoration: const InputDecoration(prefixText: 'Rp '),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Profit Margin Indicator
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.creamLatte.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '📊 Estimasi Margin: $margin%  |  Laba/Porsi: ${CurrencyFormatter.format((price - hpp).clamp(0, 9999999))}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.roastedCoffee),
                          ),
                        ),

                        const SizedBox(height: 16),

                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Lacak Stok Bahan/Porsi', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                          value: trackStock,
                          activeColor: AppColors.roastedCoffee,
                          onChanged: (val) => setModalState(() => trackStock = val),
                        ),

                        if (trackStock)
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Stok Tersedia:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: stockController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Batas Min. Stok:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: minStockController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 14),

                        Text('URL Foto Menu (Opsional):', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: imageController,
                          decoration: const InputDecoration(hintText: 'https://...'),
                        ),

                        const SizedBox(height: 14),

                        Text('Deskripsi Menu:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: descController,
                          maxLines: 2,
                          decoration: const InputDecoration(hintText: 'e.g. Espresso blend dengan susu segar...'),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              if (nameController.text.trim().isEmpty) return;

                              final product = ProductModel(
                                id: existingProduct?.id ?? const Uuid().v4(),
                                categoryId: selectedCategoryId,
                                name: nameController.text.trim(),
                                description: descController.text.trim(),
                                price: double.tryParse(priceController.text) ?? 0.0,
                                costPrice: double.tryParse(hppController.text) ?? 0.0,
                                stock: int.tryParse(stockController.text) ?? 0,
                                minStock: int.tryParse(minStockController.text) ?? 5,
                                trackStock: trackStock,
                                isActive: isActive,
                                imageUrl: imageController.text.trim().isNotEmpty
                                    ? imageController.text.trim()
                                    : (existingProduct?.imageUrl ?? 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500&auto=format&fit=crop&q=60'),
                              );

                              menu.saveProduct(product);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Menu "${product.name}" berhasil disimpan!'),
                                  backgroundColor: AppColors.matchaGreen,
                                ),
                              );
                            },
                            child: const Text('SIMPAN MENU'),
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

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();

    return Scaffold(
      backgroundColor: AppColors.oatMilkFoam,
      appBar: AppBar(
        title: const Text('KELOLA MENU CAFE'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.roastedCoffee,
        foregroundColor: Colors.white,
        onPressed: () => _showProductForm(context),
        icon: const Icon(Icons.add),
        label: const Text('TAMBAH MENU'),
      ),
      body: Column(
        children: [
          // Search & Filter
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.white,
            child: TextField(
              onChanged: (val) => menu.setSearchQuery(val),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                hintText: 'Cari menu...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                fillColor: AppColors.oatMilkFoam,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Categories Tabs
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCatChip('Semua (${menu.products.length})', isSelected: menu.selectedCategoryId == null, onTap: () => menu.selectCategory(null)),
                ...menu.categories.map((c) {
                  final count = menu.products.where((p) => p.categoryId == c.id).length;
                  return _buildCatChip('${c.name} ($count)', isSelected: menu.selectedCategoryId == c.id, onTap: () => menu.selectCategory(c.id));
                }),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Product List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
              itemCount: menu.filteredProducts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final product = menu.filteredProducts[index];

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: AppColors.creamLatte.withOpacity(0.4),
                          child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                              ? Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.coffee))
                              : const Icon(Icons.coffee),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.espressoDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Harga: ${CurrencyFormatter.format(product.price)}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.roastedCoffee),
                            ),
                            Text(
                              'HPP: ${CurrencyFormatter.format(product.costPrice)} • Margin: ${product.marginPercentage.toStringAsFixed(0)}%',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            Text(
                              product.trackStock ? 'Stok: ${product.stock} porsi' : 'Bebas Stok',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: product.isLowStock ? FontWeight.w700 : FontWeight.normal,
                                color: product.isLowStock ? AppColors.amberOrange : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Switch(
                            value: product.isActive,
                            activeColor: AppColors.matchaGreen,
                            onChanged: (val) => menu.toggleSoldOut(product.id, !val),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.warmCaramel),
                            onPressed: () => _showProductForm(context, existingProduct: product),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatChip(String label, {required bool isSelected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.creamLatte,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
